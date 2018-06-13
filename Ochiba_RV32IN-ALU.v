module ALU #(parameter WIDTH=32)
           (input clk,reset,ExREGclear,
			   input [4:0]REGRrd,
				input [WIDTH-1:0]REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg2data,
				input [1:0]REGRregfwda,REGRregfwdb,REGRmem2reg,
				input [1047:0]REGRsrc1_512,REGRsrc2_512,REGRreg2data_512,
				input [3:0]REGRalucont,
				input [1:0]REGRpcsource,
				input [2:0]REGRllcntl,REGRslcntl,
				input REGRalusel,
				input [1:0]REGRbranchcntl,
				input REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,
				input [11:0]REGRcsraddr,
				input [1:0]REGRbpflag,
				input REGRflag512,REGRnwstore,
				output [4:0]REGArd,
				output [WIDTH-1:0]REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,
				output [1047:0]REGAaluresult_512,REGAreg2data_512,
				output [1:0]REGAmem2reg,
				output [1:0]REGApcsource,
				output [2:0]REGAllcntl,REGAslcntl,
				output [1:0]REGAbranchcntl,
				output REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,
				output [11:0]REGAcsraddr,
				output [1:0]REGAbpflag,
				output REGAflag512,REGAnwstore,
				input  ExREGstall,
				output Exnow);
				
				wire [WIDTH-1:0] /*aluresult,*/fwdreg1,fwdreg2,fwdreg3,aluasrc,alubsrc,aludata1,aludata2,muldivdata1,muldivdata2,calresult,muldivresult,fwdreg2data;
				wire [3:0]alucont,muldivcont;
				wire [1047:0] aluresult_512,fwdreg_512_1,fwdreg_512_2,fwdreg_512_3,aluasrc_512,alubsrc_512,fwdreg2data_512;
				
				assign Exnow = 1'b0;
				
//				alucntl     alucntl(REGRalusel,aluasrc,alubsrc,REGRalucont,aludata1,aludata2,alucont,muldivdata1,muldivdata2,muldivcont);
				alu			alu(aluasrc,alubsrc,REGRalucont,calresult);
				alu_512		alu512(aluasrc_512,alubsrc_512,REGRalucont,aluresult_512);
