package rps_env_pkg;

typedef enum bit [1:0] {IDLE, ROCK, PAPER, SCISSORS} rps_t;

class rps_c;
	rand rps_t rps;
	int score;
	
	constraint illegal {rps != IDLE;}

	function bit comp(input rps_c a);
		if(a.rps == this.rps)
			return 1;
		else 
			return 0;
	endfunction
	
	function rps_c clone;
		clone = new;
		clone.rps = this.rps;
	endfunction
endclass

function void report_the_play (string where, rps_c t1, rps_c t2);
	string str;
	$sformat(str, "(t1.rps, t2,rps) - Score1 = %0d, Score2 = %0d", t1.score, t2.score);
	$display("%s", str);
endfunction

class stimulus_generator;
	mailbox #(rps_c) fifo;
	int id;
	bit stop = 0;

	function new(int id_i);
		id = id_i;
	endfunction

	task generate_stimulus;
		rps_c tmp;
		forever begin
			if(stop == 0)
			begin
				tmp = new;
				tmp.randomize();
				fifo.put(tmp);
			end
			else break;
		end
	endtask
	task stop_stimulus_generation();
		stop = 1;
	endtask

endclass

class rps_scoreboard;
	mailbox #(rps_c) fifo1, fifo2;
	rps_c t1, t2;
	int score1, score2, tie_score;
	int limit;
	reg test_done;

	function new(mailbox #(rps_c) fifo1_i, fifo2_i);
		fifo1 = fifo1_i;
		fifo2 = fifo2_i;
		test_done = 0;
		score1 = 0;
		score2 = 0;
		tie_score = 0;
	endfunction

	task run;
		forever begin
			fifo1.get(t1);
			fifo2.get(t2);
			report_the_play("SBD", t1, t2);
			update_and_check_score();
		end
	endtask
	local function void update_and_check_score;
		string  str;
		bit win1, win2;

		if(score1 != t1.score) begin
			$sformat(str, "MISMATCH - score1 = %0d, t1.score = %0d", score1, t1.score);
			$display("SBD %s", str);
		end
		if(score2 != t2.score) begin
			$sformat(str, "MISMATCH - score2 = %0d, t2.score = %0d", score2, t2.score);
			$display("SBD %s", str);
		end
		
		win1 = ((t1.rps == ROCK && t2.rps == SCISSORS) | 
				(t1.rps == SCISSORS && t2.rps == PAPER) |
				(t1.rps == PAPER && t2.rps == ROCK));
		win2 = ((t2.rps == ROCK && t1.rps == SCISSORS) | 
				(t2.rps == SCISSORS && t1.rps == PAPER) |
				(t2.rps == PAPER && t1.rps == ROCK));
				
		if(win1) score1 += 1;
		else if(win2) score2 += 1;
		else tie_score += 1;
		
		if((t1.score >= limit) || (t2.score >= limit))
			test_done = 1;
		$display("time:%0d SBD compare successfully, score1: %0d, score2: %0d, tie_score: %0d", $time, score1, score2, tie_score);
		
	endfunction
endclass

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


endpackage

