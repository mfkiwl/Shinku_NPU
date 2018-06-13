//-------------------------------------------------------
//
// Ochiba_RV32IN-dp.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IN
//
// Ochiba Processer RV32IN model
// Datapath and Pipeline
//
//-------------------------------------------------------

module Ochiba_RV32IN_dp #(parameter WIDTH = 32)
						(input 			clk,reset,
						 input [WIDTH-1:0]	instrmemdata,
						 output [WIDTH-1:0] instraddress,
                         output [WIDTH-1:0]dmemwdata,
                         output [1047:0]dmemwdata_512,
                         output [WIDTH-1:0]dmemaddr,
                         output [2:0] rcntl,wcntl,
                         output wenable,
                         input  [WIDTH-1:0]dmemrdata,
                        input  [1047:0]dmemrdata512,
						 output[11:0]			csraddr,
						 output[WIDTH-1:0]	csroutputdata,
						 input[WIDTH-1:0]		csrreaddata,
						 output              csrwe,
						 input              IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,
						 output          Exnow,branch,branchpd,
						 input            rxfifoemp,
						 output          fiforeaden,
						 input  [1047:0]  fiforeaddata,
						 output          fifowren,
						 output [1047:0]  fifowrdata);
						 	
	wire	[4:0]		    REGDrs1,REGDrs2,REGDrd,REGRrd,ra1,ra2,REGArd,REGMrd,regaddr;
	wire	[31:0]	    imm,branchimm,storeimm,jimm,luiimm,csrimm;
	wire [WIDTH-1:0]   pc, nextpc,dnextpc, md, rd1, rd2, wd, a, src1, src2, aluresult,
                      aluout, constx4,pcbranch,lcmemdata,REGFfetchdata,REGFpc,REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,
							 REGDpc,REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg1data,REGRreg2data,regwd,REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,
							 REGMaluresult,REGMbranchimm,REGMpc,REGMreg1data,REGMreg2data,REGMdmemdata,REGMcsrrdata,branchpdaddr,nwsaddr;
	wire              REGDiord,REGRiord,REGAiord,regwe,REGDalusel,REGRalusel,REGDregwrite,REGDwenable,REGDcsrrw,REGRregwrite,REGRwenable,REGRcsrrw,REGAwenable,
							REGAregwrite,REGAcsrrw,REGMregwrite,REGMzero,pcwrcntl,branchpdans,regwrite512,reg512_norm_we,REGDflag512,REGRflag512,REGAflag512,REGMflag512,
							REGDnwstore,REGRnwstore,REGAnwstore,REGDnwload,nwres;
	wire  [1:0]        REGDregfwda,REGDregfwdb,REGRregfwda,REGRregfwdb,REGDalusrca,REGDmem2reg,REGDpcsource,REGRmem2reg,REGRpcsource,REGAmem2reg,
	                   REGApcsource,REGMmem2reg,REGMpcsource,REGDbpflag,REGRbpflag,REGAbpflag,REGMbpflag;
	wire  [2:0]        REGDllcntl,REGDslcntl,REGRllcntl,REGRslcntl,REGAllcntl,REGAslcntl;
	wire	[1:0]			REGDbranchcntl,REGRbranchcntl,REGAbranchcntl,REGMbranchcntl,branchpdres,REGDalusrca_512,REGDalusrcb_512;
	wire  [3:0]        REGDalusrcb,REGDalucont,REGRalucont,ra1_512,ra2_512,rd_512;
	wire  [11:0]       REGDcsraddr,REGRcsraddr,REGAcsraddr;
	wire  [1047:0]      wd512,rd512,wd_512,rd1_512,rd2_512,normalreg_rd512,REGRsrc1_512,REGRsrc2_512,REGRreg2data_512,REGAaluresult_512,REGAreg2data_512,REGMaluresult_512,REGMdmemdata_512;
	assign branch = pcwrcntl;
	assign branchpd = branchpdans; 
	
            		 			
	FETCH          IF(clk,reset,IFREGclear,pcbranch,pcwrcntl,instraddress,instrmemdata,REGFfetchdata,REGFpc,branchpdaddr,branchpdans,nwsaddr,nwres,IFREGstall);

	DECODE         ID(clk,reset,IDREGclear,REGFfetchdata,REGFpc,
	               REGDrs1,REGDrs2,REGDrd,REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,REGDregfwda,REGDregfwdb,REGDalusrca,
                  REGDalusrcb,REGDmem2reg,REGDalucont,REGDpcsource,REGDiord,REGDllcntl,REGDslcntl,REGDalusel,REGDbranchcntl,REGDregwrite,REGDwenable,REGDcsrrw,REGDcsraddr,REGDbpflag,REGDflag512,REGDnwload,REGDnwstore,IDREGstall,branchpdres,
						branchpdaddr,branchpdans,rxfifoemp,nwsaddr,nwres);
 
   REGISTERFILE   RF(clk,RFREGclear,REGDrs1,REGDrs2,REGDrd,REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,REGDregfwda,REGDregfwdb,REGDalusrca,REGDalusrcb,
					   REGDmem2reg,REGDalucont,REGDpcsource,REGDiord,REGDllcntl,REGDslcntl,REGDalusel,REGDbranchcntl,REGDregwrite,REGDwenable,REGDcsrrw,REGDcsraddr,REGDbpflag,REGDflag512,REGDnwload,REGDnwstore,REGRrd,REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg2data,
					   REGRregfwda,REGRregfwdb,REGRmem2reg,REGRsrc1_512,REGRsrc2_512,REGRreg2data_512,REGRalucont,REGRpcsource,REGRllcntl,REGRslcntl,REGRalusel,REGRbranchcntl,REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,REGRcsraddr,REGRbpflag,REGRflag512,REGRnwstore,ra1,ra2,ra1_512,ra2_512,rd1,rd2,normalreg_rd512,rd1_512,rd2_512,fiforeaden,fiforeaddata,RFREGstall);

	ALU            Ex(clk,reset,ExREGclear,REGRrd,REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg2data,REGRregfwda,REGRregfwdb,REGRmem2reg,REGRsrc1_512,REGRsrc2_512,REGRreg2data_512,REGRalucont,REGRpcsource,REGRllcntl,REGRslcntl,REGRalusel,REGRbranchcntl,REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,
                      REGRcsraddr,REGRbpflag,REGRflag512,REGRnwstore,REGArd,REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,REGAaluresult_512,REGAreg2data_512,REGAmem2reg,REGApcsource,REGAllcntl,REGAslcntl,REGAbranchcntl,REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,REGAcsraddr,REGAbpflag,REGAflag512,REGAnwstore,ExREGstall,Exnow);

   MEMORYACCESS   MA(clk,MAREGclear,REGArd,REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,REGAaluresult_512,REGAreg2data_512,REGAmem2reg,REGApcsource,REGAllcntl,REGAslcntl,REGAbranchcntl,REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,REGAcsraddr,REGAbpflag,REGAflag512,REGAnwstore,REGMrd,
				      REGMaluresult,REGMbranchimm,REGMpc,REGMaluresult_512,REGMmem2reg,REGMpcsource,REGMbranchcntl,REGMregwrite,REGMzero,REGMdmemdata,REGMcsrrdata,REGMdmemdata_512,REGMbpflag,REGMflag512,dmemwdata,dmemwdata_512,dmemaddr,rcntl,wcntl,wenable,dmemrdata,dmemrdata512,csrreaddata,csroutputdata,csraddr,csrwe,fifowrdata,fifowren,MAREGstall);

	WRITEBACK      WB(REGMrd,REGMaluresult,REGMbranchimm,REGMpc,REGMaluresult_512,REGMmem2reg,REGMpcsource,REGMbranchcntl,REGMregwrite,REGMzero,
				      REGMdmemdata,REGMcsrrdata,REGMdmemdata_512,REGMbpflag,REGMflag512,regaddr,regwd,regwe,rd_512,wd_512,regwrite512,reg512_norm_we,pcbranch,pcwrcntl,branchpdres);

	regfile 		REGISTER(clk,regwe,ra1,ra2,regaddr,wd_512,reg512_norm_we,regwd,rd1,rd2,normalreg_rd512);
	regfile_512     REGISTER512(clk,regwrite512,ra1_512,ra2_512,rd_512,wd_512,rd1_512,rd2_512);