//				alu			muldiv(muldivdata1,muldivdata2,muldivcont,muldivresult);
//				calcntl     calcntl(REGRalusel,aluresult,muldivresult,calresult);
				mux4			fwdregmuxa(REGRalua,fwdreg1,fwdreg2,fwdreg3,REGRregfwda,aluasrc);
				mux4			fwdregmuxb(REGRalub,fwdreg1,fwdreg2,fwdreg3,REGRregfwdb,alubsrc);
				mux4			fwdregmuxstore(REGRreg2data,fwdreg1,fwdreg2,fwdreg3,REGRregfwdb,fwdreg2data);
				mux4_512	    fwdregmuxa_512(REGRsrc1_512,fwdreg_512_1,fwdreg_512_2,fwdreg_512_3,REGRregfwda,aluasrc_512);
                mux4_512     fwdregmuxb_512(REGRsrc2_512,fwdreg_512_1,fwdreg_512_2,fwdreg_512_3,REGRregfwdb,alubsrc_512);
	            mux4_512     fwdregmuxstore_512(REGRreg2data_512,fwdreg_512_1,fwdreg_512_2,fwdreg_512_3,REGRregfwdb,fwdreg2data_512);			
					
				//3„Çµ„Ç§„ÇØ„É´„Çµ„Ç§„ÇØ„É´??øΩ?øΩ??øΩ?øΩ?„ÅÆÊºîÁÆóÁµêÊûú„ÇíÁΩÆ??øΩ?øΩ??øΩ?øΩ?„Å¶„Åä„Åè??øΩ?øΩ??øΩ?øΩ?„Éº„Çø„É¨„Ç∏„Çπ„Çø	
				ffr fwdregister1		(clk,ExREGclear,ExREGstall,calresult,fwdreg1);
				ffr fwdregister2        (clk,ExREGclear,ExREGstall,fwdreg1,fwdreg2);
				ffr fwdregister3        (clk,ExREGclear,ExREGstall,fwdreg2,fwdreg3);
				
				ffr512 fwdregister1_512		(clk,ExREGclear,ExREGstall,aluresult_512,fwdreg_512_1);
            ffr512 fwdregister2_512        (clk,ExREGclear,ExREGstall,fwdreg_512_1,fwdreg_512_2);
            ffr512 fwdregister3_512        (clk,ExREGclear,ExREGstall,fwdreg_512_2,fwdreg_512_3);
						
				//„Åì„Åì„Åã„Çâ‰∏ãÔøΩ???øΩ?øΩ?øΩ?øΩ?„Éº„Çø„Éë„Çπ
					ffr5 REGrd         (clk,ExREGclear,ExREGstall,REGRrd,REGArd);
					ffr  REGaluresult  (clk,ExREGclear,ExREGstall,calresult,REGAaluresult);
					ffr512  REGaluresult_512  (clk,ExREGclear,ExREGstall,aluresult_512,REGAaluresult_512);
					ffr  REGbranchimm  (clk,ExREGclear,ExREGstall,REGRbranchimm,REGAbranchimm);
					ffr  REGpc         (clk,ExREGclear,ExREGstall,REGRpc,REGApc);
					ffr  REGreg2       (clk,ExREGclear,ExREGstall,fwdreg2data,REGAreg2data);
					ffr512 REGreg2_512  (clk,ExREGclear,ExREGstall,fwdreg2data_512,REGAreg2data_512);
				//„Åì„Åì„Åæ„Åß
				
				//„Åì„Åì„Åã„Çâ‰∏ãÔøΩ???øΩ?øΩ?øΩ?øΩ?„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?Âá∫??øΩ?øΩ??øΩ?øΩ?	
					ffr2 REGmem2reg  (clk,ExREGclear,ExREGstall,REGRmem2reg,REGAmem2reg);
					ffr1 REGregwrite (clk,ExREGclear,ExREGstall,REGRregwrite,REGAregwrite);
					ffr2 REGpcsource (clk,ExREGclear,ExREGstall,REGRpcsource,REGApcsource);
					ffr1 REGiord     (clk,ExREGclear,ExREGstall,REGRiord,REGAiord);
					ffr3 REGllcntl   (clk,ExREGclear,ExREGstall,REGRllcntl,REGAllcntl);
					ffr3 REGslcntl   (clk,ExREGclear,ExREGstall,REGRslcntl,REGAslcntl);
					ffr2 REGbrcntl   (clk,ExREGclear,ExREGstall,REGRbranchcntl,REGAbranchcntl);
					ffr1 wenable     (clk,ExREGclear,ExREGstall,REGRwenable,REGAwenable);
					ffr1  REGcsrrw   (clk,ExREGclear,ExREGstall,REGRcsrrw,REGAcsrrw);
					ffr12 REGcsraddr (clk,ExREGclear,ExREGstall,REGRcsraddr,REGAcsraddr);
					ffr2  REGbpflag  (clk,ExREGclear,ExREGstall,REGRbpflag,REGAbpflag);
					ffr1  REGflag512 (clk,ExREGclear,ExREGstall,REGRflag512,REGAflag512);
					ffr1  REGnwstore (clk,ExREGclear,ExREGstall,REGRnwstore,REGAnwstore);
				//„Åì„Åì„Åæ„Åß
				
				
endmodule

module alucntl(input alusel,
					input [31:0]data1,data2,
					input [3:0]cont,
					output [31:0]aludata1,aludata2,
					output [3:0]alucont,
					output [31:0]muldivdata1,muldivdata2,
					output [3:0]muldivcont);
					
				assign aludata1    = alusel ? 32'b0 : data1;
				assign muldivdata1 = alusel ? data1 : 32'b0;
				assign aludata2    = alusel ? 32'b0 : data2;
				assign muldivdata2 = alusel ? data2 : 32'b0;
				assign alucont     = alusel ? 4'b0  : cont;
			   assign muldivcont  = alusel ? cont  : 4'b0;
				
