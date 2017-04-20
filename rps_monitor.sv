class rps_monitor;
	virtual rps_dut_pins_if dut_vf;
	mailbox #(rps_c) ap;
	int id;
	
	function new(virtual rps_dut_pins_if dut_vf_i, int id_i);
		dut_vf = dut_vf_i;
		id = id_i;
	endfunction
	
	function rps_c pins2transction;
		rps_c transaction = new;
		case({dut_vf.r, dut_vf.p, dut_vf.s})
			3'b100 : transaction.rps = ROCK;
			3'b010 : transaction.rps = PAPER;
			3'b001 : transaction.rps = SCISSORS;
		endcase

		transaction.score = dut_vf.score;
		$display("time %0d, monitor%0d capture a transaction: %s", $time, id, transaction.rps);
		return transaction;
	endfunction
	
	task run;
		forever @ (posedge dut_vf.clk_if.dut_busy)
			ap.put(pins2transction());
	endtask
endclass


