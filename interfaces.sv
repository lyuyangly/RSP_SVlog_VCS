interface rps_clk_if;
	bit clk, rst, dut_busy;
endinterface

interface rps_dut_pins_if(rps_clk_if clk_if);
	reg r, p, s;
	int score;
	reg go;
	rps_t play;
endinterface

