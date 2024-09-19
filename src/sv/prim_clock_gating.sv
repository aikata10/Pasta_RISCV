module prim_clock_gating #(
    parameter Impl = "default"
) (
    input        clk_i,
    input        en_i,
    input        test_en_i,
    output logic clk_o
);

`ifdef FUNC_SIM
  logic clk_en;

  always_latch begin
    if (clk_i == 1'b0) begin
      clk_en <= en_i | test_en_i;
    end
  end

  assign clk_o = clk_i & clk_en;

`else
  GCKETCLD clk_gate (
    .E(en_i),
    .TE(test_en_i),
    .CK(clk_i),
    .Q(clk_o)
  );

`endif

endmodule