endmodule

module aluplus	#(parameter WIDTH = 32)
					(input	[WIDTH-1:0]a,b,
					output	[WIDTH-1:0]result);
					
			assign result = a + b;
			
endmodule


module regfile #(parameter WIDTH = 32)	//„É¨„Ç∏„Çπ„Çø WIDTHÂ§âÊõ¥„Åß????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?Â§âÊõ¥ÂèØËÉΩ
						(input					clk,regwrite,
						input		[4:0]			ra1,ra2,rd,
						input       [1047:0]    wd512,
						input      we512,
						input		[WIDTH-1:0] wd,
						output	[WIDTH-1:0]	rd1,rd2,
						output  [1047:0]rd512);
						
		reg	[WIDTH-1:0]REG[31:0];
		
		initial begin
		REG[1] = 32'b0;
		REG[2] = 32'b0;
		REG[3] = 32'b0;
		REG[4] = 32'b0;
		REG[5] = 32'b0;
		REG[6] = 32'b0;
		REG[7] = 32'b0;
		REG[8] = 32'b0;
		REG[9] = 32'b0;
		REG[10] = 32'b0;
		REG[11] = 32'b0;
		REG[12] = 32'b0;
		REG[13] = 32'b0;
		REG[14] = 32'b0;
		REG[15] = 32'b0;
		REG[16] = 32'b0;
		REG[17] = 32'b0;
		REG[18] = 32'b0;
		REG[19] = 32'b0;
		REG[20] = 32'b0;
		REG[21] = 32'b0;
		REG[22] = 32'b0;
		REG[23] = 32'b0;
		REG[24] = 32'b0;
		REG[25] = 32'b0;
		REG[26] = 32'b0;
		REG[27] = 32'b0;
		REG[28] = 32'b0;
		REG[29] = 32'b0;
		REG[30] = 32'b0;
		REG[31] = 32'b0;
		end
		
		//„É¨„Ç∏„Çπ„Çø„ÅÆ‰∏≠Ë∫´„Çí„Ç∑„Éü„É•„É¨„Éº„Ç∑„Éß„É≥„ÅßË¶ã„Çã„Åü„ÇÅ„ÅÆ„Åä„Åæ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
		wire [31:0] REG0,REG1,REG2,REG3,REG4,REG5,REG6,REG7,REG8,REG9,REGa,REGb,REGc,REGd,REGe,REGf,REG10,REG11,REG12,REG13,REG14,REG15;
		assign	REG0	= REG[0];
		assign	REG1	= REG[1];
		assign	REG2	= REG[2];
		assign	REG3	= REG[3];
		assign	REG4	= REG[4];
		assign	REG5	= REG[5];
		assign	REG6	= REG[6];
		assign	REG7	= REG[7];
		assign	REG8	= REG[8];
		assign	REG9	= REG[9];
		assign	REGa	= REG[10];
		assign	REGb	= REG[11];
		assign	REGc	= REG[12];
		assign	REGd	= REG[13];
		assign	REGe	= REG[14];
		assign	REGf	= REG[15];
		assign	REG10	= REG[16];
		assign	REG11	= REG[17];
		assign	REG12	= REG[18];
		assign	REG13	= REG[19];
		assign	REG14	= REG[20];
		assign	REG15 = REG[21];
		
		always @(posedge clk) begin
			if(regwrite) REG[rd] <= wd;	//rd„ÅÆÁï™Âú∞„ÅÆ„É¨„Ç∏„Çπ„Çø„Å´wd„ÇíÊõ∏????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
			if(we512) begin
			 REG[16] <= wd512[31:0];
			 REG[17] <= wd512[63:32];
			 REG[18] <= wd512[95:64];
			 REG[19] <= wd512[127:96];
			 REG[20] <= wd512[159:128];
			 REG[21] <= wd512[191:160];
			 REG[22] <= wd512[223:192];
			 REG[23] <= wd512[255:224];
			 REG[24] <= wd512[287:256];
			 REG[25] <= wd512[319:288];
			 REG[26] <= wd512[351:320];
			 REG[27] <= wd512[383:352];
			 REG[28] <= wd512[415:384];
			 REG[29] <= wd512[447:416];
			 REG[30] <= wd512[479:448];
			 REG[31] <= wd512[511:480];
			 end			 
		end
			
		assign rd1 = ra1	?	REG[ra1] :	32'b0;	//0‰ª•Â§ñ„Å™„Çâ„Åù„ÅÆ„É¨„Ç∏„Çπ„Çø„ÅÆÂÄ§„ÇíÔøΩ??0„Å™„Çâ„Çº„É≠„ÇíËøî„Åô
		assign rd2 = ra2	?	REG[ra2] :	32'b0;
		assign rd512[1031:512] = 520'b0;
		assign rd512[31:0] = REG[16];
		assign rd512[63:32] = REG[17];
		assign rd512[95:64] = REG[18];
		assign rd512[127:96] = REG[19];
		assign rd512[159:128] = REG[20];
		assign rd512[191:160] = REG[21];
		assign rd512[223:192] = REG[22];
		assign rd512[255:224] = REG[23];
		assign rd512[287:256] = REG[24];
		assign rd512[319:288] = REG[25];
		assign rd512[351:320] = REG[26];
		assign rd512[383:352] = REG[27];
		assign rd512[415:384] = REG[28];
		assign rd512[447:416] = REG[29];
		assign rd512[479:448] = REG[30];
		assign rd512[511:480] = REG[31];
		

		
