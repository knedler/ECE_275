module ballMove(
	input wire 	     clk,
	input wire [9:0] paddle1Y,
	input wire [9:0] paddle2Y,
	input wire [0:0] pause,
	
	output reg [9:0] ball_X,
	output reg [9:0] ball_Y,
	output reg [6:0] HEX0_D,
	output reg [6:0] HEX2_D
);
reg [9:0] ballX = 320;
reg [9:0] ballY = 235;

reg [3:0] p1Score = 4'b0000;
reg [3:0] p2Score = 4'b0000;
reg [2:0] vector = 3'b000;
/**************************	
Vectors! 
			000 is 0°
			001 is 45°
			010 is 135°
			011 is 180°
			100 is 235°
			101 is 315°
**************************/

always @(posedge clk)
	begin
	if (pause == 0) begin
	//Edges
		if (ballY == 0)
			begin
				vector = ((vector == 3'b001) ? 3'b101 : 3'b100);
			end
		else if (ballY == 470)
			begin
				vector = ((vector == 3'b101) ? 3'b001 : 3'b010);
			end
		//Ball On Paddle
		if (ballX <= 9) 
			begin
				if (ballX == 9)
					begin
						//If Ball Hits Paddle 1
						if ((ballY >= (paddle1Y - 9)) && (ballY <= (paddle1Y + 60)))
							begin
								if ((ballY >= (paddle1Y - 9)) && (ballY <= (paddle1Y + 14)))
									begin
										vector = 3'b001;
									end
								else if ((ballY >= (paddle1Y + 15)) && (ballY <= (paddle1Y + 36)))
									begin
										vector = 3'b000;
									end
								else if ((ballY >= (paddle1Y + 37)) && (ballY <= (paddle1Y + 60)))
									begin
										vector = 3'b101;
									end
							end
					end
				//If Ball goes off left side
				else if (ballX == 0)
					begin
						ballX = 320;
						ballY = 235;
						vector = 3'b011;
						if (p2Score < 9)
							begin
								p2Score++;
							end
						else if (p2Score == 9)
							begin
								p2Score = 0;
							end
					end
			end
		else if (ballX >= 621)
			begin
				if (ballX == 621)
					begin
						//If Ball Hits Paddle 2
						if ((ballY >= (paddle2Y - 9)) && (ballY <= (paddle2Y + 60)))
							begin
								if ((ballY >= (paddle2Y - 9)) && (ballY <= (paddle2Y + 14)))
									begin
										vector = 3'b010;
									end
								else if ((ballY >= (paddle2Y + 15)) && (ballY <= (paddle2Y + 36)))
									begin
										vector = 3'b011;
									end
								else if ((ballY >= (paddle2Y + 37)) && (ballY <= (paddle2Y + 60)))
									begin
										vector = 3'b100;
									end
							end
					end
				//If Ball goes off right side
				else if (ballX ==640)
					begin
						ballX = 320;
						ballY = 235;
						vector = 3'b000;
						if (p1Score < 9)
							begin
								p1Score++;
							end
						else if (p1Score == 9)
							begin
								p1Score = 0;
							end
					end
			end
		//Ball Movement
		if (vector == 3'b000)
			begin
				ballX++;
			end
		else if (vector == 3'b001) 
			begin
				ballX++;
				ballY--;
			end
		else if (vector == 3'b010) 
			begin
				ballX--;
				ballY--;
			end
		else if (vector == 3'b011) 
			begin
				ballX--;
			end
		else if (vector == 3'b100) 
			begin
				ballX--;
				ballY++;
			end
		else if (vector == 3'b101) 
			begin
				ballX++;
				ballY++;
			end
		end
	end
	BCD_DisplayO BCD0 (.BCDValue3(p2Score[3]), .BCDValue2(p2Score[2]), .BCDValue1(p2Score[1]), .BCDValue0(p2Score[0]),
				 .LEDSegment0(HEX0_D[0]), .LEDSegment1(HEX0_D[1]), .LEDSegment2(HEX0_D[2]), .LEDSegment3(HEX0_D[3]), .LEDSegment4(HEX0_D[4]), .LEDSegment5(HEX0_D[5]), .LEDSegment6(HEX0_D[6]));
	BCD_DisplayO BCD2 (.BCDValue3(p1Score[3]), .BCDValue2(p1Score[2]), .BCDValue1(p1Score[1]), .BCDValue0(p1Score[0]),
				 .LEDSegment0(HEX2_D[0]), .LEDSegment1(HEX2_D[1]), .LEDSegment2(HEX2_D[2]), .LEDSegment3(HEX2_D[3]), .LEDSegment4(HEX2_D[4]), .LEDSegment5(HEX2_D[5]), .LEDSegment6(HEX2_D[6]));

	assign ball_X = ballX;
	assign ball_Y = ballY;
	
endmodule
