class rps_env;
	stimulus_generator s1, s2;
	mailbox #(rps_c) f1, f2, ap1, ap2;
	rps_driver d1, d2;
	rps_monitor m1, m2;
	rps_scoreboard sb;

	function new(virtual rps_dut_pins_if p1, p2);
		s1 = new(1);
		f1 = new(2);
		d1 = new(p1, 1);
		ap1 = new;
		s2 = new(2);
		f2 = new(2);
		d2 = new(p2, 2);
		ap2 = new;

		m1 = new(p1, 1);
		m2 = new(p2, 2);
		sb = new(ap1, ap2);
		sb.limit = 10;
		s1.fifo = f1;
		s2.fifo = f2;
		d1.nb_get_port = f1;
		d2.nb_get_port = f2;

		m1.ap = ap1;
		m2.ap = ap2;
	endfunction

	task execute;
		fork
			s1.generate_stimulus();
			s2.generate_stimulus();
			d1.run();
			d2.run();
			m1.run();
			m2.run();
			sb.run();
			terminate();
		join_any
	endtask


	task terminate;
		@(posedge sb.test_done);
		s1.stop_stimulus_generation();
		s2.stop_stimulus_generation();
		$display("Test Finished!");
	endtask

endclass

