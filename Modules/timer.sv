module timer (
	input wire clk,
	input wire r,
	output reg [9:0] timer
);
reg [35:0] summed_counter;

always @(posedge clk)
	begin
		if (r)
			begin
				summed_counter = 0;
			end
		else
			begin
				summed_counter = summed_counter + 1'b1;
			end
	end

assign timer[9:0] = summed_counter[35:26];
endmodule
