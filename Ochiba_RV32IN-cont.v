//-------------------------------------------------------
//
// Ochiba_RV32IN-cont.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IN
//
// Ochiba Processer RV32IN model
// Datapath/Pipeline Controller
//
//-------------------------------------------------------


module Ochiba_RV32IN_cont 		(input clk,reset,branch,
								output IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,
								input Exnow,branchpd);
										
				assign IFREGclear = branch | branchpd;
				assign IDREGclear = branch;
				assign RFREGclear = branch;
				assign ExREGclear = branch | Exnow;
				assign MAREGclear = branch;
				assign WBREGclear = branch;
				
			    assign IFREGstall = Exnow ? 1'b1 : 1'b0;
			    assign IDREGstall = Exnow ? 1'b1 : 1'b0;
			    assign RFREGstall = Exnow ? 1'b1 : 1'b0;
			    assign ExREGstall = 1'b0;
			    assign MAREGstall = 1'b0;
			    

endmodule
