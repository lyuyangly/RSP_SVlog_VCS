module rps_dut (
	input	bit	r1, p1, s1,
	input	bit r2, p2, s2,
	output	int score1, score2,
	input	bit go1, go2,
	input	bit clk, rst,
	output	bit	dut_busy
);

bit win1, win2;
int tie_score;

assign both_ready = (go1 & go2);

initial tie_score = 0;

always @ (posedge both_ready)
begin
	#3;
	win1 <= ((r1 & s2) | (s1 & p2) | (p1 & r2));
	win2 <= ((r2 & s1) | (s2 & p1) | (p2 & r1));
	if(win1)
		score1 <= score1 + 1;
	else if(win2)
		score2 <= score2 + 1;
	else
		tie_score <= tie_score + 1;
	dut_busy <= 1;
	@ (posedge clk);
	dut_busy <= 0;
end

endmodule

