`timescale 1ns / 1ps
//-------------------------------------------------------
//
// Shinku_NPU.v
// Sodium(sodium@wide.sfc.ad.jp)
// Main Processor: Ochiba RV32IN
// Instruction set:RISC-V RV32IN
//
// Topmodule of Shinku NPU
// RV32IN ISA Model
//
//-------------------------------------------------------


module Shinku_NPU(input clk,rst,
                input [255:0]rdata,
                input [31:0]rkeep,
                input [127:0]ruser,
                input rvalid,
                output rready,
                input rlast,
                output [255:0]tdata,
                output [31:0]tkeep,
                output [127:0]tuser,
                output tvalid,
                input  tready,
                output tlast,                
				 output [15:0] gpio);
				 
				 
		wire [1047:0] ethernet_rx,ethernet_tx;
		 wire        ethernet_rx_re,ethernet_tx_we;
		 wire rxfifofull,rxfifoemp,txfifofull,txfifoemp,txfifore,rxfifowe,rxfifofull_0,rxfifofull_1,txfifofull_0,txfifofull_1,rxfifoemp_0,rxfifoemp_1,txfifoemp_0,txfifoemp_1;
		 wire [1047:0] rx_fifo_in,tx_fifo_out;
		 
		 assign rxfifofull = rxfifofull_1 && rxfifofull_0;
		 assign rxfifoemp = rxfifoemp_1 && rxfifoemp_0;
		 assign txfifofull = txfifofull_1 && txfifofull_0;
         assign txfifoemp = txfifoemp_1 && txfifoemp_0;		 
		 		 
       Ochiba_RV32IN Ochiba(clk,rst,rxfifoemp,ethernet_rx,ethernet_rx_re,ethernet_tx,ethernet_tx_we,gpio);
        fifo_generator_0 rx_fifo(clk,rst,rx_fifo_in[1047:24],rxfifowe,ethernet_rx_re,ethernet_rx[1047:24],rxfifofull_0,rxfifoemp_0);
        fifo_generator_0 tx_fifo(clk,rst,ethernet_tx[1047:24],ethernet_tx_we,txfifore,tx_fifo_out[1047:24],txfifofull_0,txfifoemp_0);
        fifo_generator_1 rx_fifo_1(clk,rst,rx_fifo_in[23:0],rxfifowe,ethernet_rx_re,ethernet_rx[23:0],rxfifofull_1,rxfifoemp_1);
        fifo_generator_1 tx_fifo_1(clk,rst,ethernet_tx[23:0],ethernet_tx_we,txfifore,tx_fifo_out[23:0],txfifofull_1,txfifoemp_1);
        FIFOcntl_rx fifocntl_rx(clk,rst,rdata,rkeep,ruser,rvalid,rready,rlast,rxfifofull,rxfifowe,rx_fifo_in);
		FIFOcntl_tx fifocntl_tx(clk,rst,tdata,tkeep,tuser,tvalid,tready,tlast,txfifoemp,txfifore,tx_fifo_out);
		 
//		 assign ethernet_rx = 1032'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007e5a6001056fce83442b293e4bf42fbb1008108a0c24a24f868729604300049fe58200005400800117eefa4287c27141ac508600;
        
            		 
endmodule
