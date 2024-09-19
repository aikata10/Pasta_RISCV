//-----------------------------------------------------------------------------
// Title      : Grain LFSR
//-----------------------------------------------------------------------------
// File       : grain_lfsr.sv
// Author     : Robert Schilling  <robert.schilling@iaik.tugraz.at>
// Company    : 
// Created    : 2020-02-15
// Last update: 2020-02-26
// Platform   : 
// Standard   : System Verilog
//-----------------------------------------------------------------------------
// Description: Calculates Grain's LFSR function
//-----------------------------------------------------------------------------

module grain_lfsr #(
  parameter int DATA_WIDTH = 32
) (
  input  logic                  Clk_CI,
  input  logic                  Rst_RBI,
  input  logic                  Enable_SI,     // Keep LFSR running
  input  logic [79:0] Seed,
  output logic                  DataReady_SO,  // New number available
  output logic [DATA_WIDTH-1:0] Data_DO        // Random number
);
  logic DataReady_SN, DataReady_SP;
  logic [79:0] LFSR_DN, LFSR_DP;
  logic [5:0] Counter_DN, Counter_DP;
  logic s_i_plus_80;

  // Continious output assignment
  assign DataReady_SO = DataReady_SP;
  assign Data_DO      = LFSR_DP[DATA_WIDTH-1:0];

  // Combinatorial process of the LFSR
  always_comb begin
    LFSR_DN = LFSR_DP;

    // Calculate feedback bit
    // !! TODO, PLACE YOUR CODE HERE !!
    s_i_plus_80 = LFSR_DN[79]^LFSR_DN[66]^LFSR_DN[56]^LFSR_DN[41]^LFSR_DN[28]^LFSR_DN[17];
    // LFSR is enabled?
    if(Enable_SI) begin
      // Shift left and shift-in new bit
      // !! TODO, PLACE YOUR CODE HERE !!
      LFSR_DN = {LFSR_DN[78:0],s_i_plus_80};
    end
  end

  // Counter and ready signalling functionality
  always_comb begin
  // Default assignment
    Counter_DN   = Counter_DP;
    DataReady_SN = DataReady_SP;

    // LFSR is enabled?
    if(Enable_SI) begin
      // Count up and overflow
      Counter_DN = Counter_DP + 1;
      if(Counter_DP == DATA_WIDTH-1) begin
        Counter_DN = '0;
      end
    end

    // Genereate Ready signal on overflow for the next cycle
    if(Counter_DP == DATA_WIDTH-1) begin
      DataReady_SN = 1'b1;
    end else begin
      DataReady_SN = 1'b0;
    end
  end

  // Register Process
  always_ff @(posedge Clk_CI, negedge Rst_RBI) begin
    // asynchronous reset (active low)
    if(!Rst_RBI) begin
      // TODO: CHANGE SEED!
      LFSR_DP      <= 80'h8A40B9CF316FF7B65660;//Seed
      Counter_DP   <= '0;
      DataReady_SP <= '0;
    end else begin
      LFSR_DP      <= LFSR_DN;
      Counter_DP   <= Counter_DN;
      DataReady_SP <= DataReady_SN;
    end
  end
endmodule
