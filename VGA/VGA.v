`include "./DE0_VGA.v"
`include "./PLL_PIXEL_CLK.v"
`include "../Modules/slowclock.sv"
`include "../Modules/slowerclock.sv"
`include "../Modules/slowestclock.sv"
`include "../Modules/timer.sv"
`include "../Modules/BCD_Display.sv"
`include "../Modules/Ball_Move.sv"
`include "../Modules/Paddle_Move.sv"
`include "../Modules/AI_Mode.sv"

module VGA(CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, SW, PaddleBtn, PauseBtn, HEX0_D, HEX1_D, HEX2_D, LEDG);
input		wire				CLOCK_50;
input 	wire	[9:0]		SW;
input		wire	[1:0]		PaddleBtn;
input		wire				PauseBtn;
output 	reg 	[2:0]		LEDG;

output 	wire 	[6:0]		HEX0_D;
output 	wire 	[6:0]		HEX1_D = 7'b0111111; //Setting the display to a -
output 	wire 	[6:0]		HEX2_D;

output	wire	[3:0]		VGA_R;			//Output Red
output	wire	[3:0]		VGA_G;			//Output Green
output	wire	[3:0]		VGA_B;			//Output Blue

output	wire	[0:0]		VGA_HS;			//Horizontal Sync
output	wire	[0:0]		VGA_VS;			//Vertical Sync

wire				[9:0]		X_pix;			//Location in X of the driver
wire				[9:0]		Y_pix;			//Location in Y of the driver

wire				[0:0]		H_visible;		//H_blank?
wire				[0:0]		V_visible;		//V_blank?

wire				[0:0]		pixel_clk;		//Pixel clock. Every clock a pixel is being drawn. 
wire				[9:0]		pixel_cnt;		//How many pixels have been output.

reg				[11:0]	pixel_color;	//12 Bits representing color of pixel, 4 bits for R, G, and B
													//4 bits for Blue are in most significant position, Red in least

reg 							CLOCK_10;
reg							CLOCK_20;
reg							CLOCK_30;
reg							CLOCK;

reg				[9:0]		timer;
reg							timerReset;

reg 				[0:0]		pause;

reg 				[9:0] 	ballX;
reg 				[9:0] 	ballY;
reg 				[9:0] 	paddle1Y;
reg				[9:0] 	paddle2Y;
reg				[9:0]		p2p;
reg				[9:0]		AIp;

//Clocks														
slowclock 	sclk 	(.fastclock(CLOCK_50), .reset(SW[9]), .slowclk(CLOCK_10));		
slowerclock srclk (.fastclock(CLOCK_50), .reset(SW[9]), .slowclk(CLOCK_20));	
slowestclock stclk (.fastclock(CLOCK_50), .reset(SW[9]), .slowclk(CLOCK_30));

//Timer
timer tr (.clk(CLOCK_50), .r(timerReset), .timer(timer));
assign timerReset = (((ballX == 0) || (ballX == 640)) ? 1 : 0);
assign CLOCK = ((timer < 30) ? CLOCK_10 : ((timer < 60) && (timer >= 30)) ? CLOCK_20 : CLOCK_30);

always @(posedge CLOCK)
begin
	if ((ballX == 0) || (ballX == 640))
		pause = 1;
	else if ((!PauseBtn))
		pause = 0;
end 

assign LEDG[0] = pause;

//Game										
ballMove 	bM 	(.clk(CLOCK), .paddle1Y(paddle1Y), .paddle2Y(paddle2Y), .pause(pause), .ball_X(ballX), .ball_Y(ballY), .HEX0_D(HEX0_D), .HEX2_D(HEX2_D));
paddleMove 	pM 	(.clk(CLOCK), .btn(PaddleBtn), .p2SW(SW[0]), .AISW(SW[8]), .pause(pause), .paddle1Y(paddle1Y), .paddle2Y(p2p));
AIMode 		aM 	(.clk(CLOCK), .ballY(ballY), .AISW(SW[8]), .paddle_2Y(AIp));

assign paddle2Y = ((SW[8] == 0) ? p2p : AIp);

//Draw the player one paddle
wire [9:0] player_1_paddle_width=10;
wire [9:0] player_1_paddle_height=60;
wire [9:0] player_1_paddle_x_location=0;
wire [9:0] player_1_paddle_y_location=paddle1Y;
reg player_1_paddle;

