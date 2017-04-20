module rps_clock_reset (
	output	bit clk, rst
);

parameter bit ACTIVE_RESET = 1;

task run (int reset_hold = 4, int half_period = 10, int count = 0);
	clk = 0;
	rst = ACTIVE_RESET;

	for(int rst_i = 0; rst_i < reset_hold; rst_i ++)
	begin
		#half_period; clk = !clk;
		#half_period; clk = !clk;
	end

	rst <= ~ rst;

	for(int clk_i = 0; (clk_i < count || count == 0); clk_i++)
	begin
		#half_period; clk = !clk;
	end
endtask

endmodule

