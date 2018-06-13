module WRITEBACK #(parameter WIDTH=32)
                 (   input [4:0]REGMrd,
				      input [WIDTH-1:0]REGMaluresult,REGMbranchimm,REGMpc,
				      input [1047:0]REGMaluresult_512,
				      input [1:0]REGMmem2reg,
				      input [1:0]REGMpcsource,
				      input [1:0]REGMbranchcntl,
					  input REGMregwrite,REGMzero,
				      input [WIDTH-1:0]REGMdmemdata,REGMcsrrdata,
				      input [1047:0]REGMdmemdata_512,
					  	input [1:0]REGMbpflag,
					  	input REGMflag512,
						output [4:0]regaddr,
						output [WIDTH-1:0]regwd,
						output regwe,
						output [3:0]reg512addr,
                        output [1047:0]reg512wd,
                        output reg512we,
                        output reg512_norm_we,
						output [WIDTH-1:0]dnextpc,
						output branchpcwe,
						output [1:0]branchpdres);
												
                  sel512_32      regsel(REGMflag512,REGMregwrite,REGMrd,regwe,regaddr,reg512_norm_we,reg512we,reg512addr);
						
						wire [WIDTH-1:0]pcbranch	=	REGMpc + 4 + REGMbranchimm;
						wire [WIDTH-1:0]pcnext	=	REGMpc + 4;
						wire [31:0]branchpcdata;
						wire [3:0]branchpc;
						wire branchpcsel;
						assign branchpc =  branchpcencntl(REGMbranchcntl,REGMzero,REGMbpflag);  //Branch PC Enable Control
						assign branchpcsel = branchpc[1];
						assign branchpdres = branchpc[3:2];
						assign branchpcwe = branchpc[0];
						
						mux2			pcbranchmux(pcbranch,pcnext,branchpcsel,branchpcdata);
						mux4			pcmux(32'b0,branchpcdata,REGMaluresult,32'b0,REGMpcsource,dnextpc);
						mux4			writedatamux(REGMaluresult,REGMdmemdata,REGMpc + 4,REGMcsrrdata,REGMmem2reg,regwd);
						mux4_512		writedatamux_512(REGMaluresult_512,REGMdmemdata_512,1032'b0,1032'b1,REGMmem2reg,reg512wd);						
						//Branch Controaller
						function [3:0]branchpcencntl;
						   input [1:0]branchcntl;
						   input zero;
							input [1:0]bpflag;
						
						    begin
						    case(branchcntl)
							    2'b00:branchpcencntl  =  4'b0000;	//the Others instructions
							    2'b01:begin	//Branch OPCODE
									case(bpflag)
										2'b00:begin
											 if(zero == 0) begin
												branchpcencntl	=	4'b0100;
												end
											 else begin
											 	branchpcencntl	=	4'b1001;
												end
											end
										2'b01:begin
											 if(zero == 0) begin
												branchpcencntl	=	4'b0100;
												end
											 else begin
											 	branchpcencntl	=	4'b1001;
												end
											end
										2'b10:begin
											 if(zero == 0) begin
												branchpcencntl	=	4'b0111;
												end
											 else begin
											 	branchpcencntl	=	4'b1000;
												end
											end
										2'b11:begin
											 if(zero == 0) begin
												branchpcencntl	=	4'b0111;
												end
											 else begin
											 	branchpcencntl	=	4'b1000;
												end
											end
										default:branchpcencntl = 4'b0;
										endcase
							    end
								2'b10: branchpcencntl = 4'b0001; //JALR
								2'b11: branchpcencntl = 4'b0000; //Others instructions
							   default:branchpcencntl = 4'b0;
						endcase
						end
					endfunction			
						
						
endmodule 