make_box_comb draw_first_player_paddle(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(player_1_paddle_width),
	.box_height(player_1_paddle_height),
	.box_x_location(player_1_paddle_x_location),
	.box_y_location(player_1_paddle_y_location),
	.pixel_clk(pixel_clk),
	.box(player_1_paddle)
);

//Draw the player two paddle
wire [9:0] player_2_paddle_width=10;
wire [9:0] player_2_paddle_height=60;
wire [9:0] player_2_paddle_x_location=630;
wire [9:0] player_2_paddle_y_location=paddle2Y;
reg player_2_paddle;

make_box_comb draw_second_player_paddle(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(player_2_paddle_width),
	.box_height(player_2_paddle_height),
	.box_x_location(player_2_paddle_x_location),
	.box_y_location(player_2_paddle_y_location),
	.pixel_clk(pixel_clk),
	.box(player_2_paddle)
);
	
//Draw the ball
wire [9:0] ball_width=10;
wire [9:0] ball_height=10;
wire [9:0] ball_x_location=ballX;
wire [9:0] ball_y_location=ballY;
reg ball;

make_box_comb draw_ball(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(ball_width),
	.box_height(ball_height),
	.box_x_location(ball_x_location),
	.box_y_location(ball_y_location),
	.pixel_clk(pixel_clk),
	.box(ball)
);
									
//Draw dotted line
wire [9:0] line1_width=3;
wire [9:0] line1_height=13;
wire [9:0] line1_x_location=324;
wire [9:0] line1_y_location=0;
reg line1;

make_box_comb draw_line1(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line1_width),
	.box_height(line1_height),
	.box_x_location(line1_x_location),
	.box_y_location(line1_y_location),
	.pixel_clk(pixel_clk),
	.box(line1)
);

wire [9:0] line2_width=3;
wire [9:0] line2_height=13;
wire [9:0] line2_x_location=324;
wire [9:0] line2_y_location=16;
reg line2;

make_box_comb draw_line2(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line2_width),
	.box_height(line2_height),
	.box_x_location(line2_x_location),
	.box_y_location(line2_y_location),
	.pixel_clk(pixel_clk),
	.box(line2)
);

wire [9:0] line3_width=3;
wire [9:0] line3_height=13;
wire [9:0] line3_x_location=324;
wire [9:0] line3_y_location=32;
reg line3;

make_box_comb draw_line3(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line3_width),
	.box_height(line3_height),
	.box_x_location(line3_x_location),
	.box_y_location(line3_y_location),
	.pixel_clk(pixel_clk),
	.box(line3)
);

wire [9:0] line4_width=3;
wire [9:0] line4_height=13;
wire [9:0] line4_x_location=324;
wire [9:0] line4_y_location=48;
reg line4;

make_box_comb draw_line4(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line4_width),
	.box_height(line4_height),
	.box_x_location(line4_x_location),
	.box_y_location(line4_y_location),
	.pixel_clk(pixel_clk),
	.box(line4)
);

wire [9:0] line5_width=3;
wire [9:0] line5_height=13;
wire [9:0] line5_x_location=324;
wire [9:0] line5_y_location=64;
reg line5;

make_box_comb draw_line5(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line5_width),
	.box_height(line5_height),
	.box_x_location(line5_x_location),
	.box_y_location(line5_y_location),
	.pixel_clk(pixel_clk),
	.box(line5)
);

wire [9:0] line6_width=3;
wire [9:0] line6_height=13;
wire [9:0] line6_x_location=324;
wire [9:0] line6_y_location=80;
reg line6;

make_box_comb draw_line6(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line6_width),
	.box_height(line6_height),
	.box_x_location(line6_x_location),
	.box_y_location(line6_y_location),
	.pixel_clk(pixel_clk),
	.box(line6)
);

wire [9:0] line7_width=3;
wire [9:0] line7_height=13;
wire [9:0] line7_x_location=324;
wire [9:0] line7_y_location=96;
reg line7;

make_box_comb draw_line7(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line7_width),
	.box_height(line7_height),
	.box_x_location(line7_x_location),
	.box_y_location(line7_y_location),
	.pixel_clk(pixel_clk),
	.box(line7)
);

wire [9:0] line8_width=3;
wire [9:0] line8_height=13;
wire [9:0] line8_x_location=324;
wire [9:0] line8_y_location=112;
reg line8;

