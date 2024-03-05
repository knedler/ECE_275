module slowestclock(input wire fastclock,
					    input wire reset,
                   output reg slowclk
);

// 1. Register / or flip flops
reg [17:0] count;
wire [17:0] dinputs;
always @(posedge fastclock or posedge reset)
begin
	if (reset) 
		count <= 18'b000000000000000000;
	else
		count <= dinputs;
end
 
// 2. Combinational logic that maps from 
// inputs + current state -> next state
assign dinputs = (count == 18'b100110001001011010) ? 18'b000000000000000000 : count + 1;

// 3. Combinational logic that maps from 
// Mealy: inputs + current state -> output
// Moore: current state -> output
assign slowclk = (count == 18'b000000000000000000) ?   1'b1 : 1'b0;
endmodule
