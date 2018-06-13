`timescale 1ns / 1ps
//-------------------------------------------------------
//
// Shinku_NPU-FIFOcntl_rx.v
// Sodium(sodium@wide.sfc.ad.jp)
// Main Processor: Ochiba RV32IN
// Instruction set:RISC-V RV32IN
//
// N/W FIFO&AXI4 rx-control module for 10GbE
//  AXI4 bitwidth = 256bit;
// RV32IN ISA Model
//
//-------------------------------------------------------

module FIFOcntl_rx(input inclk,inrst,
				input  [255:0]rdata,
				input  [31:0]rkeep,
				input  [127:0]ruser,
				input  rvalid,
				output rready,
				input  rlast,
				input  rxfifofull,
				output rxfifowe,
				output [1047:0]rx_fifo);
		
		reg [7:0]enable;
		wire regflush,bufwe0,bufwe1,bufwe2,bufwe3,bufwe4;
		wire [7:0]nowenable;
		reg [4:0]nextstate;
		reg [7:0]cntl;
		wire [15:0]atesaki;
		
//		assign cntl = control_rx(state,rxfifofull,rlast,ruser,rvalid);
		assign rready = cntl[7];
		assign rxfifowe = cntl[6];
		assign bufwe0 = cntl[5];
		assign bufwe1 = cntl[4];
		assign bufwe2 = cntl[3];
		assign bufwe3 = cntl[2];
		assign bufwe4 = cntl[1];
		assign regflush = cntl[0];
//		assign ruser[127:32] = 96'b0;
		assign atesaki = ruser[31:16];
//		assign nextstate = cntl[4:0];
//		assign nowenable = enable(rkeep,rlast,rvalid,lastenable);
		
		bufram8_rx buffer_ram_en(inclk,inrst||regflush,bufwe0,enable,rx_fifo[7:0]);
		bufram16_rx buffer_ram_atesaki(inclk,inrst||regflush,bufwe1,atesaki,rx_fifo[23:8]);
		bufram256_rx buffer_ram_0(inclk,inrst||regflush,bufwe1,rdata,rx_fifo[279:24]);
		bufram256_rx buffer_ram_1(inclk,inrst||regflush,bufwe2,rdata,rx_fifo[535:280]);
		bufram256_rx buffer_ram_2(inclk,inrst||regflush,bufwe3,rdata,rx_fifo[791:536]);
		bufram256_rx buffer_ram_3(inclk,inrst||regflush,bufwe4,rdata,rx_fifo[1047:792]);


		initial begin
			nextstate <= 4'b0;
			enable <= 8'b0;
			end
		
/*		always @(posedge inclk)begin
			rdata <= rdata;
			rkeep <= rkeep;
			ruser <= ruser;
			rvalid <= rvalid;
			rlast <= rlast;
		end
	*/	
		always @(posedge inclk)begin
			if(inrst || regflush) enable <= 8'b0;
			if(rvalid == 1'b1)begin
					case(rlast)
						1'b0: enable <= enable + 8'b0010_0000;
						1'b1:begin						
							case(rkeep)
								32'b00000000_00000000_00000000_00000001: enable <= enable;
                        32'b00000000_00000000_00000000_00000011: enable <= enable + 8'h1; 
                        32'b00000000_00000000_00000000_00000111: enable <= enable + 8'h2;
                        32'b00000000_00000000_00000000_00001111: enable <= enable + 8'h3;
                        32'b00000000_00000000_00000000_00011111: enable <= enable + 8'h4;
                        32'b00000000_00000000_00000000_00111111: enable <= enable + 8'h5; 
                        32'b00000000_00000000_00000000_01111111: enable <= enable + 8'h6;
                        32'b00000000_00000000_00000000_11111111: enable <= enable + 8'h7; 
                        32'b00000000_00000000_00000001_11111111: enable <= enable + 8'h8;
                        32'b00000000_00000000_00000011_11111111: enable <= enable + 8'h9; 
                        32'b00000000_00000000_00000111_11111111: enable <= enable + 8'ha;
                        32'b00000000_00000000_00001111_11111111: enable <= enable + 8'hb; 
                        32'b00000000_00000000_00011111_11111111: enable <= enable + 8'hc;
                        32'b00000000_00000000_00111111_11111111: enable <= enable + 8'hd; 
                        32'b00000000_00000000_01111111_11111111: enable <= enable + 8'he;
                        32'b00000000_00000000_11111111_11111111: enable <= enable + 8'hf; 
								32'b00000000_00000001_11111111_11111111: enable <= enable + 8'h10;
                        32'b00000000_00000011_11111111_11111111: enable <= enable + 8'h11; 
                        32'b00000000_00000111_11111111_11111111: enable <= enable + 8'h12;
                        32'b00000000_00001111_11111111_11111111: enable <= enable + 8'h13;
                        32'b00000000_00011111_11111111_11111111: enable <= enable + 8'h14;
                        32'b00000000_00111111_11111111_11111111: enable <= enable + 8'h15; 
                        32'b00000000_01111111_11111111_11111111: enable <= enable + 8'h16;
                        32'b00000000_11111111_11111111_11111111: enable <= enable + 8'h17; 
                        32'b00000001_11111111_11111111_11111111: enable <= enable + 8'h18;
                        32'b00000011_11111111_11111111_11111111: enable <= enable + 8'h19; 
                        32'b00000111_11111111_11111111_11111111: enable <= enable + 8'h1a;
                        32'b00001111_11111111_11111111_11111111: enable <= enable + 8'h1b; 
                        32'b00011111_11111111_11111111_11111111: enable <= enable + 8'h1c;
                        32'b00111111_11111111_11111111_11111111: enable <= enable + 8'h1d; 
                        32'b01111111_11111111_11111111_11111111: enable <= enable + 8'h1e;
                        32'b11111111_11111111_11111111_11111111: enable <= enable + 8'h1f; 
                        default: enable <= enable;
							endcase
							end
						default: enable <= enable;
					endcase
				end else enable <= 8'b0;
		end

		always @(posedge inclk)begin
				case(nextstate)
													//rready_fifowe_reg0we_reg1we_reg2we_reg3we_reg4we_regrst_nextstate(5)
                        5'h0:begin
									case(rvalid)
										1'b0:begin
												cntl <= 8'b1_0_0_0_0_0_0_0;
												nextstate <= 5'b00000;
												end
										1'b1:begin
											case(rlast)
												1'b0:begin 
														cntl <= 8'b1_0_0_1_0_0_0_0;
														nextstate <= 5'b00001;
														end
												1'b1:begin
																cntl <= 8'b1_0_1_1_0_0_0_0;
																nextstate <= 5'b00100;//good frame
																end
												default:begin
														cntl <= 8'b1_0_0_1_0_0_0_0;
														nextstate <= 5'b00000;
														end
											endcase
										end
										default:begin
											cntl <= 8'b1_0_0_0_0_0_0_0;
											nextstate <= 5'b00000;
										end
									endcase
									end
									
                        5'h1:begin
									case(rvalid)
										1'b0:begin
												cntl <= 8'b1_0_0_0_0_0_0_0;
												nextstate <= 5'b00001;
												end
										1'b1:begin
											case(rlast)
												1'b0:begin
														cntl <= 8'b1_0_0_0_1_0_0_0;
														nextstate <= 5'b00010;
														end
												1'b1:begin
															cntl <= 8'b1_0_1_0_1_0_0_0;
															nextstate <= 5'b00100;//good
													end
												default:begin
														cntl <= 8'b1_0_0_0_1_0_0_0;
														nextstate <= 5'b00010;
														 end
											endcase
										end
										default:begin
											cntl <= 8'b1_0_0_0_0_0_0_0;
											nextstate <= 5'b00001;
											end
									endcase
								end
								
                        5'h2:begin
									case(rvalid)
										1'b0:begin
											cntl <= 8'b1_0_0_0_0_0_0_0;
											nextstate <= 5'b00010;
												end
										1'b1:begin
											case(rlast)
												1'b0:begin
														cntl <= 8'b1_0_0_0_0_1_0_0;
														nextstate <= 5'b00011;
														end
												1'b1:begin
															cntl <= 8'b1_0_1_0_0_1_0_0;
															nextstate <= 5'b00100;//good
													end
												default:begin
													cntl <= 8'b1_0_0_0_0_1_0_0;
													nextstate <= 00010;
													end
											endcase
										end
										default:begin
										cntl <= 8'b1_0_0_0_0_0_0_0;
										nextstate <= 00010;
										end
									endcase
									end
								
								5'h3:begin
									case(rvalid)
										1'b0:begin
													cntl <= 8'b1_0_0_0_0_0_0_0;
													nextstate <= 5'b00011;
												end
										1'b1:begin
											case(rlast)
												1'b0:begin
													cntl <= 8'b0_0_0_0_0_0_1_0;
													nextstate <= 5'b00111;
														end
												1'b1:begin
												    if(rkeep < 32'h0FFFF_FFFF)begin
															cntl <= 8'b1_0_1_0_0_0_1_0;
															nextstate <= 5'b00100;//good
													   end else begin
													   cntl <= 8'b0_0_0_0_0_0_1_0;
                                                          nextstate <= 5'b00111;
													   end
													end
												default:begin
													cntl <= 8'b1_0_0_0_0_0_1_0;
													nextstate <= 5'b00100;
													end
											endcase
										end
										default:begin
										cntl <= 8'b1_0_0_0_0_0_0;
										nextstate <= 5'b00100;
										end
									endcase
								end
								
								5'h4:begin
									cntl <= 8'b0_0_0_0_0_0_0_0;
									nextstate <= 5'b00101;
									end
								
								5'h5:begin
									case(rxfifofull)
										1'b0:begin
											cntl <= 8'b0_1_0_0_0_0_0_0;
											nextstate <= 5'b00110;
												end
										1'b1:begin
											cntl <= 8'b0_0_0_0_0_0_0_0;
											nextstate <= 5'b00101;
												end
									endcase
								end
								
								5'h6:begin
									cntl <= 8'b1_0_0_0_0_0_0_1;
									nextstate <= 5'b00000;
									end
									
								5'h7:begin
									cntl <= 8'b1_0_0_0_0_0_0_1;
									nextstate <= 5'b00000;
									end
                       
								default:begin
									cntl <= 8'b1_0_0_0_0_0_0_1;
									nextstate <= 5'b00000; 
								end
                    endcase
					end

		
endmodule

module bufram16_rx(input clk,rst,wenable,
                 input [15:0]indata,
                 output reg [15:0]outdata);
                 
                 reg [15:0]ram;
                 
         always @(negedge clk)
                 begin
                 if(rst == 1'b1) ram <= 16'b0;
                 // Write
                     if (wenable == 1) ram <= indata;
                 //read
                    outdata <= ram;        
                 end
                 
endmodule

module bufram256_rx(input clk,rst,wenable,
                 input [255:0]indata,
                 output reg [255:0]outdata);
                 
                 reg [255:0]ram;
                 
         always @(negedge clk)
                 begin
							if(rst == 1'b1) ram <= 256'b0;
                 // Write
                     if (wenable == 1) ram <= indata;
                 //read
                    outdata <= ram;        
                 end
                 
endmodule

module bufram8_rx(input clk,rst,wenable,
                 input [7:0]indata,
                 output reg [7:0]outdata);
                 
                 reg [7:0]ram;
                 
         always @(negedge clk)
                 begin
					  		if(rst == 1'b1) ram <= 8'b0;
                 // Write
                     if (wenable == 1) ram <= indata;
                 //read
                    outdata <= ram;        
                 end
                 
endmodule
