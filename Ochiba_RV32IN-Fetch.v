module FETCH #(parameter WIDTH=32)
					(input clk,reset,IFREGclear,
					input [WIDTH-1:0]pcbranch,
					input pcwrcntl,
					output [WIDTH-1:0]pc,
					input  [WIDTH-1:0]nextinstrdata,
					output [WIDTH-1:0]REGFfetchdata,REGFpc,
					input [31:0]branchpdaddr,
					input branchpdans,
					input [31:0]nwsaddr,
					input nwsres,
					input IFREGstall);
									
										wire jdt;
					wire bdt;
					wire [31:0]jimm;
					wire [WIDTH-1:0]nextpc = pc + 4;
					wire [WIDTH-1:0]nextjmppc = pc + 4 + jimm;
					wire [WIDTH-1:0]muxnextpc;
					wire [31:0]pcbpdata,pcjpdata,pcnsdata;

					assign jimm[0]				=	1'b0;
					assign jimm[10:1]			=	nextinstrdata[30:21];
					assign jimm[11]			=	nextinstrdata[20];
					assign jimm[19:12]		=	nextinstrdata[19:12];
					assign jimm[20]			=	nextinstrdata[31];
					assign jimm[31:21]		=	{11{jimm[19]}};

										
					wire branchpd_mux = branchpdans & ~pcwrcntl;
				   
					
				   jdetect  jmpdetect(nextinstrdata,jdt,bdt);
					
						
					mux2		pcwrmux(nextpc,pcbranch,pcwrcntl,muxnextpc);
					mux2		pcbpmux(muxnextpc,branchpdaddr,branchpd_mux,pcbpdata);
					mux2		pcjpmux(pcbpdata,nextjmppc,jdt,pcjpdata);
					mux2		pcnsmux(pcjpdata,nwsaddr,nwsres,pcnsdata);
					ffrpc		pcreg(clk,reset,pcnsdata,pc);
					ffr		fetchreg(clk,IFREGclear,IFREGstall,nextinstrdata, REGFfetchdata);
					ffr		pcpipreg(clk,IFREGclear,IFREGstall,pc,REGFpc);
					
endmodule