make_box_comb draw_line8(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line8_width),
	.box_height(line8_height),
	.box_x_location(line8_x_location),
	.box_y_location(line8_y_location),
	.pixel_clk(pixel_clk),
	.box(line8)
);

wire [9:0] line9_width=3;
wire [9:0] line9_height=13;
wire [9:0] line9_x_location=324;
wire [9:0] line9_y_location=128;
reg line9;

make_box_comb draw_line9(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line9_width),
	.box_height(line9_height),
	.box_x_location(line9_x_location),
	.box_y_location(line9_y_location),
	.pixel_clk(pixel_clk),
	.box(line9)
);

wire [9:0] line10_width=3;
wire [9:0] line10_height=13;
wire [9:0] line10_x_location=324;
wire [9:0] line10_y_location=144;
reg line10;

make_box_comb draw_line10(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line10_width),
	.box_height(line10_height),
	.box_x_location(line10_x_location),
	.box_y_location(line10_y_location),
	.pixel_clk(pixel_clk),
	.box(line10)
);

wire [9:0] line11_width=3;
wire [9:0] line11_height=13;
wire [9:0] line11_x_location=324;
wire [9:0] line11_y_location=160;
reg line11;

make_box_comb draw_line11(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line11_width),
	.box_height(line11_height),
	.box_x_location(line11_x_location),
	.box_y_location(line11_y_location),
	.pixel_clk(pixel_clk),
	.box(line11)
);

wire [9:0] line12_width=3;
wire [9:0] line12_height=13;
wire [9:0] line12_x_location=324;
wire [9:0] line12_y_location=176;
reg line12;

make_box_comb draw_line12(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line12_width),
	.box_height(line12_height),
	.box_x_location(line12_x_location),
	.box_y_location(line12_y_location),
	.pixel_clk(pixel_clk),
	.box(line12)
);

wire [9:0] line13_width=3;
wire [9:0] line13_height=13;
wire [9:0] line13_x_location=324;
wire [9:0] line13_y_location=192;
reg line13;

make_box_comb draw_line13(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line13_width),
	.box_height(line13_height),
	.box_x_location(line13_x_location),
	.box_y_location(line13_y_location),
	.pixel_clk(pixel_clk),
	.box(line13)
);

wire [9:0] line14_width=3;
wire [9:0] line14_height=13;
wire [9:0] line14_x_location=324;
wire [9:0] line14_y_location=208;
reg line14;

make_box_comb draw_line14(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line14_width),
	.box_height(line14_height),
	.box_x_location(line14_x_location),
	.box_y_location(line14_y_location),
	.pixel_clk(pixel_clk),
	.box(line14)
);

wire [9:0] line15_width=3;
wire [9:0] line15_height=13;
wire [9:0] line15_x_location=324;
wire [9:0] line15_y_location=224;
reg line15;

make_box_comb draw_line15(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line15_width),
	.box_height(line15_height),
	.box_x_location(line15_x_location),
	.box_y_location(line15_y_location),
	.pixel_clk(pixel_clk),
	.box(line15)
);

wire [9:0] line16_width=3;
wire [9:0] line16_height=13;
wire [9:0] line16_x_location=324;
wire [9:0] line16_y_location=240;
reg line16;

make_box_comb draw_line16(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line16_width),
	.box_height(line16_height),
	.box_x_location(line16_x_location),
	.box_y_location(line16_y_location),
	.pixel_clk(pixel_clk),
	.box(line16)
);

wire [9:0] line17_width=3;
wire [9:0] line17_height=13;
wire [9:0] line17_x_location=324;
wire [9:0] line17_y_location=256;
reg line17;

make_box_comb draw_line17(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line17_width),
	.box_height(line17_height),
	.box_x_location(line17_x_location),
	.box_y_location(line17_y_location),
	.pixel_clk(pixel_clk),
	.box(line17)
);

wire [9:0] line18_width=3;
wire [9:0] line18_height=13;
wire [9:0] line18_x_location=324;
wire [9:0] line18_y_location=272;
reg line18;

make_box_comb draw_line18(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line18_width),
	.box_height(line18_height),
	.box_x_location(line18_x_location),
	.box_y_location(line18_y_location),
	.pixel_clk(pixel_clk),
	.box(line18)
);

wire [9:0] line19_width=3;
wire [9:0] line19_height=13;
wire [9:0] line19_x_location=324;
wire [9:0] line19_y_location=288;
reg line19;

