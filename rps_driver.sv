class rps_driver;
	mailbox #(rps_c) nb_get_port;
	rps_c transaction;
	virtual rps_dut_pins_if dut_vf;
	int id;

	function new(virtual rps_dut_pins_if dut_vf_i, int id_i);
		dut_vf = dut_vf_i;
		id = id_i;
	endfunction

	task run;
		{dut_vf.r, dut_vf.p, dut_vf.s} = 3'b000;
		dut_vf.go = 0;
		@(negedge dut_vf.clk_if.rst);

		forever @ (posedge dut_vf.clk_if.clk)
			if(nb_get_port.try_get(transaction))
			begin
				{dut_vf.r, dut_vf.p, dut_vf.s} = 3'b000;
				$display("driver%0d get a stimulus:%s", id, transaction.rps);
				case(transaction.rps)
					ROCK: dut_vf.r = 1;
					PAPER:dut_vf.p = 1;
					SCISSORS: dut_vf.s = 1;
				endcase
				dut_vf.go = 1;
				@(posedge dut_vf.clk_if.clk);
				dut_vf.go = 0;
				@(posedge dut_vf.clk_if.clk);
				{dut_vf.r, dut_vf.p, dut_vf.s} = 3'b000;
			end
	endtask

endclass