endmodule

module regfile_512 #(parameter WIDTH = 32)	//„É¨„Ç∏„Çπ„Çø WIDTHÂ§âÊõ¥„Åß????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?Â§âÊõ¥ÂèØËÉΩ
						(input					clk,regwrite,
						input		[3:0]			ra1,ra2,rd,
						input		[1047:0] wd,
						output	[1047:0]	rd1,rd2);
						
		reg	[1047:0]REG[15:0];
		
		initial begin
		REG[0] = 1048'b0;
		REG[1] = 1048'b0;
		REG[2] = 1048'b0;
		REG[3] = 1048'b0;
		REG[4] = 1048'b0;
		REG[5] = 1048'b0;
		REG[6] = 1048'b0;
		REG[7] = 1048'b0;
		REG[8] = 1048'b0;
		REG[9] = 1048'b0;
		REG[10] = 1048'b0;
		REG[11] = 1048'b0;
		REG[12] = 1048'b0;
		REG[13] = 1048'b0;
		REG[14] = 1048'b0;
		REG[15] = 1048'b0;
		REG[0] = 1048'b0;
		end
		
		//„É¨„Ç∏„Çπ„Çø„ÅÆ‰∏≠Ë∫´„Çí„Ç∑„Éü„É•„É¨„Éº„Ç∑„Éß„É≥„ÅßË¶ã„Çã„Åü„ÇÅ„ÅÆ„Åä„Åæ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
		wire [1047:0] REG512_0,REG512_1,REG512_2,REG512_3,REG512_4,REG512_5,REG512_6,REG512_7,REG512_8,REG512_9,REG512_a,REG512_b,REG512_c,REG512_d,REG512_e,REG512_f;
		assign	REG512_0	= REG[0];
		assign	REG512_1	= REG[1];
		assign	REG512_2	= REG[2];
		assign	REG512_3	= REG[3];
		assign	REG512_4	= REG[4];
		assign	REG512_5	= REG[5];
		assign	REG512_6	= REG[6];
		assign	REG512_7	= REG[7];
		assign	REG512_8	= REG[8];
		assign	REG512_9	= REG[9];
		assign	REG512_a	= REG[10];
		assign	REG512_b	= REG[11];
		assign	REG512_c	= REG[12];
		assign	REG512_d	= REG[13];
		assign	REG512_e	= REG[14];
		assign	REG512_f	= REG[15];

		
		always @(posedge clk)
			if(regwrite) REG[rd] <= wd;	//rd„ÅÆÁï™Âú∞„ÅÆ„É¨„Ç∏„Çπ„Çø„Å´wd„ÇíÊõ∏????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
			
		assign rd1 = ra1	?	REG[ra1] :	1048'b0;	//0‰ª•Â§ñ„Å™„Çâ„Åù„ÅÆ„É¨„Ç∏„Çπ„Çø„ÅÆÂÄ§„ÇíÔøΩ??0„Å™„Çâ„Çº„É≠„ÇíËøî„Åô
		assign rd2 = ra2	?	REG[ra2]	:	1048'b0;
		