make_box_comb draw_line19(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line19_width),
	.box_height(line19_height),
	.box_x_location(line19_x_location),
	.box_y_location(line19_y_location),
	.pixel_clk(pixel_clk),
	.box(line19)
);

wire [9:0] line20_width=3;
wire [9:0] line20_height=13;
wire [9:0] line20_x_location=324;
wire [9:0] line20_y_location=304;
reg line20;

make_box_comb draw_line20(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line20_width),
	.box_height(line20_height),
	.box_x_location(line20_x_location),
	.box_y_location(line20_y_location),
	.pixel_clk(pixel_clk),
	.box(line20)
);

wire [9:0] line21_width=3;
wire [9:0] line21_height=13;
wire [9:0] line21_x_location=324;
wire [9:0] line21_y_location=320;
reg line21;

make_box_comb draw_line21(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line21_width),
	.box_height(line21_height),
	.box_x_location(line21_x_location),
	.box_y_location(line21_y_location),
	.pixel_clk(pixel_clk),
	.box(line21)
);

wire [9:0] line22_width=3;
wire [9:0] line22_height=13;
wire [9:0] line22_x_location=324;
wire [9:0] line22_y_location=336;
reg line22;

make_box_comb draw_line22(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line22_width),
	.box_height(line22_height),
	.box_x_location(line22_x_location),
	.box_y_location(line22_y_location),
	.pixel_clk(pixel_clk),
	.box(line22)
);

wire [9:0] line23_width=3;
wire [9:0] line23_height=13;
wire [9:0] line23_x_location=324;
wire [9:0] line23_y_location=352;
reg line23;

make_box_comb draw_line23(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line23_width),
	.box_height(line23_height),
	.box_x_location(line23_x_location),
	.box_y_location(line23_y_location),
	.pixel_clk(pixel_clk),
	.box(line23)
);

wire [9:0] line24_width=3;
wire [9:0] line24_height=13;
wire [9:0] line24_x_location=324;
wire [9:0] line24_y_location=368;
reg line24;

make_box_comb draw_line24(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line24_width),
	.box_height(line24_height),
	.box_x_location(line24_x_location),
	.box_y_location(line24_y_location),
	.pixel_clk(pixel_clk),
	.box(line24)
);

wire [9:0] line25_width=3;
wire [9:0] line25_height=13;
wire [9:0] line25_x_location=324;
wire [9:0] line25_y_location=384;
reg line25;

make_box_comb draw_line25(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line25_width),
	.box_height(line25_height),
	.box_x_location(line25_x_location),
	.box_y_location(line25_y_location),
	.pixel_clk(pixel_clk),
	.box(line25)
);

wire [9:0] line26_width=3;
wire [9:0] line26_height=13;
wire [9:0] line26_x_location=324;
wire [9:0] line26_y_location=400;
reg line26;

make_box_comb draw_line26(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line26_width),
	.box_height(line26_height),
	.box_x_location(line26_x_location),
	.box_y_location(line26_y_location),
	.pixel_clk(pixel_clk),
	.box(line26)
);

wire [9:0] line27_width=3;
wire [9:0] line27_height=13;
wire [9:0] line27_x_location=324;
wire [9:0] line27_y_location=416;
reg line27;

make_box_comb draw_line27(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line27_width),
	.box_height(line27_height),
	.box_x_location(line27_x_location),
	.box_y_location(line27_y_location),
	.pixel_clk(pixel_clk),
	.box(line27)
);

wire [9:0] line28_width=3;
wire [9:0] line28_height=13;
wire [9:0] line28_x_location=324;
wire [9:0] line28_y_location=432;
reg line28;

make_box_comb draw_line28(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line28_width),
	.box_height(line28_height),
	.box_x_location(line28_x_location),
	.box_y_location(line28_y_location),
	.pixel_clk(pixel_clk),
	.box(line28)
);

wire [9:0] line29_width=3;
wire [9:0] line29_height=13;
wire [9:0] line29_x_location=324;
wire [9:0] line29_y_location=448;
reg line29;

make_box_comb draw_line29(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line29_width),
	.box_height(line29_height),
	.box_x_location(line29_x_location),
	.box_y_location(line29_y_location),
	.pixel_clk(pixel_clk),
	.box(line29)
);

wire [9:0] line30_width=3;
wire [9:0] line30_height=13;
wire [9:0] line30_x_location=324;
wire [9:0] line30_y_location=464;
reg line30;

