module addrselect #(parameter WIDTH = 32) 
(	input [31:0] adr,
	input [31:0] mmemdata,mmemdatah,dmemdata,
	output menable,denable,
	output [31:0]memdata);
	
	wire s,h;
	wire [31:0]selmmemdata;

	assign s = (adr[31:0] == 32'b111111111111111111111111111xxxxx);
	assign h = (adr[31] == 1);
	assign denable = s ? 1'b1 : 1'b0; 
	assign menable = s ? 1'b0 : 1'b1; 
	assign selmmemdata = h ? mmemdatah : mmemdata; 
	assign memdata = s ? dmemdata : selmmemdata; 
 		
endmodule

module gpio(input [31:0]adr,data,
            input clk,wenable,
            output [15:0]gpio);
            
         reg [31:0]register;
			
			initial begin
			register <= 32'h0000_0000;
			end
				
         
        always @(posedge clk) begin
            if(adr == 32'hFFFFFF00 && wenable == 1'b1) register <= data[15:0];
         end   
         
         assign gpio[15:0] = register[15:0];
            
endmodule


module i2ccntl(clk,adr,writedata,denable,memwrite,dmemdata2,scl,sda);
	input clk,denable;
	input [31:0]writedata;
	input [31:0]adr;
	input memwrite;
	output [31:0]dmemdata2;
	output scl;
	inout sda;
	
	wire [7:0]status_reg,input_addrreg;
//	wire[31:0]input_datareg;
	reg [7:0]i2c_status_reg,i2c_input_addrreg;
	reg [7:0]mem_status_reg,mem_input_addrreg;
	reg [31:0]i2c_input_datareg,mem_input_datareg;
	wire [31:0]input_datareg;
	reg [31:0]output_datareg;	
	reg [5:0]status;
	reg scl_reg,sda_reg,sda_rw,i2c_start,i2c_clk,memflashmem,i2cflashmem;
	
	assign scl = scl_reg;
	assign sda = (sda_rw)?sda_reg:1'bz;
	
	reg [7:0]clk_counter;
		
	integer i;
	wire [5:0] memaddr,memaddr2;
	wire flashmem;
	
	assign status_reg = i2c_status_reg^mem_status_reg;
	assign input_addrreg = mem_input_addrreg ^ i2c_input_addrreg;
	assign input_datareg = mem_input_datareg;

	initial begin
		status <= 6'b000000;
		i2c_status_reg <= 8'b0;
		mem_status_reg <= 8'b0;
		i2c_input_addrreg <= 8'b0;
		mem_input_addrreg <= 8'b0;
		i2c_input_datareg <= 32'b0;
		mem_input_datareg <= 32'b0;
		scl_reg <= 1;
		sda_reg <= 1;
		sda_rw <= 1;
		i <= 0;
		i2c_clk <= 1'b1;
		i2c_start <= 0;
		clk_counter <= 8'b00000000;
	end
	//メモ status_regの中身
	//0 R/W設定状?��?��?(0 = W,1 = R)
	//1 通信状?��?��? (1 = 通信中,0 = 通信終�?��?)
	//2 送信レジスタ使用状?��?��?(1 = レジスタ利用中??��?��?��??��信中??��?,0 = レジスタ空(送信済み))
	//3 受信レジスタ使用状?��?��?(1 = レジスタ利用中??��?read?��?��?ータあり??��?,0 = レジスタ空(read?��?��?ータな?��?��?))
	//4 送信?��?��?示(CPUからのレジスタ書き込み終�?��?)
	//5-7 今�??��ところ未使用
	
	wire act0,act1,act2;
	
	assign act0 = (adr[4:0] == 5'b00111 ); //addr 0xFFFF_FFE7
	assign act1 = (adr[4:0] == 5'b01000 ); //addr 0xFFFF_FFE8
	assign act2 = (adr[4:0] == 5'b01001 ); //addr 0xFFFF_FFE9
	assign memaddr = 7 - i;
	assign memaddr2 = 15 - i;
		
	function [7:0] addr_select;
	
		input [7:0]adr;
		input[7:0] mem_status_reg,input_addrreg,input_datareg;
		input denable;
		begin
		
			if (denable==1)
				case(adr[4:0])
					5'b00111 : addr_select = status_reg;
					5'b01000 : addr_select = input_addrreg;
					5'b01001 : addr_select = input_datareg;
					default : addr_select = 8'hxx;
				endcase
			else
			
			addr_select = 8'hxx;
			
			end
			
	endfunction
	
	assign dmemdata2 = addr_select(adr,mem_status_reg,input_addrreg,i2c_input_datareg,denable);
	
	always @(posedge clk) begin

		if(act0 == 1 && denable == 1 && memwrite == 1) mem_status_reg[4] <= writedata[4];
		if(mem_status_reg[4] == 1) begin
			i2c_start = 1;
			mem_status_reg[1] <= 1;
			mem_status_reg[2] <= 1;
		end
		if(status == 6'b0 && i2c_start != 1) begin
		mem_status_reg[1] <= 0;
		mem_status_reg[2] <= 0;
		end
		if(status != 6'b0) begin
		i2c_start = 0;
		mem_status_reg[1] <= 1;
		mem_status_reg[2] <= 1;
		mem_status_reg[4] <= 0;
		end
			
		if(act1 == 1 && denable == 1 && memwrite == 1)mem_input_addrreg <= writedata;
		if(act2 == 1 && denable == 1 && memwrite == 1)mem_input_datareg <= writedata;

		clk_counter <= clk_counter + 1'b1;
		if(clk_counter == 8'b11111111) begin
		i2c_clk <= ~i2c_clk;
		clk_counter <= 8'b00000000;
		end
		
		if(status == 6'd35) begin
		mem_input_addrreg <= 0;
		mem_input_datareg <= 0;
		end	
		
	end
	
	always @(posedge i2c_clk)begin
		if(status == 6'd0 && i2c_start == 1'd1)begin		
			sda_reg = 0;
			i = 0;
			status = 6'd2;
		end else if(status == 6'd2)begin
			scl_reg = 0;
			sda_reg <= input_addrreg[memaddr];
			i = i+1;
			status = 6'd3;
		end else	if(status >= 6'd3 && status <= 6'd9) begin
			scl_reg = ~scl_reg;
				if(scl_reg == 0)begin
					sda_reg <= input_addrreg[memaddr];
				i = i+1;
					status = status + 1;
				end
		end else if(status == 6'd10)begin
			scl_reg = 1;
			i = 0;
			status = 6'd11;
		end else if(status == 6'd11)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd12;
		end else	if(status == 6'd12)begin
			scl_reg = 1;
			status = 6'd13;
		end else if(status == 6'd13 && input_addrreg[0] == 0)begin
//			if(sda == 1) begin
				sda_rw = 1;
				scl_reg= 0;
				sda_reg <= mem_input_datareg[memaddr2];
				i = i+1;
				status = 6'd14;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status == 6'd13 && input_addrreg[0] == 1)begin
//			if(sda == 1) begin
				sda_rw = 0;
				scl_reg= 0;
				status = 6'd14;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status >= 6'd14 && status <= 6'd20 && input_addrreg[0] == 0)begin
						scl_reg = ~scl_reg;
				if(scl_reg == 0)begin
						sda_reg <= mem_input_datareg[memaddr2];
						i = i+1;
						status = status + 1;
					end
		end else if(status >= 6'd14 && status <= 6'd20 && input_addrreg[0] == 1)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 1)begin
						i2c_input_datareg[memaddr] <= sda;
					end else if(scl_reg == 0)begin
						i = i+1;
						status = status + 1;
					end
		end else	if(status == 6'd21 && input_addrreg[0] == 1)begin
			scl_reg = 1;
			i2c_input_datareg[memaddr] <= sda;
			i = 0;
			status = 6'd22;
		end else if(status == 6'd21 && input_addrreg[0] == 0)begin
			scl_reg = 1;
			i = 0;
			status = 6'd22;
		end else if(status == 6'd22)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd23;
		end else	if(status == 6'd23)begin
			scl_reg = 1;
			status = 6'd24;
		end else if(status == 6'd24 && input_addrreg[0] == 0)begin
//			if(sda == 1) begin
				sda_rw = 1;
				scl_reg= 0;
				sda_reg <= mem_input_datareg[memaddr];
				i = i+1;
				status = 6'd25;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status == 6'd24 && input_addrreg[0] == 1)begin
//			if(sda == 1) begin
				sda_rw = 0;
				scl_reg= 0;
				status = 6'd25;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status >= 6'd25 && status <= 6'd31 && input_addrreg[0] == 0)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 0)begin
						sda_reg <= mem_input_datareg[memaddr];
						status = status + 1;
						i = i+1;
					end
		end else	if(status == 6'd32 && i2c_input_addrreg[0] == 0)begin
			scl_reg = 1;
			i = 0;
			status = 6'd33;
		end else if(status >= 6'd25 && status <= 6'd31 && input_addrreg[0] == 1)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 1)begin
						i2c_input_datareg[memaddr] <= sda;
					end else if(scl_reg == 0)begin
						i = i+1;
						status = status + 1;
					end
		end else	if(status == 6'd32 && input_addrreg[0] == 1)begin
			scl_reg = 1;
			i2c_input_datareg[memaddr] <= sda;
			i = 0;
			status = 6'd33;
		end else if(status == 6'd33)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd34;
		end else	if(status == 6'd34)begin
			scl_reg = 1;
			status = 6'd35;
		end else if(status == 6'd35)begin
//			if(sda == 1) begin
				status = 6'd36;
				sda_rw = 1;
				sda_reg <= 1'b0;
				scl_reg = 0;
//			end else begin
//				status = 6'd22;
//				sda_rw = 1;
//			end
		end else if(status == 6'd36)begin
				status = 6'd37;
				scl_reg = 1;
		end else if(status == 6'd37)begin
			sda_reg <= 1'b1;
			i2c_status_reg[1] = 0;
			i2c_status_reg[2] = 0;		
			status = 6'd0;
		end
	end
		
endmodule

module spicntl(clk,adr,writedata,denable,memwrite,scl,sda,csx);
	input			clk,denable;
	input	[31:0]writedata;
	input	[31:0]adr;
	input		memwrite;
	output	reg	scl,sda;
	inout			csx;
	
	reg			[8:0]status_reg;
	reg			[31:0]senddata_reg;
	reg			[7:0]clk_counter;
	wire			act0,act1;
	reg			spi_start,csx_reg,csx_io,spi_clk;
	wire			[6:0]memaddr,memaddr2,memaddr3,memaddr4;
	reg			[8:0]status;
	reg			[6:0]i;
	
	initial begin
	status_reg		<= 8'b0;
	senddata_reg	<=	32'b0;
	clk_counter		<=	7'b0;
	spi_start		<=	1'b0;
	csx_reg			<= 1'b0;
	csx_io			<= 1'b0;
	spi_clk			<=	1'b0;
	status			<=	8'b0;
	i					<= 7'b0;
	scl				<=	1'b0;
	sda				<=	1'b0;
	end
	
	assign csx = (csx_io)?csx_reg:1'bz;
	
	assign act0 = (adr[4:0] == 5'b01010 ); //addr 0xFFFFFFEA
	assign act1 = (adr[4:0] == 5'b01011 ); //addr 0xFFFFFFEB
	assign memaddr = 7 - i;
	assign memaddr2 = 15 - i;
	assign memaddr3 = 23 - i;
	assign memaddr4 = 31 - i;
		
	always @(posedge clk) begin

		if(act0 == 1 && denable == 1 && memwrite == 1) begin
		status_reg[4] <= writedata[4];
		status_reg[5] <= writedata[5];
		status_reg[6] <= writedata[6];
		status_reg[7] <= writedata[7];
		status_reg[8] <= writedata[8];
		end
		
		if(status_reg[4] == 1) begin
			spi_start = 1;
			status_reg[1] = 1;
			status_reg[2] = 1;
		end
		if(status == 6'b0 && spi_start != 1) begin
		status_reg[1] = 0;
		status_reg[2] = 0;
		end
		if(status != 6'b0) begin
		spi_start = 0;
		status_reg[1] = 1;
		status_reg[2] = 1;
		status_reg[4] = 0;
		end
			
		if(act1 == 1 && denable == 1 && memwrite == 1)senddata_reg <= writedata;

		clk_counter <= clk_counter + 1'b1;
		if(clk_counter == 8'b00110010) begin
		spi_clk <= ~spi_clk;
		clk_counter <= 8'b00000000;
		end
		
		if(status == 6'd35) begin
		senddata_reg <= 0;
		end	
		
	end
	
	always @(posedge spi_clk)begin
		scl = ~scl;
		if(status == 6'd0 && spi_start == 1'd1)begin
			csx_reg = 0;
			status = 6'd2;
		end else	if(status >= 6'd2 && status <= 6'd10) begin
			if(clk == 0)begin
					sda <= senddata_reg[memaddr];
					status <= status + 1;
					i <= i + 1;
				end
		end else if(status == 6'd10)begin
			status = 6'd13;
			i <= 0;
			csx_io = 1;
		end else if(status == 6'd13)begin
			if(csx == 0) begin
				csx_io	= 0;
				if(clk == 0)begin
				sda <= senddata_reg[memaddr2];
				i <= i + 1;
				status = 6'd14;
				end
			end
		end else if(status >= 6'd14 && status <= 6'd20)begin
				if(scl == 0)begin
						sda <= senddata_reg[memaddr2];
						i <= i + 1;
						status = status + 1;
				end
		end 
/*		else	if(status == 6'd21 && input_addrreg[0] == 1)begin
			scl_reg = 1;
			i2c_input_datareg[memaddr] <= sda;
			i = 0;
			status = 6'd22;
		end else if(status == 6'd21 && input_addrreg[0] == 0)begin
			scl_reg = 1;
			i = 0;
			status = 6'd22;
		end else if(status == 6'd22)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd23;
		end else	if(status == 6'd23)begin
			scl_reg = 1;
			status = 6'd24;
		end else if(status == 6'd24 && input_addrreg[0] == 0)begin
//			if(sda == 1) begin
				sda_rw = 1;
				scl_reg= 0;
				sda_reg <= mem_input_datareg[memaddr];
//				i++;
				status = 6'd25;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status == 6'd24 && input_addrreg[0] == 1)begin
//			if(sda == 1) begin
				sda_rw = 0;
				scl_reg= 0;
				status = 6'd25;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status >= 6'd25 && status <= 6'd31 && input_addrreg[0] == 0)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 0)begin
						sda_reg <= mem_input_datareg[memaddr];
//						i++;
						status = status + 1;
					end
		end else	if(status == 6'd32 && i2c_input_addrreg[0] == 0)begin
			scl_reg = 1;
			i = 0;
			status = 6'd33;
		end else if(status >= 6'd25 && status <= 6'd31 && input_addrreg[0] == 1)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 1)begin
						i2c_input_datareg[memaddr] <= sda;
					end else if(scl_reg == 0)begin
//						i++;
						status = status + 1;
					end
		end else	if(status == 6'd32 && input_addrreg[0] == 1)begin
			scl_reg = 1;
			i2c_input_datareg[memaddr] <= sda;
			i = 0;
			status = 6'd33;
		end else if(status == 6'd33)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd34;
		end else	if(status == 6'd34)begin
			scl_reg = 1;
			status = 6'd35;
		end else if(status == 6'd35)begin
//			if(sda == 1) begin
				status = 6'd36;
				sda_rw = 1;
				scl_reg = 0;
//			end else begin
//				status = 6'd22;
//				sda_rw = 1;
//			end
		end else if(status == 6'd36)begin
				status = 6'd37;
				scl_reg = 1;
		end else if(status == 6'd37)begin
			sda_reg <= 1'b1;
			i2c_status_reg[1] = 0;
			i2c_status_reg[2] = 0;		
			status = 6'd0;
		end
		*/
	end

endmodule
/*
module spicntl(clk,adr,writedata,denable,memwrite,scl,sda,csx);
	input clk,denable;
	input [31:0]writedata;
	input [31:0]adr;
	input memwrite;
	output scl;
	output sda;
	inout  csx;
	
	wire [7:0]status_reg,input_addrreg;
	wire[15:0]input_datareg;
	reg [7:0]mem_status_reg,mem_input_addrreg;
	reg [31:0]i2c_input_datareg,mem_input_datareg;
	reg [31:0]output_datareg;	
	reg [5:0]status;
	reg scl_reg,sda_reg,csx_reg,csx_io,spi_start,spi_clk,memflashmem,i2cflashmem,outclk;
	
	assign scl = outclk;
	assign sda = sda_reg;
	assign csx = (csx_io)?csx_reg:1'bz;
	
	reg [7:0]clk_counter;
		
	integer i;
	
	wire [5:0] memaddr,memaddr2;
	wire flashmem;
	
	assign status_reg = mem_status_reg;

	initial begin
		status <= 6'b000000;
		mem_status_reg <= 8'b0;
		mem_input_addrreg <= 8'b0;
		mem_input_datareg <= 32'b0;
		scl_reg <= 1;
		sda_reg <= 1;
		i <= 0;
		spi_start <= 0;
		clk_counter <= 8'b00000000;
	end
	//メモ status_regの中身
	//0 R/W設定状?��?��?(0 = W,1 = R)
	//1 通信状?��?��? (1 = 通信中,0 = 通信終�?��?)
	//2 送信レジスタ使用状?��?��?(1 = レジスタ利用中??��?��?��??��信中??��?,0 = レジスタ空(送信済み))
	//3 受信レジスタ使用状?��?��?(1 = レジスタ利用中??��?read?��?��?ータあり??��?,0 = レジスタ空(read?��?��?ータな?��?��?))
	//4 送信?��?��?示(CPUからのレジスタ書き込み終�?��?)
	//5 ?��?��?ータか命令か�??��?��?��?つ1つ?��?��?
	//6 ?��?��?ータか命令か�??��?��?��?つ2つ?��?��?
	//7 ?��?��?ータか命令か�??��?��?��?つ3つ?��?��?
	//8 ?��?��?ータか命令か�??��?��?��?つ4つ?��?��?

	
	wire act0,act1,act2;
	
	assign act0 = (adr[4:0] == 5'b01010 ); //addr 0xFFFFFFEA
	assign act1 = (adr[4:0] == 5'b01011 ); //addr 0xFFFFFFEB
	assign memaddr = 7 - i;
	assign memaddr2 = 15 - i;
		
	function [7:0] addr_select;
	
		input [7:0]adr;
		input[31:0] mem_status_reg,input_addrreg,input_datareg;
		input denable;
		begin
		
			if (denable==1)
				case(adr[4:0])
					5'b01010 : addr_select = status_reg;
					5'b01011 : addr_select = input_addrreg;
					5'b01100 : addr_select = input_datareg;
					default : addr_select = 8'hxx;
				endcase
			else
			
			addr_select = 8'hxx;
			
			end
			
	endfunction
	
	always @(posedge clk) begin

		if(act0 == 1 && denable == 1 && memwrite == 1) begin
		mem_status_reg[4] <= writedata[4];
		mem_status_reg[5] <= writedata[5];
		mem_status_reg[6] <= writedata[6];
		mem_status_reg[7] <= writedata[7];
		mem_status_reg[8] <= writedata[8];
		
		end
		if(mem_status_reg[4] == 1) begin
			spi_start = 1;
			mem_status_reg[1] = 1;
			mem_status_reg[2] = 1;
		end
		if(status == 6'b0 && spi_start != 1) begin
		mem_status_reg[1] = 0;
		mem_status_reg[2] = 0;
		end
		if(status != 6'b0) begin
		spi_start = 0;
		mem_status_reg[1] = 1;
		mem_status_reg[2] = 1;
		mem_status_reg[4] = 0;
		end
			
		if(act2 == 1 && denable == 1 && memwrite == 1)mem_input_datareg <= writedata;

		clk_counter <= clk_counter + 1'b1;
		if(clk_counter == 8'b00110010) begin
		spi_clk <= ~spi_clk;
		clk_counter <= 8'b00000000;
		end
		
		if(status == 6'd35) begin
		mem_input_addrreg <= 0;
		mem_input_datareg <= 0;
		end	
		
	end
	
	always @(posedge spi_clk)begin
		outclk = ~outclk;
		if(status == 6'd0 && spi_start == 1'd1)begin
			csx_reg = 0;
			status = 6'd2;
		end else if(status == 6'd2)begin
			if(outclk == 0) begin
			sda_reg <= mem_status_reg[5];
			status = 6'd3;
			end
		end else	if(status >= 6'd3 && status <= 6'd10) begin
			if(outclk == 0)begin
					sda_reg <= input_addrreg[memaddr];
					status = status + 1;
					i = i + 1;
				end
		end else if(status == 6'd10)begin
			status = 6'd11;
			csx_io = 1;
		end else if(status == 6'd13)begin
			if(csx == 0) begin
				csx_io	= 0;
				if(outclk == 0)begin
				csx_reg <= mem_input_datareg[memaddr2];
				status = 6'd14;
				end
		end else if(status >= 6'd14 && status <= 6'd20)begin
				if(scl_reg == 0)begin
						sda_reg <= mem_states_reg[5];
//						i++;
						status = status + 1;
					end
		end else if(status >= 6'd14 && status <= 6'd20 && input_addrreg[0] == 1)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 1)begin
						i2c_input_datareg[memaddr] <= sda;
					end else if(scl_reg == 0)begin
//						i++;
						status = status + 1;
					end
		end else	if(status == 6'd21 && input_addrreg[0] == 1)begin
			scl_reg = 1;
			i2c_input_datareg[memaddr] <= sda;
			i = 0;
			status = 6'd22;
		end else if(status == 6'd21 && input_addrreg[0] == 0)begin
			scl_reg = 1;
			i = 0;
			status = 6'd22;
		end else if(status == 6'd22)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd23;
		end else	if(status == 6'd23)begin
			scl_reg = 1;
			status = 6'd24;
		end else if(status == 6'd24 && input_addrreg[0] == 0)begin
//			if(sda == 1) begin
				sda_rw = 1;
				scl_reg= 0;
				sda_reg <= mem_input_datareg[memaddr];
//				i++;
				status = 6'd25;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status == 6'd24 && input_addrreg[0] == 1)begin
//			if(sda == 1) begin
				sda_rw = 0;
				scl_reg= 0;
				status = 6'd25;
//			end else begin
//				status = 6'd2;
//				sda_rw = 1;
//			end
		end else if(status >= 6'd25 && status <= 6'd31 && input_addrreg[0] == 0)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 0)begin
						sda_reg <= mem_input_datareg[memaddr];
//						i++;
						status = status + 1;
					end
		end else	if(status == 6'd32 && i2c_input_addrreg[0] == 0)begin
			scl_reg = 1;
			i = 0;
			status = 6'd33;
		end else if(status >= 6'd25 && status <= 6'd31 && input_addrreg[0] == 1)begin
					scl_reg = ~scl_reg;
					if(scl_reg == 1)begin
						i2c_input_datareg[memaddr] <= sda;
					end else if(scl_reg == 0)begin
//						i++;
						status = status + 1;
					end
		end else	if(status == 6'd32 && input_addrreg[0] == 1)begin
			scl_reg = 1;
			i2c_input_datareg[memaddr] <= sda;
			i = 0;
			status = 6'd33;
		end else if(status == 6'd33)begin
			scl_reg = 0;
			sda_rw = 0;
			status = 6'd34;
		end else	if(status == 6'd34)begin
			scl_reg = 1;
			status = 6'd35;
		end else if(status == 6'd35)begin
//			if(sda == 1) begin
				status = 6'd36;
				sda_rw = 1;
				scl_reg = 0;
//			end else begin
//				status = 6'd22;
//				sda_rw = 1;
//			end
		end else if(status == 6'd36)begin
				status = 6'd37;
				scl_reg = 1;
		end else if(status == 6'd37)begin
			sda_reg <= 1'b1;
			i2c_status_reg[1] = 0;
			i2c_status_reg[2] = 0;		
			status = 6'd0;
		end
	end
	end
		
endmodule


module ps2kbcntl(clk,adr,writedata,denable,memwrite,dmemdata,ps2clk,ps2data,irq);
	input clk,denable;
	input [31:0]writedata;
	input [15:0]adr;
	input memwrite;
	output [31:0]dmemdata;
	output irq;
	inout ps2clk;
	inout ps2data;
	
	wire [7:0]status_reg,input_addrreg;
	wire[15:0]input_datareg;
	reg [7:0]ps2kb_status_reg;
	reg [7:0]mem_status_reg,mem_input_addrreg;
	reg [31:0]ps2kb_input_datareg,mem_input_datareg;
	reg [31:0]output_datareg;	
	reg [5:0]status,rstatus;
	reg [13:0]clk_counter;
	reg ps2clk_reg,ps2data_reg,clk_rw,data_rw,ps2_start,memflashmem,i2cflashmem;
	
	assign ps2clk = (clk_rw)?ps2clk_reg:1'bz;
	assign ps2data = (data_rw)?ps2data_reg:1'bz;
	
//	reg [7:0]clk_counter;
		
	integer i;
	wire [5:0] memaddr,memaddr2;
	wire flashmem;
	
	assign input_datareg = ps2kb_input_datareg;

	initial begin
		status <= 6'b000000;
		ps2clk_reg <= 1;
		ps2data_reg <= 1;
		clk_rw <= 0;
		data_rw <= 0;
		i <= 0;
		clk_counter <= 13'b0;
	end
	//メモ status_regの中身
	//0 R/W設定状?��?��?(0 = W,1 = R)
	//1 通信状?��?��? (1 = 通信中,0 = 通信終�?��?)
	//2 送信レジスタ使用状?��?��?(1 = レジスタ利用中??��?��?��??��信中??��?,0 = レジスタ空(送信済み))
	//3 受信レジスタ使用状?��?��?(1 = レジスタ利用中??��?read?��?��?ータあり??��?,0 = レジスタ空(read?��?��?ータな?��?��?))
	//4 送信?��?��?示(CPUからのレジスタ書き込み終�?��?)
	//5-7 今�??��ところ未使用
	
	wire act0,act1,act2;
	
	assign act0 = (adr[4:0] == 5'b01010 ); //addr 0xFFEA
	assign act1 = (adr[4:0] == 5'b01011 ); //addr 0xFFEB
	assign act2 = (adr[4:0] == 5'b01100 ); //addr 0xFFEC
	assign memaddr = 7 - i;
	assign memaddr2 = 15 - i;
	
	always @(posedge clk) begin
			if(act0 == 1 && denable == 1 && memwrite == 1) mem_status_reg[4] <= writedata[4];
		if(mem_status_reg[4] == 1) begin
			ps2_start = 1;
			mem_status_reg[1] = 1;
			mem_status_reg[2] = 1;
		end
		if(status == 6'b0 && ps2_start != 1) begin
		mem_status_reg[1] = 0;
		mem_status_reg[2] = 0;
		end
		if(status != 6'b0) begin
		ps2_start = 0;
		mem_status_reg[1] = 1;
		mem_status_reg[2] = 1;
		mem_status_reg[4] = 0;
		end
			
		if(act1 == 1 && denable == 1 && memwrite == 1)mem_input_datareg <= writedata;
	
		if(status == 6'd4) begin
		mem_input_datareg <= 0;
		end
		
		if(irq == 1 && act1 == 1 && denable == 1 && memwrite == 0)begin
//		dmemdata <= ps2kb_input_datareg;
		//irq = 0;
	
		if(ps2_start == 1 && status == 0)begin
		//clk_rw = 1;
		ps2clk_reg = 0;
		status = 1;
		ps2_start = 0;
		end else if(status == 1) begin
		clk_counter = clk_counter + 1;
			if(clk_counter >= 13'h1400)begin
			status = 2;
			end
		end else if(status == 2) begin
		data_rw = 1;
		ps2data_reg = 0;
		status = 3;
		end else if(status == 3) begin
		ps2clk_reg = 0;
		//clk_rw = 0;
		wait(ps2clk == 0);
		ps2data_reg = 1;
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[7];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[6];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[5];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[4];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[3];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[2];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[1];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = mem_input_datareg[0];
		wait(ps2clk == 1);
		wait(ps2clk == 0);
//		ps2data_reg = paritydata;
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		ps2data_reg = 0;
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		status = 4;
		end else if(status == 4)begin
		status = 0;
		end
		
	if(clk == 0 && status == 0)begin
		ps2clk_reg = 0;
		rstatus = 1;
	end else if(rstatus == 1) begin
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[7] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[6] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[5] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[4] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[3] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[2] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[1] = ps2data;
		wait(ps2clk == 0);
		wait(ps2clk == 1);
		ps2kb_input_datareg[0] = ps2data;
		wait(ps2clk == 0);
		rstatus = 0;
//		irq = 1;
		end
		
	end
	
	end


endmodule

*/
