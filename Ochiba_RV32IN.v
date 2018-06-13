//-------------------------------------------------------
//
// Ochiba_RV32IM.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IN
//
// Topmodule of Ochiba_RV32IN
// Ochiba Processer
// RV32IN ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------

module Ochiba_RV32IN #(parameter WIDTH = 32)
				 (input inclk,inrst,
				 input rxfifoemp,
				 input [1047:0]ethernet_rx,
				 output ethernet_rx_re,
				 output [1047:0]ethernet_tx,
				 output ethernet_tx_we,				 
				 output [15:0] gpio);

				 
				wire	[31:0]	instr,address;
				wire				zero,wdataenable;
				wire	[1:0]		alusrca;
				wire	[1:0]		mem2reg;
				wire				iord, pcen, regwrite, regdest,reset,clk;	
				wire	[31:0]	memdata,writedata,mmemdata,dmemdata,instrmemdata,datamemdata,csrindata,csroutdata,instraddress,dataaddress;
				wire           memread, wenable,csrrw,denable,IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,Exnow,branch,branchpd;
				wire	[15:0]	adr,addr;
				wire	[11:0]	csraddr;
				wire   [1047:0]  writedata512,datamemdata512;
				wire   [2:0]    rcntl,wcntl;

				 assign reset = inrst;
                 assign clk = ~inclk;
				assign wdataenable = 0;

				Ochiba_RV32IN_cont controller(clk,reset,branch,IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,Exnow,branchpd);				
				Ochiba_RV32IN_dp dp(clk,reset,instrmemdata,instraddress,writedata,writedata512,dataaddress,rcntl,wcntl,wenable,datamemdata,datamemdata512,csraddr,csrindata,csroutdata,csrrw,IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,
										WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,Exnow,branch,branchpd,rxfifoemp,ethernet_rx_re,ethernet_rx,ethernet_tx_we,ethernet_tx);
				instr_ram		instr_ram(writedata,instraddress,clk,wdataenable,instrmemdata);
				data_ram			data_ram(writedata,dataaddress,clk,wenable,datamemdata);
				data_ram_1024	data_ram_1024(writedata512,dataaddress,clk,wenable,datamemdata512);
				gpio				gpio_cntl(dataaddress,writedata,clk,wenable,gpio);
				sysreg 	system_reg(clk,csrrw,reset,csraddr,csrindata,csroutdata);
				
					
	
			 
endmodule
				 