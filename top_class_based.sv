module top_class_based();
	
	import rps_env_pkg::*;
	`include "rps_env.sv";

	rps_clk_if clk_if();
	rps_clock_reset cr(.clk(clk_if.clk), .rst(clk_if.rst));

	rps_dut_pins_if pins1_if(clk_if);
	rps_dut_pins_if pins2_if(clk_if);
	
	rps_dut dut (
		.r1(pins1_if.r),
		.p1(pins1_if.p),
		.s1(pins1_if.s),
		.r2(pins2_if.r),
		.p2(pins2_if.p),
		.s2(pins2_if.s),
		.score1(pins1_if.score),
		.score2(pins2_if.score),
		.go1(pins1_if.go),
		.go2(pins2_if.go),
		.clk(clk_if.clk),
		.rst(clk_if.rst),
		.dut_busy(clk_if.dut_busy)
	);

	rps_env env;
	
	initial begin
		env = new(pins1_if, pins2_if);
		fork
			cr.run();
		join_none
		env.execute();
		$finish;
		// $stop;
	end

	initial begin
		 $fsdbDumpfile("tb.fsdb");
		 $fsdbDumpvars;
	end

endmodule