make_box_comb draw_line30(
	.X_pix(X_pix),
	.Y_pix(Y_pix),
	.box_width(line30_width),
	.box_height(line30_height),
	.box_x_location(line30_x_location),
	.box_y_location(line30_y_location),
	.pixel_clk(pixel_clk),
	.box(line30)
);
									
always @(posedge pixel_clk)
	begin
		if (player_1_paddle) pixel_color <= 12'b1111_1111_1111;
		else if (player_2_paddle) pixel_color <= 12'b1111_1111_1111;
		else if (ball) pixel_color <= 12'b1111_1111_1111;
		else if (line1) pixel_color <= 12'b1111_1111_1111;
		else if (line2) pixel_color <= 12'b1111_1111_1111;
		else if (line3) pixel_color <= 12'b1111_1111_1111;
		else if (line4) pixel_color <= 12'b1111_1111_1111;
		else if (line5) pixel_color <= 12'b1111_1111_1111;
		else if (line6) pixel_color <= 12'b1111_1111_1111;
		else if (line7) pixel_color <= 12'b1111_1111_1111;
		else if (line8) pixel_color <= 12'b1111_1111_1111;
		else if (line9) pixel_color <= 12'b1111_1111_1111;
		else if (line10) pixel_color <= 12'b1111_1111_1111;
		else if (line11) pixel_color <= 12'b1111_1111_1111;
		else if (line12) pixel_color <= 12'b1111_1111_1111;
		else if (line13) pixel_color <= 12'b1111_1111_1111;
		else if (line14) pixel_color <= 12'b1111_1111_1111;
		else if (line15) pixel_color <= 12'b1111_1111_1111;
		else if (line16) pixel_color <= 12'b1111_1111_1111;
		else if (line17) pixel_color <= 12'b1111_1111_1111;
		else if (line18) pixel_color <= 12'b1111_1111_1111;
		else if (line19) pixel_color <= 12'b1111_1111_1111;
		else if (line20) pixel_color <= 12'b1111_1111_1111;
		else if (line21) pixel_color <= 12'b1111_1111_1111;
		else if (line22) pixel_color <= 12'b1111_1111_1111;
		else if (line23) pixel_color <= 12'b1111_1111_1111;
		else if (line24) pixel_color <= 12'b1111_1111_1111;
		else if (line25) pixel_color <= 12'b1111_1111_1111;
		else if (line26) pixel_color <= 12'b1111_1111_1111;
		else if (line27) pixel_color <= 12'b1111_1111_1111;
		else if (line28) pixel_color <= 12'b1111_1111_1111;
		else if (line29) pixel_color <= 12'b1111_1111_1111;
		else if (line30) pixel_color <= 12'b1111_1111_1111;
		else pixel_color <= 12'b0000_0000_0000;
		
	end
	
		//Pass pins and current pixel values to display driver
		DE0_VGA VGA_Driver
		(
			.clk_50(CLOCK_50),
			.pixel_color(pixel_color),
			.VGA_BUS_R(VGA_R), 
			.VGA_BUS_G(VGA_G), 
			.VGA_BUS_B(VGA_B), 
			.VGA_HS(VGA_HS), 
			.VGA_VS(VGA_VS), 
			.X_pix(X_pix), 
			.Y_pix(Y_pix), 
			.H_visible(H_visible),
			.V_visible(V_visible), 
			.pixel_clk(pixel_clk),
			.pixel_cnt(pixel_cnt)
		);

endmodule

module make_box_comb(
	input [9:0] X_pix,
	input [9:0] Y_pix,
	input [9:0] box_width,
	input [9:0] box_height,
	input [9:0] box_x_location,
	input [9:0] box_y_location,
	input pixel_clk,
	output reg box
	);
	always @(posedge pixel_clk)
	begin
		if((X_pix>box_x_location)&&(X_pix<(box_x_location+box_width))&&(Y_pix>box_y_location)&&(Y_pix<(box_y_location+box_height))) 
			box=1;
		else 
			box=0;
	end
endmodule
/*
module make_box_comb(
	input [9:0] X_pix,
	input [9:0] Y_pix,
	input [9:0] box_width,
	input [9:0] box_height,
	input [9:0] box_x_location,
	input [9:0] box_y_location,
	output box
	);
		assign box = ((X_pix>box_x_location)&&(X_pix<(box_x_location+box_width))&&(Y_pix>box_y_location)&&(Y_pix<box_y_location+box_height)))?0:1;
endmodule
*/