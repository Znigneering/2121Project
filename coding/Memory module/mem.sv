`default_nettype none

module Memory (
  inout [31:0] mem_bus,
  input [15:0] address,
  input read, 
  input enable
);

  reg [31:0] reg_mem [65535:0];
  reg [31:0] reg_bus;
  
  assign mem_bus = (enable & read) ? reg_bus : 32'bz; 
  
  always @(enable)
    begin
      if (read == 0)
        begin
          reg_mem[address] <= mem_bus;
        end
      else
        begin
          reg_bus <= reg_mem[address];
        end
    end
endmodule