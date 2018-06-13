//-------------------------------------------------------
//
// Ochiba_RV32IM-cont.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IM
//
// Ochiba Processer RV32IM model
// System Control Register
//
//-------------------------------------------------------

module sysreg (input					clk,csrrw,rst,
					input 	[11:0]	csraddr,
					input		[31:0]	csrindata,
					output	[31:0]	csroutdata);
					
			wire			s,csrenable,denable,renable;
			wire[31:0]	dataselect;
			
			wire[31:0]		cycl,cych,secl,sech,wd,rd;
				
			assign s = (csraddr[11:10] == 2'b11);
			assign denable = s ? 1'b1 : 1'b0;
			assign renable = s ? 1'b0 : 1'b1;
			assign csrenable = s & csrrw;
			assign dataselect	=	switch(csraddr,cycl,cych,secl,sech,rd);
			assign csroutdata	=	dataselect;
			assign wd			=	csrindata;
			
				
			csrreg			csr(clk,csrenable,csraddr,wd,rd);
			counter			cycle_counter(clk,rst,cycl,cych);
			counter_sec		sec_counter(clk,rst,secl,sech);
			
			function [31:0] switch;
				input 		[11:0]	csraddr;
				input			[31:0]	cycl,cych,secl,sech,rd;

				begin
					case(csraddr)
						12'hc00:switch = cycl;			
						12'hc01:switch = secl;
					
						12'hc80:switch = cych;
						12'hc81:switch = sech;				
						default:	switch = rd;
					endcase
				
				end
	endfunction

					
endmodule

module csrreg #(parameter WIDTH = 32)	//レジスタ WIDTH変更で��?変更可能
						(input					clk,regwrite,
						input		[11:0]			sraddr,
						input		[WIDTH-1:0] wd,
						output	[WIDTH-1:0]	rd);
						
		reg	[WIDTH-1:0]REG[4095:0];
		
	
		always @(negedge clk)
			if(regwrite) REG[sraddr] <= wd;
			
		assign rd = REG[sraddr];	//レジスタの値を返す

		
endmodule

module counter(input					clk,reset,
					output	[31:0]	counterl,
					output	[31:0]	counterh);
					
			reg[63:0] clk_counter;
			always @(posedge clk)clk_counter = clk_counter + 1;
			
			assign	counterl	=	clk_counter[31:0];
			assign	counterh	=	clk_counter[63:32];
			
			
endmodule

module counter_sec(input	clk,reset,
					output	[31:0]	counterl,
					output	[31:0]	counterh);
					
			reg[63:0] clk_counter;
			reg[63:0] clk_counter_sec;
			
			always @(posedge clk)
			begin
				clk_counter = clk_counter + 1;
				if(clk_counter == 63'h2FAF080)
				begin
				clk_counter_sec	= clk_counter_sec + 1;
				clk_counter			= 64'b0;
				end
			end
			
			assign	counterl	=	clk_counter[31:0];
			assign	counterh	=	clk_counter[63:32];
			
endmodule

