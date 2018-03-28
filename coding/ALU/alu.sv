`default_nettype none

module SrcAlu(
  inout [31:0] cpu_bus,
    input a_in,
    input c_in,
    input add,
    input sub,
    input a_and_b,
    input a_or_b,
    input shr,
    input shra,
    input shl,
    input not_a,
    input c_eq_b,
    input inc_4,
    input c_out
);
  
  reg [31:0] A, C, res;

  assign cpu_bus = (c_out) ? C : 32'bz;
  
  always @(*)
    begin
      if(a_in) A <= cpu_bus;
      if(add) res <= A + cpu_bus;
      if(sub) res <= A - cpu_bus;
      if(a_and_b) res <= A & cpu_bus;
      if(a_or_b) res <= A | cpu_bus;
      if(shr) res <= A >> cpu_bus;
      if(shra) res <= A >>> cpu_bus;
      if(shl) res <= A << cpu_bus;
      if(not_a) res <= ~A;
      if(c_eq_b) res <= cpu_bus;
      if(inc_4) res <= A + 32'b100;
      if(c_in) C <= res;
    end
    
endmodule
  