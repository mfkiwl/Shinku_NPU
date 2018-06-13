module DECODE #(parameter WIDTH=32)
					(input clk,reset,IDREGclear,
					input [WIDTH-1:0]REGfetchdata,REGFpc,
					output [4:0]REGDrs1,REGDrs2,REGDrd,
					output [WIDTH-1:0]REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,
					output [1:0]REGDregfwda,REGDregfwdb,REGDalusrca,
					output [3:0]REGDalusrcb,
					output [1:0]REGDmem2reg,
					output [3:0]REGDalucont,
					output [1:0]REGDpcsource,
					output REGDiord,
					output [2:0]REGDllcntl,REGDslcntl,
					output REGDalusel,
					output [1:0]REGDbranchcntl,
					output REGDregwrite,REGDwenable,REGDcsrrw,
					output [11:0]REGDcsraddr,
					output [1:0]REGDbpflag,
					output REGDflag512,
					output REGDnwload,REGDnwstore,
					input  IDREGstall,
					input [1:0]branchpdres,
					output [31:0]branchpdaddr,
					output branchpdans,
					input rxfifoemp,
					output [31:0]nwsaddr,
					output nwsans);
					
					wire	[4:0]		rs1,rs2,rd,rdold1,rdold2,rdold3;
					wire	[31:0]	imm,branchimm,storeimm,jimm,luiimm,csrimm;
					wire	[27:0]	systemcont;
					wire  [6:0]    opcode,opcode1,opcode2,opcode3,funct7;
					wire  [2:0]    funct3,llcntl,slcntl;
					wire  [11:0]   imm12,csraddr;
					wire  [1:0]    alusrca,mem2reg,pcsource;
					wire  [3:0]    alusrcb;
					wire           regwrite,iord,wenable,csrrw,alusel,flag512,flag512old1,flag512old2,flag512old3,nwload,nwstore;
					wire  [1:0]		branchcntl;
					wire  [3:0]    alucont;
					
					wire [1:0] fwdold1,fwdold2,fwdold3,fwdmuxsela,fwdmuxselb;
               wire [2:0] ereg0,ereg1,ereg2,ereg3;
					wire [1:0] regc_1,regc_2,regc_3;
					
					wire [1:0] fwdold1_512,fwdold2_512,fwdold3_512,fwdmuxsela_512,fwdmuxselb_512;
               wire [2:0] ereg0_512,ereg1_512,ereg2_512,ereg3_512;
               wire [1:0] regc_1_512,regc_2_512,regc_3_512;
					
					reg [1:0]branchpd_state;

					
					assign rs1					=	REGfetchdata[19:15];	//rs1„ÅÆÂ†¥??øΩ?øΩ??øΩ?øΩ?
					assign rs2					=	REGfetchdata[24:20];	//rs2„ÅÆÂ†¥??øΩ?øΩ??øΩ?øΩ?
					assign rd					=	REGfetchdata[11:7];	//rd„ÅÆÂ†¥??øΩ?øΩ??øΩ?øΩ?
					assign imm[11:0]			=	REGfetchdata[31:20];	//ÂÆöÊï∞ÂëΩ‰ª§„Å´„Åä„ÅÑ„Å¶ÂÆöÊï∞„ÅåÔøΩ???øΩ?øΩ„ÇãÔøΩ???øΩ?øΩ??øΩ?øΩ??øΩ?øΩ?
					assign imm[31:12]			=	20'B0;
					assign jimm[0]				=	1'b0;
					assign jimm[10:1]			=	REGfetchdata[30:21];	//ÂëΩ‰ª§„Å´„Åä„ÅÑ„Å¶ÂÆöÊï∞„ÅåÔøΩ???øΩ?øΩ„ÇãÔøΩ???øΩ?øΩ??øΩ?øΩ??øΩ?øΩ?
					assign jimm[11]			=	REGfetchdata[20];
					assign jimm[19:12]		=	REGfetchdata[19:12];
					assign jimm[20]			=	REGfetchdata[31];
					assign jimm[31:21]		=	{11{jimm[19]}};
					assign opcode				=	REGfetchdata[6:0];		//OPCODE
					assign funct3				=	REGfetchdata[14:12];	//functionË≠òÂà•„ÅÆ„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(3??øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?)
					assign funct7				=	REGfetchdata[31:25];	//functionË≠òÂà•„ÅÆ„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(7??øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?)
					assign imm12				=	REGfetchdata[31:20];	//ÂëΩ‰ª§„ÅÆË≠òÂà•„Å´‰Ωø??øΩ?øΩ??øΩ?øΩ?ÂÆöÊï∞(12??øΩ?øΩ??øΩ?øΩ???øΩ?øΩ??øΩ?øΩ?
					assign branchimm[0]		=	1'b0;
					assign branchimm[4:1]	=	REGfetchdata[11:8];	//??øΩ?øΩ??øΩ?øΩ?Â≤êÔøΩ???øΩ?øΩÊôÇ„Å´Ë∂≥„ÅôÊï∞„ÅÆ‰ΩúÔøΩ???øΩ?øΩ??øΩ?øΩ„Åì„Åì„Åã„Çâ
					assign branchimm[10:5]	=	REGfetchdata[30:25];
					assign branchimm[11]		=	REGfetchdata[7];
					assign branchimm[12]		=	REGfetchdata[31];		//„Åì„Åì„Åæ„Åß
					assign branchimm[31:13]	=	{19{branchimm[11]}};
					assign storeimm[4:0]		=	REGfetchdata[11:7];
					assign storeimm[11:5]	=	REGfetchdata[31:25];
					assign storeimm[31:12]	=	{20{storeimm[11]}};
					assign luiimm[31:12]		=	REGfetchdata[31:12];
					assign luiimm[11:0]		=	12'b0;
					assign csraddr				=	imm12;
					assign csrimm[4:0]		=	REGfetchdata[19:15];
					assign csrimm[31:5]		=	27'b0;
					
					assign alusrca		=	systemcont[1:0];
					assign alusrcb		=	systemcont[5:2];
					assign mem2reg		=	systemcont[7:6];
					assign regwrite	=	systemcont[8];
					assign alusel		=  systemcont[9];
					assign alucont		=	systemcont[13:10];
					assign pcsource	=	systemcont[15:14];
					assign iord			=	systemcont[16];
					assign llcntl		=	systemcont[19:17];
					assign slcntl		=	systemcont[22:20];
					assign wenable		=	systemcont[23];
					assign csrrw		=	systemcont[24];
					assign flag512    =  systemcont[25];
					assign nwload     =  systemcont[26];
					assign nwstore    =  systemcont[27];
			
					//RV32I„ÅÆOPCODE
					parameter   LOAD		=  7'b0000011;
					parameter   STORE		=  7'b0100011;
					parameter	OP			=	7'b0110011; //MUL/DIV„ÇÇ„Åì??øΩ?øΩ??øΩ?øΩ?
					parameter	OPIMM		=	7'b0010011;
					parameter	LUI		=	7'b0110111;
					parameter	AUIPC		=	7'b0010111;
					parameter	JAL		=	7'b1101111;
					parameter	JALR		=	7'b1100111;
					parameter	BRANCH	=	7'b1100011;
					parameter	MISCMEM	=	7'b0001111;
					parameter	SYSTEM	=	7'b1110011;
					parameter  ETHOP	   =   7'b0001011;
					parameter  ETHLS  	=   7'b0101011;
	
					//OPÂëΩ‰ª§„ÅÆfunction„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(funct3)
					parameter   ADDSUB	=  3'b000;
					parameter   SLT		=  3'b010;
					parameter	SLTU		=	3'b011;
					parameter	AND		=	3'b111;
					parameter	OR			=	3'b110;
					parameter	XOR		=	3'b100;
					parameter   SLL		=  3'b001;
					parameter   SRLSRA	=  3'b101;
	
					//LOADÂëΩ‰ª§„ÅÆfunction„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(funct3)
					parameter   LB			=  3'b000;
					parameter   LH			=  3'b001;
					parameter	LW			=	3'b010;
					parameter	LBU		=	3'b100;
					parameter	LHU		=	3'b101;
					parameter  LNW    =   3'b110;
	
					//STOREÂëΩ‰ª§„ÅÆfunction„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(funct3)
					parameter   SB			=  3'b000;
					parameter   SH			=  3'b001;
					parameter	SW			=	3'b010;
					parameter  SNW        =   3'b011;
					
					//FUnction Code of NWS(Network Store)/NWL(Network Load)(funct3)
					parameter   NWL			=  3'b000;
					parameter   NWS			=  3'b001;
			
					//BRANCHÂëΩ‰ª§„ÅÆfunction„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(funct3)
					parameter   BEQ			=  3'b000;
					parameter   BNE			=  3'b001;
					parameter	BLT			=	3'b100;
					parameter   BGE			=  3'b101;
					parameter   BLTU			=  3'b110;
					parameter	BGEU			=	3'b111;
	
					//MISCMEMÂëΩ‰ª§„ÅÆfunction„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(funct3)
					parameter   FENCE			=  3'b000;
					parameter   FENCEI		=  3'b001;
			
					//SYSTEMÂëΩ‰ª§„ÅÆfunction„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(funct3)
					parameter   ECAEBR	=  3'b000;
					parameter   CSRRW		=  3'b001;
					parameter	CSRRS		=	3'b010;
					parameter	CSRRC		=	3'b011;
					parameter	CSRRWI	=	3'b101;
					parameter	CSRRSI	=	3'b110;
					parameter   CSRRCI	=  3'b111;
				
					//MULÂëΩ‰ª§Á≥ª„ÅÆÊã°ÂºµÂëΩ‰ª§
					parameter	MUL		=	3'b000;
					parameter	MULH		=	3'b001;
					parameter	MULHSU	=	3'b010;
					parameter	MULHU		=	3'b011;
					parameter	DIV		=	3'b100;
					parameter	DIVU		=	3'b101;
					parameter	REM		=	3'b110;
					parameter	REMU		=	3'b111;
	
					//ECALL,EBREAKÂëΩ‰ª§„ÅÆÂà§Êñ≠„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?(imm[11:0])
					parameter   ECALL		=  11'b0;
					parameter   EBREAK	=  11'b00000000001;
				
					assign systemcont =	decoder(opcode,funct3,funct7,imm12);
					assign branchcntl	=	branchcntl_base(opcode,funct3);

				
				//„Åì„Åì„Åã„Çâ‰∏ãÔøΩ???øΩ?øΩ?øΩ?øΩ?„Éº„Çø„Éë„Çπ
					ffr5 REGrs1        (clk,IDREGclear,IDREGstall,rs1,REGDrs1);
					ffr5 REGrs2        (clk,IDREGclear,IDREGstall,rs2,REGDrs2);
					ffr5 REGrd         (clk,IDREGclear,IDREGstall,rd,REGDrd);
					ffr  REGimm        (clk,IDREGclear,IDREGstall,imm,REGDimm);
					ffr  REGjimm       (clk,IDREGclear,IDREGstall,jimm,REGDjimm);
					ffr  REGbranchimm  (clk,IDREGclear,IDREGstall,branchimm,REGDbranchimm);
					ffr  REGstoreimm   (clk,IDREGclear,IDREGstall,storeimm,REGDstoreimm);
					ffr  REGluiimm     (clk,IDREGclear,IDREGstall,luiimm,REGDluiimm);
					ffr  REGcsrimm     (clk,IDREGclear,IDREGstall,csrimm,REGDcsrimm);
					ffr  REGpc         (clk,IDREGclear,IDREGstall,REGFpc,REGDpc);
				//„Åì„Åì„Åæ„Åß
				
				//„Åì„Åì„Åã„Çâ‰∏ãÔøΩ???øΩ?øΩ?øΩ?øΩ?„Ç≥„Éº??øΩ?øΩ??øΩ?øΩ?Âá∫??øΩ?øΩ??øΩ?øΩ?	
				   ffr2  REGregfwda  (clk,IDREGclear,IDREGstall,fwdmuxsela,REGDregfwda);
					ffr2  REGregfwdb  (clk,IDREGclear,IDREGstall,fwdmuxselb,REGDregfwdb);
					ffr2  REGalusrca  (clk,IDREGclear,IDREGstall,alusrca,REGDalusrca);
					ffr4  REGalusrcb  (clk,IDREGclear,IDREGstall,alusrcb,REGDalusrcb);
					ffr2  REGmem2reg  (clk,IDREGclear,IDREGstall,mem2reg,REGDmem2reg);
					ffr1  REGregwrite (clk,IDREGclear,IDREGstall,regwrite,REGDregwrite);
					ffr1  REGalusel   (clk,IDREGclear,IDREGstall,alusel,REGDalusel);
					ffr4  REGalucont  (clk,IDREGclear,IDREGstall,alucont,REGDalucont);
					ffr2  REGpcsource (clk,IDREGclear,IDREGstall,pcsource,REGDpcsource);
					ffr1  REGiord     (clk,IDREGclear,IDREGstall,iord,REGDiord);
					ffr3  REGllcntl   (clk,IDREGclear,IDREGstall,llcntl,REGDllcntl);
					ffr3  REGslcntl   (clk,IDREGclear,IDREGstall,slcntl,REGDslcntl);
					ffr2  REGbrcntl   (clk,IDREGclear,IDREGstall,branchcntl,REGDbranchcntl);
					ffr1  REGwenable  (clk,IDREGclear,IDREGstall,wenable,REGDwenable);
					ffr1  REGcsrrw    (clk,IDREGclear,IDREGstall,csrrw,REGDcsrrw);
					ffr12 REGcsraddr  (clk,IDREGclear,IDREGstall,csraddr,REGDcsraddr);
					ffr2  REGbpflag   (clk,IDREGclear,IDREGstall,branchpd_state,REGDbpflag);
					ffr1  REGflag512  (clk,IDREGclear,IDREGstall,flag512,REGDflag512);
					ffr1  REGnwload  (clk,IDREGclear,IDREGstall,nwload,REGDnwload);	
					ffr1  REGnwstore  (clk,IDREGclear,IDREGstall,nwstore,REGDnwstore);								
				//„Åì„Åì„Åæ„Åß
					
				//„Éï„Ç©„ÉØ„Éº??øΩ?øΩ??øΩ?øΩ?„Ç£„É≥„Ç∞„ÅåÔøΩ??øΩ?øΩ?Ë¶Å„Åã„Å©??øΩ?øΩ??øΩ?øΩ?„ÅãÔøΩ???øΩ?øΩÊ§úÔøΩ???øΩ?øΩ
				   ffr7 REGopcode1		  (clk,IDREGclear,IDREGstall,opcode,opcode1);
					ffr7 REGopcode2        (clk,IDREGclear,IDREGstall,opcode1,opcode2);
					ffr7 REGopcode3        (clk,IDREGclear,IDREGstall,opcode2,opcode3);
					ffr5 REGrdold1         (clk,IDREGclear,IDREGstall,rd,rdold1);
					ffr5 REGrdold2         (clk,IDREGclear,IDREGstall,rdold1,rdold2);
					ffr5 REGrdold3         (clk,IDREGclear,IDREGstall,rdold2,rdold3);
					ffr1 REGflg512old1     (clk,IDREGclear,IDREGstall,flag512,flag512old1);
					ffr1 REGflg512old2     (clk,IDREGclear,IDREGstall,flag512old1,flag512old2);					
					ffr1 REGflg512old3     (clk,IDREGclear,IDREGstall,flag512old2,flag512old3);
					ffr3 REGereg01         (clk,IDREGclear,IDREGstall,ereg0,ereg1);
					ffr3 REGereg12         (clk,IDREGclear,IDREGstall,ereg1,ereg2);					
					ffr3 REGereg23         (clk,IDREGclear,IDREGstall,ereg2,ereg3);
					
					assign ereg0 =  ereg(opcode,funct3);

					assign regc_1[1] = regc(ereg0[2],ereg1[0],flag512,flag512old1); //rs1
					assign regc_1[0] = regc(ereg0[1],ereg1[0],flag512,flag512old1); //rs2
					assign regc_2[1] = regc(ereg0[2],ereg2[0],flag512,flag512old2); //rs1
               assign regc_2[0] = regc(ereg0[1],ereg2[0],flag512,flag512old2); //rs2
               assign regc_3[1] = regc(ereg0[2],ereg3[0],flag512,flag512old3); //rs1
               assign regc_3[0] = regc(ereg0[1],ereg3[0],flag512,flag512old3); //rs2
						
					assign fwdmuxsela = regfwdds1(fwdold1,fwdold2,fwdold3);
					assign fwdmuxselb = regfwdds2(fwdold1,fwdold2,fwdold3);
					
					assign fwdold1 = fwd(regc_1,rdold1,rs1,rs2);
					assign fwdold2 = fwd(regc_2,rdold2,rs1,rs2);
					assign fwdold3 = fwd(regc_3,rdold3,rs1,rs2);
					
					function regc;
					   input ereg0;
					   input ereg1;
					   input flag512_0;
					   input flag512_1;
					   
					   case(flag512_0)
					       1'b0: begin
					           case(flag512_1)
					               1'b0: regc = ereg0 & ereg1;
					               1'b1: regc = 1'b0;
					           endcase
					             end
					      1'b1: begin
					           case(flag512_1)
                              1'b0: regc = 1'b0;
                              1'b1: regc = ereg0 & ereg1;
                          endcase
                            end   
					   
					   endcase
					endfunction
					
					function [1:0]fwd;
					 input [1:0]reg_c;
					 input [4:0]REGold;
					 input [4:0]rs1;
					 input [4:0]rs2;
					 
					case (reg_c)
						2'b00: fwd = 2'b00;
						2'b10: case(REGold - rs1)
										5'b0000: fwd = 2'b10;
										default: fwd = 2'b00;
										endcase
						2'b01: case(REGold - rs2)
										5'b0000: fwd = 2'b01;
										default: fwd = 2'b00;
										endcase
						2'b11: case(REGold - rs2)
										5'b0000: case(REGold - rs1)
													5'b0000: fwd = 2'b11;
													default: fwd = 2'b01;
													endcase
										default: case(REGold - rs1)
													5'b0000: fwd = 2'b10;
													default: fwd = 2'b00;
													endcase
								  endcase
					endcase
					
					endfunction
					
			function [2:0]ereg;
				input [6:0]opcode;
				input [2:0]funct3;
			
				begin
		
					case(opcode)
							LOAD:    ereg	=	3'b101;	
							STORE:   ereg	=	3'b110;	
							OP:      ereg	=	3'b111;
							ETHOP:   ereg   =   3'b111;
							OPIMM:   ereg	=	3'b101;	
							LUI:     ereg	=	3'b001;
							AUIPC:   ereg	=	3'b001;
							JAL:     ereg	=	3'b001;
							JALR:    ereg	=	3'b101;	
							BRANCH:  ereg	=	3'b110;
							MISCMEM: ereg	=	3'b000;
							SYSTEM:  ereg	=	3'b000;
							NWL:     ereg  =  3'b001;
					      ETHLS:   begin
								case(funct3)
									NWL: ereg = 3'b001; 
									NWS: ereg = 3'b010;
									default: ereg = 3'b000;
								endcase
						   end	
			   	default:	ereg		=	3'b000;	//Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?
				   endcase
				end
				   
			endfunction
					
					function [1:0]regfwdds1; //Register Forword Data Source for Register source1
				        input  [1:0]fwdold1;
                    input  [1:0]fwdold2;
                    input  [1:0]fwdold3;
						 
						 case(fwdold1[1])
							1'b1: regfwdds1 = 2'b01;
							1'b0: case (fwdold2[1])
									  1'b1:  regfwdds1 = 2'b10;
						           1'b0:  case(fwdold3[1])
											     1'b1: regfwdds1 = 2'b11;
												  1'b0: regfwdds1 = 2'b00;
												endcase
						         endcase
						endcase
					endfunction
					
					function [1:0]regfwdds2;//Register Forword Data Source for Register source2
				        input  [1:0]fwdold1;
                    input  [1:0]fwdold2;
                    input  [1:0]fwdold3;
						 
						 case(fwdold1[0])
							1'b1: regfwdds2 = 2'b01;
							1'b0: case (fwdold2[0])
									  1'b1:  regfwdds2 = 2'b10;
						           1'b0:  case(fwdold3[0])
											     1'b1: regfwdds2 = 2'b11;
												  1'b0: regfwdds2 = 2'b00;
												endcase
						         endcase
						endcase
					endfunction
					
				function	[1:0]branchcntl_base;
				input 		[6:0]	opcode;
				input			[2:0]	funct3;
				
				begin
				if(opcode == BRANCH )begin
						branchcntl_base = 2'b01;
				end
				else if(opcode == JALR) begin
						branchcntl_base = 2'b10;
				end
				else branchcntl_base = 2'b00;				
				end
            endfunction
	
				function [27:0] decoder;
				input 		[6:0]	opcode;
				input			[2:0]	funct3;
				input			[6:0] funct7;
				input			[11:0]imm12;

				begin
				case(opcode)	//opcode„Çí„Åæ„ÅöËß£??øΩ?øΩ??øΩ?øΩ?
					OP:begin		//ÊºîÁÆóÂëΩ‰ª§
					   case(funct3) //opcode„ÅåOP„ÅÆÂëΩ‰ª§„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
						   ADDSUB:	begin
									case(funct7) //funct3„ÅåÂêå„ÅòADD„Å®SUB„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0011_0_1_00_0000_00; //ADD
											7'b0100000:		decoder = 28'b0_0_0_0_0_000_000_0_00_0100_0_1_00_0000_00; //SUB
											7'b0000001:	   decoder = 28'b0_0_0_0_0_000_000_0_00_0000_1_1_00_0000_00; //MUL
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0011_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(ADD)
									endcase
									end
						   SLT:	begin
									case(funct7) //funct3„ÅåÂêå„ÅòSLT„Å®MULHSU„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0101_0_1_00_0000_00; //SLT
											7'b0000001:		decoder = 28'b0_0_0_0_0_000_000_0_00_0010_1_1_00_0000_00; //MULHSU
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0101_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SLT)
									endcase
									end
						   SLTU:	begin
									case(funct7) //funct3„ÅåÂêå„ÅòSLTU„Å®MULHU„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0110_0_1_00_0000_00; //SLTU
											7'b0000001:		decoder = 28'b0_0_0_0_0_000_000_0_00_0011_1_1_00_0000_00; //MULHU
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0110_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SLTU)
									endcase
									end
						   AND:	begin
									case(funct7) //funct3„ÅåÂêå„ÅòXOR„Å®DIV„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0000_0_1_00_0000_00; //AND
											7'b0000001:		decoder = 28'b0_0_0_0_0_000_000_0_00_0111_1_1_00_0000_00; //REMU
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(AND)
									endcase
									end
						   OR:	begin
									case(funct7) //funct3„ÅåÂêå„ÅòXOR„Å®DIV„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0001_0_1_00_0000_00; //OR
											7'b0000001:		decoder = 28'b0_0_0_0_0_000_000_0_00_0110_1_1_00_0000_00; //REM
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0001_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(OR)
									endcase
									end
						   XOR:	begin
									case(funct7) //funct3„ÅåÂêå„ÅòXOR„Å®DIV„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0010_0_1_00_0000_00; //XOR
											7'b0000001:		decoder = 28'b0_0_0_0_0_000_000_0_00_0100_1_1_00_0000_00; //DIV
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0010_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(XOR)
									endcase
									end
						   SLL:		begin
									case(funct7) //funct3„ÅåÂêå„ÅòSLL„Å®MULH„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:				decoder = 28'b0_0_0_0_0_000_000_0_00_0111_0_1_00_0000_00; //SLL
											7'b0000001:		decoder = 28'b0_0_0_0_0_000_000_0_00_0001_1_1_00_0000_00; //MULH
											default:			decoder = 28'b0_0_0_0_0_000_000_0_00_0111_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SLL)
									endcase
									end
						   SRLSRA:begin
						   			case(funct7) //funct3„ÅåÂêå„ÅòSRL„Å®SRA„Å®DIVU„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
						   				7'b0:			decoder = 28'b0_0_0_0_0_000_000_0_00_1000_0_1_00_0000_00; //SRL
							   			7'b0100000:	decoder = 28'b0_0_0_0_0_000_000_0_00_1001_0_1_00_0000_00; //SRA
											7'b0000001:	decoder = 28'b0_0_0_0_0_000_000_0_00_0101_1_1_00_0000_00; //DIVU
											default:		decoder = 28'b0_0_0_0_0_000_000_0_00_1000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SRL)
										endcase
									end
						   default: decoder = 28'b0_0_0_0_0_000_000_0_00_0000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(AND)
					   endcase
					end
				ETHOP:begin //Network Extention
				 case(funct3)
				  ADDSUB:	begin
                         case(funct7) //funct3„ÅåÂêå„ÅòADD„Å®SUB„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0011_0_1_00_0000_00; //ADD
                                 7'b0100000:        decoder = 28'b0_0_1_0_0_000_000_0_00_0100_0_1_00_0000_00; //SUB
                                 7'b0000001:       decoder = 28'b0_0_1_0_0_000_000_0_00_0000_1_1_00_0000_00; //MUL
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0011_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(ADD)
                         endcase
                         end
                SLT:    begin
                         case(funct7) //funct3„ÅåÂêå„ÅòSLT„Å®MULHSU„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0101_0_1_00_0000_00; //SLT
                                 7'b0000001:        decoder = 28'b0_0_1_0_0_000_000_0_00_0010_1_1_00_0000_00; //MULHSU
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0101_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SLT)
                         endcase
                         end
                SLTU:    begin
                         case(funct7) //funct3„ÅåÂêå„ÅòSLTU„Å®MULHU„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0110_0_1_00_0000_00; //SLTU
                                 7'b0000001:        decoder = 28'b0_0_1_0_0_000_000_0_00_0011_1_1_00_0000_00; //MULHU
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0110_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SLTU)
                         endcase
                         end
                AND:    begin
                         case(funct7) //funct3„ÅåÂêå„ÅòXOR„Å®DIV„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0000_0_1_00_0000_00; //AND
                                 7'b0000001:        decoder = 28'b0_0_1_0_0_000_000_0_00_0111_1_1_00_0000_00; //REMU
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(AND)
                         endcase
                         end
                OR:    begin
                         case(funct7) //funct3„ÅåÂêå„ÅòXOR„Å®DIV„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0001_0_1_00_0000_00; //OR
                                 7'b0000001:        decoder = 28'b0_0_1_0_0_000_000_0_00_0110_1_1_00_0000_00; //REM
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0001_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(OR)
                         endcase
                         end
                XOR:    begin
                         case(funct7) //funct3„ÅåÂêå„ÅòXOR„Å®DIV„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0010_0_1_00_0000_00; //XOR
                                 7'b0000001:        decoder = 28'b0_0_1_0_0_000_000_0_00_0100_1_1_00_0000_00; //DIV
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0010_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(XOR)
                         endcase
                         end
                SLL:        begin
                         case(funct7) //funct3„ÅåÂêå„ÅòSLL„Å®MULH„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                 7'b0:                decoder = 28'b0_0_1_0_0_000_000_0_00_0111_0_1_00_0000_00; //SLL
                                 7'b0000001:        decoder = 28'b0_0_1_0_0_000_000_0_00_0001_1_1_00_0000_00; //MULH
                                 default:            decoder = 28'b0_0_1_0_0_000_000_0_00_0111_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SLL)
                         endcase
                         end
                SRLSRA:begin
                            case(funct7) //funct3„ÅåÂêå„ÅòSRL„Å®SRA„Å®DIVU„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
                                7'b0:            decoder = 28'b0_0_1_0_0_000_000_0_00_1000_0_1_00_0000_00; //SRL
                                7'b0100000:    decoder = 28'b0_0_1_0_0_000_000_0_00_1001_0_1_00_0000_00; //SRA
                                 7'b0000001:    decoder = 28'b0_0_1_0_0_000_000_0_00_0101_1_1_00_0000_00; //DIVU
                                 default:        decoder = 28'b0_0_1_0_0_000_000_0_00_1000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SRL)
                             endcase
                         end
                default: decoder = 28'b0_0_1_0_0_000_000_0_00_0000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(AND)
            endcase
         end
				
				OPIMM:begin
						case(funct3) //opcode„ÅåOP„ÅÆÂëΩ‰ª§„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
							ADDSUB:	 decoder = 28'b0_0_0_0_0_000_000_0_00_0011_0_1_00_0010_00;	//SUBI„ÅØ„Å™??øΩ?øΩ??øΩ?øΩ?„Åü„ÇÅADDI„ÅÆ„Åø
							SLT:		 decoder = 28'b0_0_0_0_0_000_000_0_00_0101_0_1_00_0010_00;
							SLTU:		 decoder = 28'b0_0_0_0_0_000_000_0_00_0110_0_1_00_0010_00;
							AND:		 decoder = 28'b0_0_0_0_0_000_000_0_00_0000_0_1_00_0010_00;
							OR:		 decoder = 28'b0_0_0_0_0_000_000_0_00_0001_0_1_00_0010_00;
							XOR:		 decoder = 28'b0_0_0_0_0_000_000_0_00_0010_0_1_00_0010_00;
							SLL:		 decoder = 28'b0_0_0_0_0_000_000_0_00_0111_0_1_00_0010_00;
							SRLSRA:	begin
										case(funct7) //funct3„ÅåÂêå„ÅòSRL„Å®SRA„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
											7'b0:			 decoder = 28'b0_0_0_0_0_000_000_0_00_1000_0_1_00_0010_00;
											7'b0100000:	 decoder = 28'b0_0_0_0_0_000_000_0_00_1001_0_1_00_0010_00;
											default:  decoder = 28'b0_0_0_0_0_000_000_0_00_1000_0_1_00_0010_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?(SRL)
										endcase
										end
							default:  decoder = 28'b0_0_0_0_0_000_000_0_00_00011_1_00_010_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ? (AND)
						endcase
						end
						
				LOAD:	begin
						case(funct3) //opcode„ÅåLOAD„ÅÆÂëΩ‰ª§„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
								LB:		 decoder = 28'b0_0_0_0_0_000_100_1_00_0011_0_1_01_0010_00;
								LH:		 decoder = 28'b0_0_0_0_0_000_011_1_00_0011_0_1_01_0010_00;
								LW:		 decoder = 28'b0_0_0_0_0_000_000_1_00_0011_0_1_01_0010_00;
								LBU:		 decoder = 28'b0_0_0_0_0_000_010_1_00_0011_0_1_01_0010_00;
								LHU:		 decoder = 28'b0_0_0_0_0_000_001_1_00_0011_0_1_01_0010_00;
								LNW:        decoder  = 28'b0_0_1_0_0_000_101_1_00_0011_0_1_01_0010_00;
                        default:  decoder = 28'b0_0_0_0_0_000_111_1_00_0011_0_1_01_0010_00;
						endcase
						end
				STORE: begin
						case(funct3) //opcode„ÅåLOAD„ÅÆÂëΩ‰ª§„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
								LB:		 decoder = 28'b0_0_0_0_1_100_000_1_00_0011_0_0_00_0100_00;
								LH:		 decoder = 28'b0_0_0_0_1_011_000_1_00_0011_0_0_00_0100_00;
								LW:		 decoder = 28'b0_0_0_0_1_000_000_1_00_0011_0_0_00_0100_00;
								LBU:		 decoder = 28'b0_0_0_0_1_100_000_1_00_0011_0_0_00_0100_00;
								LHU:		 decoder = 28'b0_0_0_0_1_011_000_1_00_0011_0_0_00_0100_00;
								LNW:      decoder = 28'b0_0_1_0_0_101_000_1_00_0011_0_0_00_0010_00;
                        default:  decoder = 28'b0_0_0_0_1_111_000_1_00_0011_0_0_00_0100_00;
						endcase
						end
				ETHLS: begin
						 case(funct3)
								NWL:      decoder = 28'b0_1_1_0_0_000_000_0_00_0001_0_1_00_0011_10;
								NWS:      decoder = 28'b1_0_1_0_0_000_000_0_00_0001_0_0_00_0000_10;
	                     default:  decoder = 28'b0_1_1_0_0_000_000_0_00_0001_0_1_00_0000_10;
						 endcase
						 end
				BRANCH: begin
						case(funct3)
								BEQ:		decoder = 28'b0_0_0_0_0_000_000_0_01_1110_0_0_00_0000_00;
								BNE:		decoder = 28'b0_0_0_0_0_000_000_0_01_1101_0_0_00_0000_00;
								BLT:		decoder = 28'b0_0_0_0_0_000_000_0_01_0101_0_0_00_0000_00;
								BGE:		decoder = 28'b0_0_0_0_0_000_000_0_01_1011_0_0_00_0000_00;
								BLTU:		decoder = 28'b0_0_0_0_0_000_000_0_01_0110_0_0_00_0000_00;
								BGEU:		decoder = 28'b0_0_0_0_0_000_000_0_01_1100_0_0_00_0000_00;								
						default:  decoder = 28'b0_0_0_0_000_000_0_01_1101_0_0_00_0000_00;//„Çº„É≠„Åò„ÇÉ„Å™??øΩ?øΩ??øΩ?øΩ?
							endcase
							end
				
				LUI: decoder = 28'b0_0_0_0_0_000_000_0_00_0011_0_1_00_0101_10; //„Çº„É≠„Åò„ÇÉ„Å™??øΩ?øΩ??øΩ?øΩ?
				
				JAL:  decoder = 28'b0_0_0_0_0_000_000_1_10_0011_0_1_10_0011_01;
				JALR:  decoder = 28'b0_0_0_0_0_000_000_1_10_0011_0_1_10_0010_00;	
				AUIPC:	decoder = 28'b0_0_0_0_0_000_000_0_00_0011_0_1_00_0010_01;
				SYSTEM: begin
						case(funct3) //opcode„ÅåLOAD„ÅÆÂëΩ‰ª§„Çí„Åï„Çâ„Å´Ëß£??øΩ?øΩ??øΩ?øΩ?
								CSRRW:		 decoder = 28'b0_0_0_1_0_000_000_1_00_00011_1_11_1111_00;
								CSRRS:		 decoder = 28'b0_0_0_1_0_000_000_1_00_00001_0_11_0110_00;
								CSRRC:		 decoder = 28'b0_0_0_1_0_000_000_1_00_10010_0_11_0110_00;
								CSRRWI:		 decoder = 28'b0_0_0_1_0_000_000_1_00_00011_0_00_1000_00;
								CSRRSI:		 decoder = 28'b0_0_0_1_0_000_000_1_00_00001_0_00_1000_00;
								CSRRCI:		 decoder = 28'b0_0_0_1_0_000_000_1_00_10010_0_00_1000_00;
                        default:  decoder = 28'b0_0_0_1_0_000_000_1_00_00011_0_00_1111_00;
								//csren_wenable_slcntl_llcntl_iord_pcsource_alucont_regwrite_mem2reg_alusrcb_alusrca
						endcase
						end
														
            default:	 decoder = 28'b0_0_0_0_0_000_000_0_00_0000_0_1_00_0000_00; // Âü∫Êú¨Ëµ∑„Åç„Å™??øΩ?øΩ??øΩ?øΩ?
				endcase
		end
