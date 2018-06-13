module MEMORYACCESS #(parameter WIDTH=32)
                  (input clk,MAREGclear,
						input [4:0]REGArd,
				      input [WIDTH-1:0]REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,
				      input [1047:0]REGAaluresult_512,REGAreg2data_512,
				      input [1:0]REGAmem2reg,
				      input [1:0]REGApcsource,
				      input [2:0]REGAllcntl,REGAslcntl,
				      input [1:0]REGAbranchcntl,
						input REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,
				      input [11:0]REGAcsraddr,
					  input  [1:0]REGAbpflag,
					  input REGAflag512,REGAnwstore,
					  output [4:0]REGMrd,
				      output [WIDTH-1:0]REGMaluresult,REGMbranchimm,REGMpc,
				      output [1047:0]REGMaluresult_512,
				      output [1:0]REGMmem2reg,
				      output [1:0]REGMpcsource,
				      output [1:0]REGMbranchcntl,
						output REGMregwrite,REGMzero,
				      output [WIDTH-1:0]REGMdmemdata,REGMcsrrdata,
				      output [1047:0]REGMdmemdata_512,
					  output [1:0]REGMbpflag,
					  output REGMflag512,
					  output [WIDTH-1:0]dmemwdata,
					  output [1047:0]dmemwdata_512,
					  output [WIDTH-1:0]dmemaddr,
					  output [2:0] rcntl,wcntl,
					  output wenable,
					  input  [WIDTH-1:0]dmemrdata,
                  input  [1047:0]dmemrdata_512,
						input  [31:0]csrreaddata,
						output [31:0]csroutputdata,
						output [11:0]csraddr,
						output csrwe,
						output [1047:0]nwstore,
						output nwstoreen,
						input  MAREGstall);
												
						wire [WIDTH-1:0]dataaddress,memrdata;
						wire             zero;
					
						assign dmemaddr = dataaddress;
						assign wenable   = REGAwenable;
						assign dmemwdata = REGAreg2data;
					    assign dmemwdata_512 = REGAreg2data_512;
					    assign rcntl = REGAllcntl;
					    assign wcntl = REGAslcntl;
						 assign nwstore = REGAaluresult_512;
						 assign nwstoreen = REGAnwstore;
						
					mux2			adressmux(REGApc,REGAaluresult,REGAiord,dataaddress);
						
					//dmemwdata    ……書き込み?��?��?ータ(ビット長変換前�??��To?��?��?ータメモリ)
					//REGAreg2data ……書き込み?��?��?ータ(ビット長変換前�??��Fromレジスタ2)
					//dmemrdata    ……読み込み?��?��?ータ(ビット長変換前�??��From?��?��?ータメモリ)
					//memrdata     ……読み込み?��?��?ータ(ビット長変換後�??��To WBス?��?��?ージ)
					//widthcntl	lw(dmemrdata,REGAllcntl,memrdata);
					//widthcntl	sw(REGAreg2data,REGAslcntl,dmemwdata);	
					
					zero			zerochk(REGAaluresult,zero);
					
					//CSRレジスタもここから触ることにしま?��?��? が細かい実�?��?はこんど
                    assign csroutputdata = REGAaluresult;
					assign csraddr = REGAcsraddr;
					assign csrwe = REGAcsrrw;
						
				//ここから下�??����?ータパス
					ffr5 REGrd         (clk,MAREGclear,MAREGstall,REGArd,REGMrd);
					ffr  REGaluresult  (clk,MAREGclear,MAREGstall,REGAaluresult,REGMaluresult);
					ffr512 REGaluresult_512 (clk,MAREGclear,MAREGstall,REGAaluresult_512,REGMaluresult_512);
					ffr  REGdmemdata   (clk,MAREGclear,MAREGstall,dmemrdata,REGMdmemdata);
					ffr512 REGdmemdata_512 (clk,MAREGclear,MAREGstall,dmemrdata_512,REGMdmemdata_512);
					ffr  REGcsrdata    (clk,MAREGclear,MAREGstall,csrreaddata,REGMcsrrdata);
					ffr  REGbranchimm  (clk,MAREGclear,MAREGstall,REGAbranchimm,REGMbranchimm);
					ffr  REGpc         (clk,MAREGclear,MAREGstall,REGApc,REGMpc);
				//ここまで
				
				//ここから下�??����?コー?��?��?出?��?��?	
					ffr2  REGmem2reg  (clk,MAREGclear,MAREGstall,REGAmem2reg,REGMmem2reg);
					ffr1  REGregwrite (clk,MAREGclear,MAREGstall,REGAregwrite,REGMregwrite);
					ffr2  REGpcsource (clk,MAREGclear,MAREGstall,REGApcsource,REGMpcsource);
					ffr2  REGbrcntl   (clk,MAREGclear,MAREGstall,REGAbranchcntl,REGMbranchcntl);
					ffr1  REGzero     (clk,MAREGclear,MAREGstall,zero,REGMzero);
					ffr2  REGbpflag   (clk,MAREGclear,MAREGstall,REGAbpflag,REGMbpflag);
					ffr1  REGflag512  (clk,MAREGclear,MAREGstall,REGAflag512,REGMflag512);
				//ここまで

endmodule
