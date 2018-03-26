`default_nettype none

module SrcMemoryController(
    inout [31:0] cpu_bus,
    inout [31:0] mem_bus,
    input ma_in,
    input md_in, 
    input md_out, 
    input read,
    input enable,
    output [15:0] address
);
  reg [15:0] ma;
  reg [31:0] md;
  
  assign address = ma;
  assign cpu_bus = (md_out) ? md : 32'bz;
  assign mem_bus = (enable && ~read) ? md : 32'bz;
  
  always @(*)
    begin
      if (enable)
        begin
          if (read)
            begin
              md <= mem_bus;
            end
        end
      if (ma_in)
        begin
          ma <= cpu_bus;
        end
      if (md_in)
        begin
          md <= cpu_bus;
        end
    end
  
endmodule