endmodule

module calcntl(input alusel,
					input [31:0]aluresult,muldivresult,
					output [31:0]calresult);
					
				assign calresult    = alusel ? muldivresult : aluresult;
				
endmodule

module alu #(parameter WIDTH = 32)
				(input		[WIDTH-1:0]	a, b,
				input			[3:0]			alucont,
				output		[WIDTH-1:0]	result);
				
			wire   [4:0]shamt = b[4:0];
			assign result = alu(a,b,alucont,shamt);

	function [31:0]alu;
		input [31:0]in1;
		input [31:0]in2;
		input [3:0]	alucont;
		input [4:0] shamt;
		
		begin
				case(alucont[3:0])
					4'b0000:	alu	=	in1 & in2; //a AND b
					4'b0001:	alu	=	in1 | in2;	//a OR b
					4'b0010:	alu	=	in1 ^ in2; //a XOR b
					4'b0011:	alu	=	in1 + in2;	//a ADD b
					4'b0100:	alu	=	in1 - in2; //a SUB b
					4'b0101:	alu	=	{31'b0, $signed(in1) < $signed(in2)};	//slt	
					4'b0110:	alu	=	{31'b0, in1 < in2};	//sltu
					4'b0111:	alu	=	in1 << shamt;	//sll	
					4'b1000:	alu	=	in1 >> shamt;	//srl
					4'b1001:	alu	=	$signed(in1) >>> shamt;	//sra
					4'b1010:	alu	=	~(a | (~b));	//„Éì„ÉÉ„ÉàÔøΩ???øΩ?øΩ„ÇØ„É™„Ç¢
				   4'b1011: alu	=  {31'b0, $signed(in1) >= $signed(in2)};//sge
					4'b1100: alu	=  {31'b0, in1 >= in2};//sgeu
					4'b1101: alu   =  {31'b0, in1 == in2};//seq
					4'b1110: alu   =  {31'b0, in1 != in2};//sne
				
					default:	alu =	0;		//Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?
				endcase
		end
	endfunction
			
endmodule

module alu_512 
				(input		[1047:0]	a, b,
				input			[3:0]			alucont,
				output		[1047:0]	result);
				
			wire   [7:0]shamt = b[7:0];
			assign result = alu_512(a,b,alucont,shamt);

	function [1047:0]alu_512;
		input [1047:0]in1;
		input [1047:0]in2;
		input [1047:0]	alucont;
		input [7:0] shamt;
		
		begin
				case(alucont[3:0])
					4'b0000:	alu_512	=	in1 & in2; //a AND b
					4'b0001:	alu_512	=	in1 | in2;	//a OR b					4'b0010:	alu_512	=	in1 ^ in2; //a XOR b
					4'b0011:	alu_512	=	in1 + in2;	//a ADD b
					4'b0100:	alu_512	=	in1 - in2; //a SUB b
					4'b0101:	alu_512	=	{1047'b0, $signed(in1) < $signed(in2)};	//slt	
					4'b0110:	alu_512	=	{1047'b0, in1 < in2};	//sltu
					4'b0111:	alu_512	=	in1 << shamt;	//sll	
					4'b1000:	alu_512	=	in1 >> shamt;	//srl
					4'b1001:	alu_512	=	$signed(in1) >>> shamt;	//sra
					4'b1010:	alu_512	=	~(a | (~b));	//„Éì„ÉÉ„ÉàÔøΩ???øΩ?øΩ„ÇØ„É™„Ç¢
				    4'b1011: alu_512	=  {1047'b0, $signed(in1) >= $signed(in2)};//sge
					4'b1100: alu_512	=  {1047'b0, in1 >= in2};//sgeu
					4'b1101: alu_512   =  {1047'b0, in1 == in2};//seq
					4'b1110: alu_512   =  {1047'b0, in1 != in2};//sne				
					default:	alu_512 =	1048'b0;		//Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?
				endcase
		end
	endfunction
			
endmodule

