//-------------------------------------------------------
// Ochiba_RV32IM.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IM
//
// Testbench of Ochiba Processer
//-------------------------------------------------------
`timescale 1ns/10ps

// top level design for testing
module test #(parameter WIDTH = 31, REGBITS = 3)();

   reg                 clk;
   reg                 reset;
	reg					  [255:0]rdata;
	reg                 [31:0]rkeep;
	reg       [127:0]ruser;
	reg			rvalid,rlast,rxfifofull;
	reg       tready;
	wire		 rready;
	wire  [255:0]tdata;
	wire     [31:0]tkeep;
	wire  [127:0]tuser;
	wire	tvalid,tlast;
   wire  [15:0]gpio;
   	reg    [31:0]counter;
   // 10nsec --> 100MHz
   parameter STEP = 10;

   Shinku_NPU Shinku(clk,reset,rdata,rkeep,ruser,rvalid,rready,rlast,tdata,tkeep,tuser,tvalid,tready,tlast,gpio);

   // initialize test
   initial
      begin
         `ifdef __POST_PR__
            $sdf_annotate("Shinku.sdf", test.Shinku, , "sdf.log", "MAXIMUM");
         `endif
         clk <= 1; reset <= 0; rxfifofull <= 0; 
			rdata <= 255'b0; rkeep <= 32'b0; counter <= 32'b0;
			tready <= 1'b1; ruser <= 128'h00000000_00000000_00000000_0101_007c;
         // dump waveform
         $dumpfile("dump_Shinku_NPU.vcd");
         $dumpvars(0, Shinku);
         // stop at 1,000 cycles
         #(STEP* 5500);
         $display("Simulation failed");
         $finish;
      end

   // generate clock to sequence tests
   always #(STEP/2)
      begin
         clk <= ~clk;
      end

	always #(STEP)
		begin
			counter <= counter + 1;
		end
	
	always #(STEP)
		begin
			case(counter)
				32'd10:begin
					rdata <= 256'h0000fedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd11:begin
					rdata <= 256'h000fedcba987654321fedcba987654321fedcba987654321fedcba9876543210;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd12:begin
					rdata <= 256'h00fedcba987654321fedcba987654321fedcba987654321fedcba98765432100;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd13:begin
					rdata <= 256'h0fedcba987654321fedcba987654321fedcba987654321fedcba987654321000;
					rkeep <= 32'h0FFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b1;
					end
					
				32'd20:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd21:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd22:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b1;
					end
				
				32'd30:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd31:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd32:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'h0FFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b1;
					end
					
				32'd40:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd41:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd42:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b1;
					end
					
				32'd50:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd51:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd52:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b1;
					end
					
				32'd60:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd61:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd62:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd63:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b0;
					end
				32'd64:begin
					rdata <= 256'hfedcba987654321fedcba987654321fedcba987654321fedcba987654321;
					rkeep <= 32'hFFFF_FFFF;
					rvalid <= 1'b1;
					rlast <= 1'b1;
					end
				default:begin
					rdata <= 256'h0;
					rkeep <= 32'h0;
					rvalid <= 1'b0;
					rlast <= 1'b0;
					tready <= 1'b1;
					ruser <= 128'h00000000_00000000_00000000_0101_007c;
					end
				endcase
		end
	
endmodule 