endfunction

                    assign nwsaddr = REGFpc;
                    assign nwsans  = nwsdetect(opcode,funct3,rxfifoemp); 
                    
                    function nwsdetect;
                                input [6:0]opcode;
                                input [2:0]funct3;
                                input fifoemp;
                                
                                case (opcode)
                                    ETHLS:begin
                                          if(funct3 == 3'b0) begin //NWL
                                            if(fifoemp == 1)begin
                                                nwsdetect = 1'b1;
                                            end else begin
                                                nwsdetect = 1'b0;
                                            end
                                        end
                                        else begin
                                            nwsdetect = 1'b0;
                                        end
                                    end
                                    default:nwsdetect = 1'b0;
                                endcase
                    endfunction            
                                

					assign branchpdaddr = REGFpc + 4 + branchimm;
					assign branchpdans = branchpd(opcode,branchpd_state);
					
					initial begin
					branchpd_state = 2'b01;
					end
					
					always @(posedge clk) begin	
					case (branchpdres)
						2'b00:begin
							branchpd_state <= branchpd_state;
							end
						2'b01:begin
							if(branchpd_state == 2'b0) begin
								branchpd_state <= 2'b0;
							end
							else if(branchpd_state == 2'b01) begin
								branchpd_state <= 2'b00;
							end
							else if(branchpd_state == 2'b10) begin
								branchpd_state <= 2'b01;
							end
							else begin
								branchpd_state <= 2'b10;
							end
						end
						2'b10:begin
							if(branchpd_state == 2'b0) begin
								branchpd_state <= 2'b01;
							end
							else if(branchpd_state == 2'b01) begin
								branchpd_state <= 2'b10;
							end
							else if(branchpd_state == 2'b10) begin
								branchpd_state <= 2'b11;
							end
							else begin
								branchpd_state <= 2'b11;
							end
						end
						2'b11:begin
							branchpd_state <= branchpd_state;
							end
			         default:begin
							branchpd_state <= branchpd_state;
							end
					endcase
					
					end

		function branchpd;
					input [6:0]opcode;
					input [1:0]bp_state;
					case (opcode)
						BRANCH:begin
						  	if(bp_state == 2'b0) begin
								branchpd = 1'b0;
							end
							else if(bp_state == 2'b01) begin
								branchpd = 1'b0;
							end
							else if(bp_state == 2'b10) begin
								branchpd = 1'b1;
							end
							else begin
								branchpd = 1'b1;
							end
						end
						default:branchpd = 1'b0;
					endcase
		endfunction			
					




endmodule