module REGISTERFILE #(parameter WIDTH=32)(
					input clk,RFREGclear,
					input [4:0]REGDrs1,REGDrs2,REGDrd,
					input [WIDTH-1:0]REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,
					input [1:0]REGDregfwda,REGDregfwdb,REGDalusrca,
					input [3:0]REGDalusrcb,
					input [1:0]REGDmem2reg,
					input [3:0]REGDalucont,
					input [1:0]REGDpcsource,
					input REGDiord,
					input [2:0]REGDllcntl,REGDslcntl,
					input REGDalusel,
					input [1:0]REGDbranchcntl,
					input REGDregwrite,REGDwenable,REGDcsrrw,
					input [11:0]REGDcsraddr,
					input [1:0]REGDbpflag,
					input REGDflag512,
					input REGDnwload,REGDnwstore,
					output [4:0]REGRrd,
					output [WIDTH-1:0]REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg2data,
					output [1:0]REGRregfwda,REGRregfwdb,REGRmem2reg,
					output [1047:0]REGRsrc1_512,REGRsrc2_512,REGRreg2data_512,
					output [3:0]REGRalucont,
					output [1:0]REGRpcsource,
					output [2:0]REGRllcntl,REGRslcntl,
					output REGRalusel,
					output [1:0]REGRbranchcntl,
					output REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,
					output [11:0]REGRcsraddr,
					output [1:0]REGRbpflag,
					output REGRflag512,REGRnwstore,//REGRfifotx,REGRfiforx,
					output [4:0]ra1,ra2,
					output [3:0]ra1_512,ra2_512,
					input	 [WIDTH-1:0]rd1,rd2,
					input  [1047:0]normreg_rd512,rd1_512,rd2_512,
					output fiforeaden,
					input  [1047:0]fifoindata,
					input RFREGstall);
					
					wire [4:0]ra1_512a,ra2_512a;
//					assign ra1 = REGDrs1;
//					assign ra2 = REGDrs2;
					assign ra1_512 = ra1_512a[3:0];
					assign ra2_512 = ra2_512a[3:0];
					assign fiforeaden = REGDnwload;
					mux2_ra regsrcmux1(REGDrs1,REGDflag512,ra1,ra1_512a);
					mux2_ra regsrcmux2(REGDrs2,REGDflag512,ra2,ra2_512a);

					wire [WIDTH-1:0] src1,src2;
					
					parameter const_zero =	32'b0; //ゼロ
					parameter const_one	=	32'b1; //0xFFFFFFFF
					
					wire [WIDTH-1:0] fwdreg1,fwdreg2,fwdreg3,data1,data2;
					wire [1047:0] regdata512_1,regdata512_2,src1_512,src2_512;
					
					mux4			src1mux(rd1,REGDpc,32'b0,32'b0,REGDalusrca,src1);
					mux16			src2mux(rd2,32'b1,REGDimm,REGDjimm,REGDstoreimm,REGDluiimm,32'b0,REGDcsrimm,
					32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,REGDalusrcb,src2);
					mux2_512       reg512mux_1(rd1_512,normreg_rd512,ra1_512a[4],regdata512_1);
					mux2_512       reg512mux_2(rd2_512,normreg_rd512,ra2_512a[4],regdata512_2);
				   mux4_512        src1mux_512(regdata512_1,normreg_rd512,1048'b0,1048'b1,REGDalusrca,src1_512);
					mux4_512        src2mux_512(regdata512_2,normreg_rd512,1048'b0,fifoindata,REGDalusrcb[1:0],src2_512);
										
					//ここから下�????��?��??��?��??��?��?ータパス
					ffr5 REGrd         (clk,RFREGclear,RFREGstall,REGDrd,REGRrd);
					ffr  REGsrc1       (clk,RFREGclear,RFREGstall,src1,REGRalua);
					ffr  REGsrc2       (clk,RFREGclear,RFREGstall,src2,REGRalub);
					ffr512  REGsrc1_512       (clk,RFREGclear,RFREGstall,src1_512,REGRsrc1_512);
               ffr512  REGsrc2_512       (clk,RFREGclear,RFREGstall,src2_512,REGRsrc2_512);
					ffr  REGbranchimm  (clk,RFREGclear,RFREGstall,REGDbranchimm,REGRbranchimm);
					ffr  REGpc         (clk,RFREGclear,RFREGstall,REGDpc,REGRpc);
              	ffr  REGreg2data   (clk,RFREGclear,RFREGstall,rd2,REGRreg2data);
              	ffr512 REGreg2data_512 (clk,RFREGclear,RFREGstall,rd2_512,REGRreg2data_512);
				   //ここまで
				
				//ここから下�????��?��??��?��??��?��?コー???��?��??��?��???��?��??��?��?出???��?��??��?��???��?��??��?��?	
					ffr2  REGregfwda  (clk,RFREGclear,RFREGstall,REGDregfwda,REGRregfwda);
					ffr2  REGregfwdb  (clk,RFREGclear,RFREGstall,REGDregfwdb,REGRregfwdb);
					ffr2  REGmem2reg  (clk,RFREGclear,RFREGstall,REGDmem2reg,REGRmem2reg);
					ffr1  REGregwrite (clk,RFREGclear,RFREGstall,REGDregwrite,REGRregwrite);
					ffr1  REGalusel   (clk,RFREGclear,RFREGstall,REGDalusel,REGRalusel);
					ffr4  REGalucont  (clk,RFREGclear,RFREGstall,REGDalucont,REGRalucont);
					ffr2  REGpcsource (clk,RFREGclear,RFREGstall,REGDpcsource,REGRpcsource);
					ffr1  REGiord     (clk,RFREGclear,RFREGstall,REGDiord,REGRiord);
					ffr3  REGllcntl   (clk,RFREGclear,RFREGstall,REGDllcntl,REGRllcntl);
					ffr3  REGslcntl   (clk,RFREGclear,RFREGstall,REGDslcntl,REGRslcntl);
					ffr2  REGbrcntl   (clk,RFREGclear,RFREGstall,REGDbranchcntl,REGRbranchcntl);
					ffr1  wenable     (clk,RFREGclear,RFREGstall,REGDwenable,REGRwenable);
					ffr1  REGcsrrw    (clk,RFREGclear,RFREGstall,REGDcsrrw,REGRcsrrw);
					ffr12 REGcsraddr  (clk,RFREGclear,RFREGstall,REGDcsraddr,REGRcsraddr);
					ffr2  REGbpflag   (clk,RFREGclear,RFREGstall,REGDbpflag,REGRbpflag);
					ffr1  REGflag512  (clk,RFREGclear,RFREGstall,REGDflag512,REGRflag512);
					ffr1  REGnwstore  (clk,RFREGclear,RFREGstall,REGDnwstore,REGRnwstore);
				//ここまで		
			
			
endmodule