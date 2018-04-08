`default_nettype none
`include "mem_controller.sv"
`include "alu.sv"


module SrcCpu (
  inout [31:0] mem_bus,
  input clk,
  output [15:0] address,
  output read,
  output enable,
  input [4:0] reg_select,
  output [31:0] reg_value
);
  
  reg [31:0] pc = 0;
  reg [31:0] ir;
  reg pc_out = 0;
  
  assign cpu_bus = pc_out ? pc : 32'bz;
  
  reg [31:0] rs [31:0];
  reg [31:0] rs_sel = 0 ;
  
  generate
    genvar i;
    for (i=0; i<32; i = i + 1)
      begin: gen1
      	assign cpu_bus = rs_sel[i] ? rs[i] : 32'bz;
      end
  endgenerate

  wire [4:0] opcode = ir[31:27];
  wire [4:0] ra = ir[26:22];
  wire [4:0] rb = ir[21:17];
  wire [4:0] rc = ir[16:12];
  wire [16:0] c2 = ir[16:0];
  
  wire [31:0] cpu_bus;
  //MEMORY MOUDULE
  reg m_read = 0;
  reg m_enable = 0;
  reg ma_in = 0;
  reg md_in = 0;
  reg md_out = 0;
    
  assign read = m_read;
  assign enable = m_enable;
  
  SrcMemoryController memc(cpu_bus, mem_bus, ma_in, md_in, md_out, read, enable, 	address);
  //CPU MOUDULE
  reg a_in,
  reg c_in = 0;
  reg add = 0;
  reg sub = 0;
  reg a_and_b = 0;
  reg a_or_b = 0;
  reg shr = 0;
  reg shra = 0;
  reg shl = 0;
  reg not_a = 0;
  reg c_eq_b = 0;
  reg inc_4 = 0;
  reg c_out = 0;
  
  SrcAlu alu(cpu_bus,a_in,c_in,add,sub,a_and_b,a_or_b,shr,shra,shl,not_a,c_eq_b,
             inc_4,c_out);
    
  reg [31:0] state = 0;
  
  always @(posedge clk) begin
    case (state)
      0 : begin
        pc_out <= 1;
        ma_in <= 1;
        state <= 1;
        $display("ir = %d", ir);
      end
      1 : begin
        pc_out <= 0;
        pc <= pc + 1;
        
        ma_in <= 0;
        m_read <= 1;
        m_enable <= 1;
        md_out <= 1;
        
        state <= 2;
      end
      2 : begin
        ir <= cpu_bus;
        state <= 3;
      end
      3 : begin
        $display("ir = %08h", ir);
        $display("opcode = %d", opcode);
        $display("ra = %d", ra);
        $display("rb = %d", ra);
        $display("c2 = %d", c2);
      end
      4 : begin
        
      end
    endcase
  end
  

endmodule
	