endmodule

module   jdetect(input [31:0] memdata,
						output jal,branch);

			wire [1:0]decans;
			assign decans = easydec(memdata);
			assign jal = decans[0];
			assign branch = decans[1];
			
			function[1:0]easydec;
				input [31:0]memdata;
				begin
				case(memdata[6:0])
				7'b1101111:begin //JAL
					easydec[0] = 1'b1;
					easydec[1] = 1'b0;
					end
				7'b1100011:begin //BRANCH
					easydec[0] = 1'b0;
					easydec[1] = 1'b1;
					end
				default:begin
				   easydec[0] = 1'b0;
					easydec[1] = 1'b0;
					end
				endcase
				end
			endfunction
endmodule
			
		
module	zero	#(parameter WIDTH=32)
					(input	[WIDTH-1:0]	data,
					output				zero);
			
			assign zero = (data == 32'b0);
					
endmodule

module	widthcntl	#(parameter WIDTH = 32)
						(input	[WIDTH-1:0]	indata,
						input		[2:0]			length,
						output 	[WIDTH-1:0]	outdata);
						
	assign outdata = width(indata,length);

   function [31:0]width;
	   input [31:0]indata;
	   input [2:0]length;
	
			begin
				case(length)
				3'b000:width			=	indata;	//LW(Load Word)
				3'b001:begin							//LHU(Load Half-word Unsigned)
							width[15:0]	=	indata[15:0];
							width[31:16]	=	16'b0;
						end
				3'b010:begin							//LBU(Load Byte Unsigned)
							width[7:0]	=	indata[7:0];
							width[31:8]	=	24'b0;
						end
				3'b011:begin							//LH(Load Half-word)
							width[15:0]	=	indata[15:0];
							if(indata[15] == 1)width[31:16]	=	16'hffff;
							else width[31:16]	=	16'b0;
						end
				3'b100:begin							//LB(Load Byte)
							width[7:0]	=	indata[7:0];
							if(indata[7] == 1)width[31:8]	=	24'hffffff;
							else width[31:8]	=	24'b0;
						end
				default:	width		=	indata;	//Ëµ∑„Åç„Å™????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
				endcase
			end
   endfunction

endmodule

module sel512_32 (input flag512,regwe,
                  input [4:0]regaddr,
                  output reg32we,
                  output [4:0]reg32addr,
                  output reg512_norm_we,
                  output reg512we,
                  output [3:0]reg512addr);
         
         wire reg512we_processing;
         wire [4:0]reg512addr_processing;
         
                  assign reg32we = flag512 ? 1'b0 : regwe;
                  assign reg512we_processing = flag512 ? regwe : 1'b0;
                  assign reg32addr = flag512 ? 5'b0 : regaddr;
                  assign reg512addr_processing = flag512 ? regaddr : 5'b0;
                  assign reg512_norm_we = reg512addr_processing[4] ? reg512we_processing : 1'b0;
                  assign reg512we = reg512addr_processing[4] ? 1'b0 : reg512we_processing;
                  assign reg512addr = reg512addr_processing[4] ? 4'b0 : reg512addr_processing[3:0];

endmodule

module ff	#(parameter WIDTH = 32)
				(input				clk,
				input			[WIDTH-1:0]	indata,
				output reg	[WIDTH-1:0]	outdata);
			
			always @(posedge clk)
				outdata <= indata;
						
endmodule	

module ffr	#(parameter WIDTH = 32)
				(input				clk,reset,stall,
				input			[WIDTH-1:0]	indata,
				output reg	[WIDTH-1:0]	outdata);
				
			initial begin
			outdata <= 32'b0;
			end

            wire [WIDTH-1:0] ffwrdata;
           assign ffwrdata = stall ? outdata : indata;
                			
			always @(posedge clk)
			if			(reset)	outdata <= 32'b0;
			else		 outdata <= ffwrdata;	
			
endmodule

module ffr1	(input				clk,reset,stall,
				input			indata,
				output reg	outdata);
				
			initial begin
			outdata <= 1'b0;
			end
				
                 wire   ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 1'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr2	(input				clk,reset,stall,
				input			[1:0]	indata,
				output reg	[1:0]	outdata);
				
			initial begin
			outdata <= 2'b0;
			end
				
                    wire [1:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 2'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr3	(input				clk,reset,stall,
				input			[2:0]	indata,
				output reg	[2:0]	outdata);
				
			initial begin
			outdata <= 3'b0;
			end
				
                    wire [2:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 3'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr4	(input		clk,reset,stall,
				input			[3:0]	indata,
				output reg	[3:0]	outdata);
				
			initial begin
			outdata <= 3'b0;
			end
				
			  wire [3:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 4'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr5	(input				clk,reset,stall,
				input			[4:0]	indata,
				output reg	[4:0]	outdata);
				
			initial begin
			outdata <= 5'b0;
			end
				
                     wire [4:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 5'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr7	(input				clk,reset,stall,
				input			[6:0]	indata,
				output reg	[6:0]	outdata);
				
			initial begin
			outdata <= 7'b0;
			end
				
                     wire [6:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 7'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr12	(input				clk,reset,stall,
				input			[11:0]	indata,
				output reg	[11:0]	outdata);
				
			initial begin
			outdata <= 12'b0;
			end
				
                     wire [11:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 12'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr512	(input				clk,reset,stall,
				input			[1047:0]	indata,
				output reg	[1047:0]	outdata);
				
			initial begin
			outdata <= 1048'b0;
			end
				
                     wire [1047:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 1048'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffrpc	#(parameter WIDTH = 32)
				(input				clk,reset,
				input			[WIDTH-1:0]	indata,
				output reg	[WIDTH-1:0]	outdata);
				
			initial begin
			outdata <= 32'h0000_0000;
			end
				
			always @(posedge clk)
			if			(reset)	outdata <= 32'b0;
			else		 outdata <= indata;	
			
endmodule



module ffenable #(parameter WIDTH = 32)	//„Ç§„ÉçÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„Éñ„É©Á´ØÂ≠ê‰ªò„Åç„Éï„É™????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?„Éó„Éï„É≠????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
						(input				clk,enable,
						input			[WIDTH-1:0]	indata,
						output reg	[WIDTH-1:0]	outdata);
			
			always @(posedge clk)
				if(enable) outdata <= indata;
						
endmodule									

module ffenabler #(parameter WIDTH = 32)	//„Ç§„ÉçÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„Éñ„É©Á´ØÂ≠êÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É™„Çª????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?„Éà‰ªò„Åç„Éï„É™????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?„Éó„Éï„É≠????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
						(input				clk,reset,enable,
						input			[WIDTH-1:0]	indata,
						output reg	[WIDTH-1:0]	outdata);
			
			always @(posedge clk)
				if			(reset)	outdata <= 0;
				else if	(enable)	outdata <= indata;
						
endmodule	

module mux2	#(parameter WIDTH = 32) //2ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input	[WIDTH-1:0]	data0,data1,
				input						seldata,
				output	[WIDTH-1:0]	outdata);
				
	assign outdata = seldata ? data1 : data0;
	
