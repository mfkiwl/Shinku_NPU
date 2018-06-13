`timescale 1ns / 1ps
//-------------------------------------------------------
//
// Shinku_NPU-FIFOcntl_tx.v
// Sodium(sodium@wide.sfc.ad.jp)
// Main Processor: Ochiba RV32IN
// Instruction set:RISC-V RV32IN
//
//  N/W FIFO&AXI4 tx-control module for 10GbE
//  AXI4 bitwidth = 256bit;
// RV32IN ISA Model
//
//-------------------------------------------------------


module FIFOcntl_tx(input inclk,inrst,
				output [255:0]tdata,
				output [31:0]tkeep,
				output [127:0]tuser,
				output tvalid,
				input  tready,
				output  tlast,
				input  txfifoemp,
				output txfifore,
				input [1047:0]tx_fifo);
		
		reg [4:0]state;
		wire bufwenable;
		
		wire [32:0]tkeepdata;
		wire [7:0]outdata;
		wire [15:0]outdata_atesaki;
		wire [255:0]outdata_1,outdata_2,outdata_3,outdata_4;
		wire [15:0]cntl;
		wire [4:0]nextstate;
		

		assign cntl  = control_tx(outdata,state,txfifoemp,tready);
		assign tkeep = enable(cntl[5:0]);
		assign tlast = cntl[13];
		assign tuser[15:0] = tusercalc(outdata);
		assign tuser[31:16] = outdata_atesaki;
		assign tuser[127:32] = 96'b0;
		assign tvalid = cntl[14];
		assign txfifore = cntl[12];
		assign bufwenable = cntl[11];
		assign nextstate = cntl[10:6];
		assign tdata = txdatamux(outdata_1,outdata_2,outdata_3,outdata_4,state);
		
		bufram8 buffer_ram_en(inclk,inrst,bufwenable,tx_fifo[7:0],outdata);
		bufram16 buffer_ram_ikisaki(inclk,inrst,bufwenable,tx_fifo[23:8],outdata_atesaki);
		
		bufram256 buffer_ram_0(inclk,inrst,bufwenable,tx_fifo[279:24],outdata_1);
		bufram256 buffer_ram_1(inclk,inrst,bufwenable,tx_fifo[535:280],outdata_2);
		bufram256 buffer_ram_2(inclk,inrst,bufwenable,tx_fifo[791:536],outdata_3);
		bufram256 buffer_ram_3(inclk,inrst,bufwenable,tx_fifo[1047:792],outdata_4);

		always @(posedge inclk)begin
			if(inrst)state <= 5'b0;
			else state <= nextstate;
		end
		

		
		function [15:0]tusercalc;
		         input [7:0]cntl;
		      		         
		         begin
		          if(cntl[6:5] == 2'b11)begin
		              tusercalc = 16'b00000000_0010_0000 + 16'b00000000_0010_0000 + 16'b00000000_0010_0000 + cntl[4:0]+ 16'd00000000_0000_0001;
		          end
		          else if(cntl[6:5] == 2'b10)begin
                      tusercalc = 16'b00000000_0010_0000 + 16'b00000000_0010_0000 + cntl[4:0]+ 16'd00000000_0000_0001;
                  end
                  else if(cntl[6:5] == 2'b01)begin
                      tusercalc = 16'b00000000_0010_0000 + cntl[4:0]+ 16'd00000000_0000_0001;
                  end
                  else if(cntl[6:5] == 2'b00)begin
                      tusercalc = cntl[4:0]+ 16'd00000000_0000_0001;
                  end else begin
                   tusercalc = cntl[4:0]+ 16'd00000000_0000_0001;
                   end
		         end
		endfunction
		
		function [255:0] txdatamux;
		        input [255:0]data0,data1,data2,data3;
		        input [4:0]state;
		        
		        begin
                case (state)
                    5'h2: txdatamux    = data0;
                    5'h3: txdatamux    = data1;
                    5'h4: txdatamux    = data2;
                    5'h5: txdatamux    = data3;
                    default: txdatamux = data0; 
                endcase
		        end
		
		endfunction
		
		function [31:0]enable;
					input [5:0]data;
						begin
							 case(data)
									6'h0:enable = 32'b00000000_00000000_00000000_00000001;
                                    6'h1:enable = 32'b00000000_00000000_00000000_00000011; 
                                    6'h2:enable = 32'b00000000_00000000_00000000_00000111;
                                    6'h3:enable = 32'b00000000_00000000_00000000_00001111;
                                    6'h4:enable = 32'b00000000_00000000_00000000_00011111;
                                    6'h5:enable = 32'b00000000_00000000_00000000_00111111; 
                                    6'h6:enable = 32'b00000000_00000000_00000000_01111111;
                                    6'h7:enable = 32'b00000000_00000000_00000000_11111111; 
                                    6'h8:enable = 32'b00000000_00000000_00000001_11111111;
                                    6'h9:enable = 32'b00000000_00000000_00000011_11111111; 
                                    6'ha:enable = 32'b00000000_00000000_00000111_11111111;
                                    6'hb:enable = 32'b00000000_00000000_00001111_11111111; 
                                    6'hc:enable = 32'b00000000_00000000_00011111_11111111;
                                    6'hd:enable = 32'b00000000_00000000_00111111_11111111; 
                                    6'he:enable = 32'b00000000_00000000_01111111_11111111;
                                    6'hf:enable = 32'b00000000_00000000_11111111_11111111; 
                                    6'h10:enable = 32'b00000000_00000001_11111111_11111111;
                                    6'h11:enable = 32'b00000000_00000011_11111111_11111111; 
                                    6'h12:enable = 32'b00000000_00000111_11111111_11111111;
                                    6'h13:enable = 32'b00000000_00001111_11111111_11111111;
                                    6'h14:enable = 32'b00000000_00011111_11111111_11111111;
                                    6'h15:enable = 32'b00000000_00111111_11111111_11111111; 
                                    6'h16:enable = 32'b00000000_01111111_11111111_11111111;
                                    6'h17:enable = 32'b00000000_11111111_11111111_11111111; 
                                    6'h18:enable = 32'b00000001_11111111_11111111_11111111;
                                    6'h19:enable = 32'b00000011_11111111_11111111_11111111; 
                                    6'h1a:enable = 32'b00000111_11111111_11111111_11111111;
                                    6'h1b:enable = 32'b00001111_11111111_11111111_11111111; 
                                    6'h1c:enable = 32'b00011111_11111111_11111111_11111111;
                                    6'h1d:enable = 32'b00111111_11111111_11111111_11111111; 
                                    6'h1e:enable = 32'b01111111_11111111_11111111_11111111;
                                    6'h1f:enable = 32'b11111111_11111111_11111111_11111111;
												6'H3f:enable = 32'b0;
                                    default: enable = 32'b0;
                                 endcase
										end
		endfunction
						
		
		function [14:0]control_tx;
                input [7:0] tkeepdata;
                input [4:0] state;
					 input txemp;
					 input tready;
                
                begin
                    case(state)
													//tvalid_tlast_fifore_regwe_nextstate(5)_en(6)
                        5'h0:begin
									case(txemp)
										1'b0:control_tx = 15'b0_0_1_1_00001_111111;
										1'b1:control_tx = 15'b0_0_1_1_00000_111111;
									endcase
								end
						5'h1:control_tx = 15'b0_0_0_0_00010_111111;
                        5'h2:begin
                            case(tkeepdata[6:5])
                                2'b0:begin
												case(tready)
													1'b0:begin
														control_tx[14:5] = 10'b1_1_0_0_00010_0;
														control_tx[4:0] = tkeepdata[4:0];
														end
													1'b1:begin
														control_tx[14:5] = 10'b1_1_0_0_00000_0;
														control_tx[4:0] = tkeepdata[4:0];
														end
												endcase
                                 end
                              default:begin
											case(tready)
												1'b0:control_tx = 15'b1_0_0_0_00010_011111; 
												1'b1:control_tx = 15'b1_0_0_0_00011_011111; 
											endcase
										end
                           endcase
                        end
                        5'h3:begin
                            case(tkeepdata[6:5])
                                2'b01:begin
												case(tready)
													1'b0:begin
														control_tx[14:5] = 10'b1_1_0_0_00011_0;
                                                        control_tx[4:0] = tkeepdata[4:0];
														end
													1'b1:begin
														control_tx[14:5] = 10'b1_1_0_0_00000_0;
                                                        control_tx[4:0] = tkeepdata[4:0];

														end
												endcase
                                 end
                              default:begin
											case(tready)
												1'b0:control_tx = 15'b1_0_0_0_00011_011111; 
												1'b1:control_tx = 15'b1_0_0_0_00100_011111; 
											endcase
										end
                           endcase
                        end
                        5'h4:begin
                            case(tkeepdata[6:5])
                                2'b10:begin
												case(tready)
													1'b0:begin
														control_tx[14:5] = 10'b1_1_0_0_00100_0;
														control_tx[4:0] = tkeepdata[4:0];
														end
													1'b1:begin
														control_tx[14:5] = 10'b1_1_0_0_00000_0;
														control_tx[4:0] = tkeepdata[4:0];
														end
												endcase
                                 end
                              default:begin
											case(tready)
												1'b0:control_tx = 15'b1_0_0_0_00100_011111; 
												1'b1:control_tx = 15'b1_0_0_0_00101_011111; 
											endcase
										end
                           endcase
                        end
                        5'h5:begin
                            case(tkeepdata[6:5])
                                2'b10:begin
												case(tready)
													1'b0:begin
													control_tx[14:5] = 10'b1_1_0_0_00101_0;
                                                    control_tx[4:0] = tkeepdata[4:0];

														end
													1'b1:begin
														control_tx[14:5] = 10'b1_1_0_0_00000_0;
                                                    control_tx[4:0] = tkeepdata[4:0];
														end
												endcase
                                 end
                              default:begin
											case(tready)
												1'b0:control_tx = 15'b1_1_0_0_00101_011111; 
												1'b1:control_tx = 15'b1_1_0_0_00000_011111; 
											endcase
										end
                           endcase
                        end
								default:begin
									control_tx = 15'b0_0_0_0_00000_000000; 
								end
                    endcase
                end
            endfunction
		
endmodule

module bufram256(input clk,rst,wenable,
                 input [255:0]indata,
                 output reg [255:0]outdata);
                 
                 reg [255:0]ram;
                 
         always @(posedge clk)
                 begin
                 if(rst == 1'b1) ram <= 8'b0;
                 // Write
                     if (wenable == 1) ram <= indata;
                 //read
                    outdata <= ram;        
                 end
                 
endmodule

module bufram16(input clk,rst,wenable,
                 input [15:0]indata,
                 output reg [15:0]outdata);
                 
                 reg [15:0]ram;
                 
         always @(posedge clk)
                 begin
                 if(rst == 1'b1) ram <= 16'b0;
                 // Write
                     if (wenable == 1) ram <= indata;
                 //read
                    outdata <= ram;        
                 end
                 
endmodule

module bufram8(input clk,rst,wenable,
                 input [7:0]indata,
                 output reg [7:0]outdata);
                 
                 reg [7:0]ram;
                 
         always @(posedge clk)
                 begin
                 if(rst == 1'b1) ram <= 8'b0;
                 // Write
                     if (wenable == 1) ram <= indata;
                 //read
                    outdata <= ram;        
                 end
                 
endmodule
