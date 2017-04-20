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

endpackage

