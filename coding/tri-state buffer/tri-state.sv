module TriState(
	input[0:31] data,
	input active,
	output[0:31] result
);

assign result = (active) ? data : 32'bz;

endmodule
