module fpadd (clk, reset, start, a, b, sum, done);
    input clk, reset, start;
    input [31:0] a, b;
    output reg [31:0] sum;
	output reg done = 1'b0;

	reg sign_a, sign_b;
	reg [7:0] exp_a, exp_b;
	reg signed [24:0] mant_a, mant_b;
	reg [3:0] state;

	reg b25, b24;

	reg [7:0] exp_r, ediff;
	reg signed [25:0] mant_r;
	reg sign_r;

	always @(posedge clk)begin
		
		if(reset) begin
			state <= 0;
			done <= 1'b1;
		end
		else begin 
			case(state)
				0 : begin 
					//checking start
					if (start) begin
						done <= 1'b0;
						state <= state + 2;
						sign_a <= a[31];
						sign_b <= b[31];
						exp_a <= a[30:23];
						exp_b <= b[30:23];
						mant_a <= {{2'b01},{a[22:0]}};
						mant_b <= {{2'b01},{b[22:0]}};
					end
				end
				1 : begin
					//State-2-Resolving Special cases
					//-give indication
					if (exp_a == {8{1'b0}} && mant_a == {{1{2'b01}},{23{1'b0}}}) begin
						sign_r <= sign_b;
						exp_r <= exp_b;
						mant_r <= {{1{1'b0}},{mant_b[24:0]}};
						state <= 15;
					end
					else if (exp_b == {8{1'b0}} && mant_b == {{1{2'b01}},{23{1'b0}}}) begin
						sign_r <= sign_a;
						exp_r <= exp_a;
						mant_r <= {{1{1'b0}},{mant_a[24:0]}};
						state <= 15;
					end
					else if (exp_a == {8{1'b1}}) begin
						sign_r <= sign_a;
						exp_r <= exp_a;
						mant_r <= {{1{1'b0}},{mant_a[24:0]}};
						state <= 15;
					end
					else if (exp_b == {8{1'b1}}) begin
						sign_r <= sign_b;
						exp_r <= exp_b;
						mant_r <= {{1{1'b0}},{mant_b[24:0]}};
						state <= 15;
					end
					else begin
						state <= state + 1;
					end
				end

				2 : begin
					//State-4-Comparing Differences
					//-Finding difference in exponents amd using Maximum exponent as reference
					if (exp_a > exp_b) begin
						ediff <= exp_a - exp_b;
						exp_r <= exp_a;
					end
					else if (exp_b > exp_a) begin
						ediff <= exp_b - exp_a;
						exp_r <= exp_b;
					end
					else if (exp_a == exp_b) begin
						ediff <= 0;
						exp_r <= exp_a;
					end
					state <= state + 1;
				end
				3 : begin
					//State-3-Seeing sign
					//-Negating Mantissa
					if (sign_a) begin
						mant_a = -mant_a;
					end
					if (sign_b) begin
						mant_b = -mant_b;
					end
					state <= state + 1;
				end

				4 : begin
					//Shifting mantissa accordingly
					if (exp_a > exp_b) begin
						mant_b <= mant_b >>> ediff;
					end
					else if (exp_b > exp_a) begin
						mant_a <= mant_a >>> ediff;
					end
					state <= state + 1;
				end

				5 : begin
					//Shifting Mantissa
					mant_r <= mant_a + mant_b;
					state <= state + 1;
				end

				6 : begin
					//State-5-Adding Mantissa
					//-Comparing Mantissa to determine Sign and Mantissa
					if (mant_r[25] == 1) begin
						sign_r <= 1'b1;
						mant_r <= -mant_r;
					end
					else if(mant_r[25] == 0) begin
						sign_r <= 1'b0;
					end
					state <= state + 1;
				end

				7  : begin
					//State-6-Normalise
					b25 <= mant_r[24];
					b24 <= mant_r[23];
					state <= state + 1;
				end

				8	: begin
					//-Change/Shift Mantissa and Exponent
					if (mant_r == {25{1'b0}}) begin 
						exp_r <= {8{1'b0}};
						state <= 15;
					end
					else if (b25 == 1)begin
						mant_r <= mant_r >>> 1;
						state <= 15;
					end
					else if ((b25 == 0) && (b24 == 1))begin
						state <= 15;
					end
					else if (b24 != 1) begin
						mant_r <= mant_r <<< 1;
						exp_r <= exp_r - 1;
						b24 = mant_r[23];
						b25 = mant_r[24];
						state <= 7;
					end
				end

				default : begin
					sum <= {{sign_r},{exp_r[7:0]},{mant_r[22:0]}};
					done <= 1'b1;
					state <= 0;
				end
			endcase
		end
	end
endmodule


// Filename        : fpadd_tb.v
// Description     : Sequential multiplier test bench
// Author          : Nitin Chandrachoodan <nitin@ee.iitm.ac.in>
// Automatic test bench
// Uses tasks to keep test code clean
`timescale 1ns/1ns
// The number of tests should ideally be obtained from the file
`define NUMTEST 4
`define TIMEOUT 100
module fpadd_tb () ;
	reg [31:0]	testinputs[0:`NUMTEST*3-1];
	reg [31:0] 	a, b, sumexp;
	reg 		clk, reset, start;
	integer     tot, err;
	integer     timer, i;
	reg         timedout;

	wire [31:0]	sum;
	wire 	   	done;

	fpadd dut( .clk(clk),
		.reset(reset),
		.start(start),
		.a(a),
		.b(b),
		.sum(sum),
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
			end else if (sum !== sumexp) begin
				err += 1;
				$display($time, " a = %X, b = %X, sum = %X, expected sum = %X", a, b, sum, sumexp);
			end
		end
	endtask // start_and_crank_dut
	
	initial begin
		$dumpfile("test.vcd");
		$dumpvars;
		// Initialize the clock
		clk = 1;
		tot = 0;
		err = 0;
		timedout = 0;
		// Apply reset for 100ns
		reset = 1;
		#100 reset = 0;

		// Bulk read the test cases into testinputs
		$readmemh("vtest.dat", testinputs);

		for (i=0; i<`NUMTEST; i=i+1) begin
			a = testinputs[i*3];
			b = testinputs[i*3+1];
			sumexp = testinputs[i*3+2];
			// $display($time, " a = %X, b = %X, expected sum = %X", a, b, sumexp);
			start_and_crank_dut;
		end

		if (err > 0) begin
			$display("FAILED %d out of %d", err, tot);
		end else if (timedout === 'b1) begin
			$display("FAILED due to TIMEOUT");
		end else begin
			$display("PASS");
		end

		$finish;
		
	end
	
endmodule