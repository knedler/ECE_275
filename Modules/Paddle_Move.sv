module paddleMove (
	input wire clk,
	input wire [1:0] btn,
	input wire p2SW,
	input wire AISW,
	input wire [0:0] pause,
	
	output reg [9:0] paddle1Y,
	output reg [9:0] paddle2Y
);
reg [9:0] paddle_1Y = 210;
reg [9:0] paddle_2Y = 210;

always @(posedge clk)
	begin
	if (pause != 1) begin
	//Paddle
		if (btn[0] == 0)
			begin
				if (p2SW == 0) //P1?
					begin
						if (paddle_1Y <= 419) //Paddle 1 up
							begin
								paddle_1Y++;
							end
					end
				else if ((p2SW == 1) && (AISW == 0)) //P2 + !AI?
					begin
						if (paddle_2Y <= 419) //Paddle 2 up
							begin
								paddle_2Y++;
							end
					end
			end
		else if (btn[1] == 0)
			begin
				if (p2SW == 0) //P1?
					begin
						if (paddle_1Y >= 1) //Paddle 1 down
							begin
								paddle_1Y--;
							end
					end
				else if ((p2SW == 1) && (AISW == 0)) //P2 + !AI?
					begin
						if (paddle_2Y >= 1) //Paddle 2 down
							begin
								paddle_2Y--;
							end
					end
			end
		end
	end
assign paddle1Y = paddle_1Y;
assign paddle2Y = paddle_2Y;
endmodule
