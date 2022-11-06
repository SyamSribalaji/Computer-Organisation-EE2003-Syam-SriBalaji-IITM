 /*
 Signed Sequential Multiplier 
 23/08/22
 Syam SriBalaji T
 EE20B136
 */
 
`define width 8 //Width of Signed bit which needs to multiplied
`define ctrwidth 4

module seq_mult (p, done, clk, start, a, b);
	input clk, start;
	input [`width-1:0] a, b;
	output done; //Flag bit to indicate when done
    output [2*`width-1:0] p; //Product

	reg [2*`width-1:0] p;
    reg [2*`width-1:0] multiplier;
    reg [2*`width-1:0] multiplicand;
    reg done;
	reg [`ctrwidth:0] ctr; //To control the Shift and NO. of Iterations

	always @(posedge clk) begin
		if (start) begin
			done <= 0;
			p <= 0;
			ctr <= 0;
			multiplier <= {{`width{a[`width-1]}},a}; //Concatenating the MSB to previous bits
			multiplicand <= {{`width{b[`width-1]}},b};
     	end else begin
			if (ctr < 2*`width)
	  		begin
                if (multiplicand[ctr] == 1) begin
                    p <= p + (multiplier << ctr); //Repeated Addition of Shifted bits
                end
                ctr <= ctr + 1;
	  		end else begin
	     		done <= 1;
	  		end
     	end
    end
endmodule

`timescale 1ns/1ns
`define width 8
`define TIMEOUT 100

module seq_mult_tb () ;
   reg signed [`width-1:0] a, b;
   reg 		   clk, start;
   integer     tot, err;
   integer     timer;
   reg         timedout;

   wire  signed [2*`width-1:0] p, expected_p;
   wire 	      done;

   //Calculation of expected output.
   assign expected_p = a * b;
   
   seq_mult dut( .clk(clk),
		 .start(start),
		 .a(a),
		 .b(b),
		 .p(p),
		 .done(done));

   // Generate a 10ns clock 
   always #5 clk = !clk;
   
   task start_and_crank_dut;
      begin
         tot += 1;
         timer = 0;   
	      // start the DUT for one clock cycle
	      start = 1;
	      @(posedge clk);
	      // Remove start 
	      #1 start = 0;
	 
	      // Loop until the DUT indicates 'done'
	      while ((done == 0) && (timer < `TIMEOUT)) begin
	         @(posedge clk); // Wait for one clock cycle
            timer += 1;
	      end
         if (timer == `TIMEOUT) begin
            $display("Timed out");
            timedout = 1;
         end else if (p !== expected_p) begin
            err += 1;
            $display($time, " a = %d, b = %d, p = %d, expected p = %d", a, b, p, expected_p);
         end
      end
   endtask // start_and_crank_dut
   
   initial begin
      // Initialize the clock
      clk = 1;
      tot = 0;
      err = 0;
      timedout = 0;

      // Sequences of values pumped through DUT 
      
      // It is not necessary to place a #1 before the $display,
      // because the start_and_crank_dut task will only exit after the
      // value is correctly computed.
      a = 10;
      b = 1;
      start_and_crank_dut;
      
      a = 10;
      b = 2;
      start_and_crank_dut;

      // Product will not fit in 8 bits.      
      a = 20;
      b = 20;
      start_and_crank_dut;

      // One operand negative
      a = -10;
      b = 2;
      start_and_crank_dut;
      
      // One operand negative
      a = 10;
      b = -2;
      start_and_crank_dut;

      // One input 0
      a = 0;
      b = 10;
      start_and_crank_dut;

      // Other input 0
      a = 10;
      b = 0;
      start_and_crank_dut;

      // Large values
      a = 127;
      b = 127;
      start_and_crank_dut;

      // Add more test cases:
      // - other input negative
      // - each input 0
      // - max/min values etc.
      // - random numbers if necessary?

      if (err > 0) begin
         $display("FAILED %d out of %d", err, tot);
      end else if (timedout === 'b1) begin
         $display("FAILED due to TIMEOUT");
      end else begin
         $display("PASS");
      end

      $finish;
      
   end
   
endmodule // seq_mult_tb