endmodule

module mux2_ra	#(parameter WIDTH = 32) //2ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input	[4:0]	data,
				input			seldata,
				output	[4:0]	outdata0,outdata1);
				
	assign outdata0 = seldata ? 5'b0 : data;
	assign outdata1 = seldata ? data : 5'b0;

endmodule

module mux2_512	#(parameter WIDTH = 1048) //2ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input	[WIDTH-1:0]	data0,data1,
				input						seldata,
				output	[WIDTH-1:0]	outdata);
				
	assign outdata = seldata ? data1 : data0;
	
endmodule

module mux4	#(parameter WIDTH = 32) //4ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input		[WIDTH-1:0]	data0,data1,data2,data3,
				input			[1:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
			
	assign outdata = mux4f(data0,data1,data2,data3,seldata);
				
	function [31:0]mux4f;
		input [31:0]data0,data1,data2,data3;
		input			[1:0]			seldata;
		begin
		case (seldata)
			2'b00: mux4f	= data0;
			2'b01: mux4f	= data1;
			2'b10: mux4f	= data2;
			2'b11: mux4f	= data3;
		endcase
		end
	endfunction
endmodule

module mux4_512	#(parameter WIDTH = 1048) //4ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input		[WIDTH-1:0]	data0,data1,data2,data3,
				input			[1:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
			
	assign outdata = mux4f_512(data0,data1,data2,data3,seldata);
				
	function [1047:0]mux4f_512;
		input [1047:0]data0,data1,data2,data3;
		input			[1:0]			seldata;
		begin
		case (seldata)
			2'b00: mux4f_512	= data0;
			2'b01: mux4f_512	= data1;
			2'b10: mux4f_512	= data2;
			2'b11: mux4f_512	= data3;
		endcase
		end
	endfunction
endmodule

module mux8	#(parameter WIDTH = 32) //8ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input		[WIDTH-1:0]	data0,data1,data2,data3,data4,data5,data6,data7,
				input			[2:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
				
	assign outdata = mux8f(data0,data1,data2,data3,data4,data5,data6,data7,seldata);
	
	function [31:0]mux8f;
		input [31:0]data0;
		input [31:0]data1;
		input [31:0]data2;
		input [31:0]data3;
		input [31:0]data4;
		input [31:0]data5;
		input [31:0]data6;
		input [31:0]data7;
		input	[2:0]	seldata;
		begin
		
		case (seldata)
			3'b000: mux8f = data0;
			3'b001: mux8f = data1;
			3'b010: mux8f = data2;
			3'b011: mux8f = data3;
			3'b100: mux8f = data4;
			3'b101: mux8f = data5;
			3'b110: mux8f = data6;
			3'b111: mux8f = data7;
		endcase
		end
	endfunction
endmodule

module mux8_512	#(parameter WIDTH = 1048) //8ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input		[WIDTH-1:0]	data0,data1,data2,data3,data4,data5,data6,data7,
				input			[2:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
				
	assign outdata = mux8f_512(data0,data1,data2,data3,data4,data5,data6,data7,seldata);
	
	function [1047:0]mux8_512f;
		input [1047:0]data0;
		input [1047:0]data1;
		input [1047:0]data2;
		input [1047:0]data3;
		input [1047:0]data4;
		input [1047:0]data5;
		input [1047:0]data6;
		input [1047:0]data7;
		input	[2:0]	seldata;
		begin
		
		case (seldata)
			3'b000: mux8_512f = data0;
			3'b001: mux8_512f = data1;
			3'b010: mux8_512f = data2;
			3'b011: mux8_512f = data3;
			3'b100: mux8_512f = data4;
			3'b101: mux8_512f = data5;
			3'b110: mux8_512f = data6;
			3'b111: mux8_512f = data7;
		endcase
		end
	endfunction
endmodule

module mux16	#(parameter WIDTH = 32) //8ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input		[WIDTH-1:0]	data0,data1,data2,data3,data4,data5,data6,data7,data8,data9,dataa,datab,datac,datad,datae,dataf,
				input			[3:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
				
	assign outdata = mux16f(data0,data1,data2,data3,data4,data5,data6,data7,data8,data9,dataa,datab,datac,datad,datae,dataf,seldata);
	
	function [31:0]mux16f;
		input [31:0]data0;
		input [31:0]data1;
		input [31:0]data2;
		input [31:0]data3;
		input [31:0]data4;
		input [31:0]data5;
		input [31:0]data6;
		input [31:0]data7;
		input [31:0]data8;
		input [31:0]data9;
		input [31:0]dataa;
		input [31:0]datab;
		input [31:0]datac;
		input [31:0]datad;
		input [31:0]datae;
		input [31:0]dataf;
		input	[3:0]	seldata;
		begin
		
		case (seldata)
			4'b0000: mux16f = data0;
			4'b0001: mux16f = data1;
			4'b0010: mux16f = data2;
			4'b0011: mux16f = data3;
			4'b0100: mux16f = data4;
			4'b0101: mux16f = data5;
			4'b0110: mux16f = data6;
			4'b0111: mux16f = data7;
			4'b1000: mux16f = data8;
			4'b1001: mux16f = data9;
			4'b1010: mux16f = dataa;
			4'b1011: mux16f = datab;
			4'b1100: mux16f = datac;
			4'b1101: mux16f = datad;
			4'b1110: mux16f = datae;
			4'b1111: mux16f = dataf;
			
		endcase
		end
	endfunction
endmodule

module mux16_512	#(parameter WIDTH = 1048) //8ÂÖ•????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?1Âá∫ÂäõÔøΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É´???øΩ?øΩ??øΩ?øΩ????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?????øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ„É¨„ÇØ„Çµ
				(input		[WIDTH-1:0]	data0,data1,data2,data3,data4,data5,data6,data7,data8,data9,dataa,datab,datac,datad,datae,dataf,
				input			[3:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
				
	assign outdata = mux16f_512(data0,data1,data2,data3,data4,data5,data6,data7,data8,data9,dataa,datab,datac,datad,datae,dataf,seldata);
	
	function [1047:0]mux16f_512;
		input [1047:0]data0;
		input [1047:0]data1;
		input [1047:0]data2;
		input [1047:0]data3;
		input [1047:0]data4;
		input [1047:0]data5;
		input [1047:0]data6;
		input [1047:0]data7;
		input [1047:0]data8;
		input [1047:0]data9;
		input [1047:0]dataa;
		input [1047:0]datab;
		input [1047:0]datac;
		input [1047:0]datad;
		input [1047:0]datae;
		input [1047:0]dataf;
		input	[3:0]	seldata;
		begin
		
		case (seldata)
			4'b0000: mux16f_512 = data0;
			4'b0001: mux16f_512 = data1;
			4'b0010: mux16f_512 = data2;
			4'b0011: mux16f_512 = data3;
			4'b0100: mux16f_512 = data4;
			4'b0101: mux16f_512 = data5;
			4'b0110: mux16f_512 = data6;
			4'b0111: mux16f_512 = data7;
			4'b1000: mux16f_512 = data8;
			4'b1001: mux16f_512 = data9;
			4'b1010: mux16f_512 = dataa;
			4'b1011: mux16f_512 = datab;
			4'b1100: mux16f_512 = datac;
			4'b1101: mux16f_512 = datad;
			4'b1110: mux16f_512 = datae;
			4'b1111: mux16f_512 = dataf;
			
		endcase
		end
	endfunction
endmodule
