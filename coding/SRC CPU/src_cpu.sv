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
  
  assign reg_value = rs[reg_select];
  
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

  wire[4:0] opcode = ir[31:27];
  wire[4:0] ra = ir[26:22];
  wire[4:0] rb = ir[21:17];
  wire[4:0] rc = ir[16:12];
  wire[15:0] c2 = ir[16:0];

  reg opcode_out = 0;
  reg ra_out = 0;
  reg rb_out = 0;
  reg rc_out = 0;
  reg c2_out = 0;
  
  assign cpu_bus = opcode_out ? ir[31:27] : 32'bz;
  assign cpu_bus = ra_out ? ir[26:22] : 32'bz;
  assign cpu_bus = rb_out ? ir[21:17] : 32'bz;
  assign cpu_bus = rc_out ? ir[16:12] : 32'bz;
  assign cpu_bus = c2_out ? 65536*ir[16]+ir[16:0] : 32'bz;
  
  wire [31:0] cpu_bus;
    
  reg m_read = 0;
  reg m_enable = 0;
  reg ma_in = 0;
  reg md_in = 0;
  reg md_out = 0;
  
  
  assign read = m_read;
  assign enable = m_enable;
  
  SrcMemoryController memc(cpu_bus, mem_bus, ma_in, md_in, md_out, read, enable, address);
  
  //CPU MOUDULE
  reg a_in = 0;
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
  
  SrcAlu aluc(cpu_bus, a_in, c_in, add, sub, a_and_b, a_or_b, shr, shra, shl, not_a, c_eq_b, inc_4, c_out);
  
  reg [31:0] state = 0;
  
  always @(posedge clk) begin
    case (state)
      0 : begin
        pc_out <= 1;
        ma_in <= 1;
        state <= 1;
      end
      1 : begin
        pc_out <= 0;
        ma_in <= 0;
        
        m_read <= 1;
        m_enable <= 1;
        md_out <= 1;
        state <= 2;
      end
      //get opcode
      2 : begin
        m_read <= 0;
        m_enable <= 0;
        md_out <= 0;
        
        ir <= cpu_bus;
        pc <= pc + 1;
        state <= 3;
      end
      3 : begin
        $display("ir = %d", ir);
        $display("opcode: %d",opcode);
        $display("ra: %d",ra);
        $display("rb: %d",rb);
        $display("rc: %d",rc);
        
        case (opcode)
          0,1 : begin
            if (rb == 0)
                rb_out = 1;
            else
                rs_sel[rb] =1;
            a_in = 1;
          end
          
          11,12 : begin
            rs_sel[rb] = 1;
            a_in = 1;
          end
        endcase
        state <= 4;
      end
      4: begin
        case (opcode)
          0,1 : begin
            a_in=0;
            if(rb == 0)
                rb_out <= 0;
            else
                rs_sel[rb] <= 0;

            c2_out <= 1;
            add <= 1;
            c_in <= 1;
          end
          
          11,12 : begin
            rs_sel[rb] <= 0;
            a_in = 0;
            
            rs_sel[rc] <= 1;
          end
        endcase
        state <= 5;
      end
      5: begin  
        case (opcode)
          0,1 : begin
            c2_out <= 0;
            add <= 0;
            c_in <= 0;

            c_out <= 1;
            ma_in <= 1;
          end
          
          11,12 : begin
            rs_sel[rb] <= 0;
            a_in = 0;
            
            rs_sel[rc] <= 1;
            if (opcode == 11)
	          add = 1;
            else
              sub = 1;
            c_in = 1;
          end
        endcase
        state <= 6;
      end
      6: begin
        case (opcode)
          0 : begin
            c_out <= 0;
            ma_in <= 0;

            m_read <= 1;
            m_enable <= 1;
            md_out <= 1;
          end
          
          1 : begin
          	c_out <= 0;
            ma_in <= 0;
            
            rs_sel[ra] <= 1;
            md_in = 1;
          end
          
          11,12 : begin
            rs_sel[rc] <= 0;
            if (opcode == 11)
	          add = 0;
            else
              sub = 0;
            c_in = 0;
            
            c_out = 1;
          end
        endcase
        state <= 7;
      end
      7: begin
        case (opcode)
          0 : begin
            m_read <= 0;
            m_enable <= 0;
            md_out <= 0;
            
            rs[ra] <= cpu_bus;
        	state <= 0;
          end
          
          1 : begin
            rs_sel[ra] <= 0;
            md_in = 0;
            
            m_enable = 1;
            state <= 8;
          end
          
          11,12 : begin
            rs[ra] <= cpu_bus;
            c_out = 0;
            
            state <= 0;
          end
        endcase
      end
	  //test timestamp
      8: begin
        case (opcode)
          1 : begin
            m_enable <= 0;
            state <= 0;
          end
        endcase
      end
    endcase
  end
 
endmodule