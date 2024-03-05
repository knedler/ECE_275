module AIMode(
	input wire clk,
	input wire [9:0] ballY,
	input wire AISW,
	
	output reg [9:0] paddle_2Y
);
reg [9:0] paddle2Y = 210;

always @(posedge clk)
	begin
		if (AISW == 1) //AI Mode?
			begin
				if ((ballY >= 30) && (ballY <= 450))
					begin
						if (ballY < paddle2Y - 9) //Ball higher than paddle?
							begin
								paddle2Y--;
							end
						else if (ballY > paddle2Y + 60) //Ball lower than paddle?
							begin
								paddle2Y++;
							end
					end
			end
	end
assign paddle_2Y = paddle2Y;
endmodule
	