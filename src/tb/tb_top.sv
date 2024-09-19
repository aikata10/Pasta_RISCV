`timescale 1ns/1ps

`define PAROUT_FILE     "_program/parout.txt"
`define PAROUT_REF_FILE "_program/parout.ref"

module tb_top;

  logic Clk_C = 1'b0;
  logic Rst_RB = 1'b0;
  logic EoC_S;
  logic [3:0] GPO_D;

  // Parallel out monitor
  integer fd_par_out;
  wire [7:0] parout_data;
  wire parout_valid;
  initial
  begin
    fd_par_out = $fopen(`PAROUT_FILE, "w");
    if (fd_par_out == 0) begin
      $display("WARNING: cannot open PARALLEL_OUT_FILE");
      $finish(1);
    end
  end

  always @(posedge Clk_C)
  begin
    if(parout_valid) begin
      $fwrite(fd_par_out, "%c", parout_data);
      $fwrite(1, "%c", parout_data);
    end
  end

  // Clock and reset generator
  //
  // Create clocks until we get a EOC (End of computing) signal from CPU
  initial begin
    Clk_C = 0;
    forever #25 Clk_C = ~Clk_C;
  end

  initial begin
    Rst_RB = 1'b0;
    #50
    Rst_RB = 1'b1;
  end

  integer ret;
  integer ctr=-1;
  integer ref_out;
  integer tb_out;
  string line_tb, line_ref;
  always @(posedge Clk_C) begin
    if(EoC_S) begin
      // Few cycles after finish
      #250
      $fclose(fd_par_out);

      ref_out  = $fopen(`PAROUT_REF_FILE, "r");
      if(!ref_out) begin
        $display ("NO REFERENCE FILE FOUND, IGNORE OUTPUT CHECK");
        $finish(0);
      end

      tb_out  = $fopen(`PAROUT_FILE, "r");
      if(!ref_out) begin
        $display ("ERROR: Could not read testbench output");
        $finish(1);
      end

      while(!$feof(tb_out) || !$feof(ref_out))begin
        ret = $fgets(line_tb, tb_out);
        ret = $fgets(line_ref, ref_out);
        ctr=ctr+1;
        if (line_tb != line_ref) begin
          $display ("TEST FAILED:");
          $display ("Expected %s but got %s", line_ref, line_tb);
          $finish(1);
        end
      end

      $display ("TEST SUCEEDED = ",ctr);
      $fclose(ref_out);
      $fclose(tb_out);
      $finish(0);
    end
  end
   

  IbexASIC ibex(
    .Clk_CI       ( Clk_C         ),
    .Rst_RBI      ( Rst_RB        ),
    .Eoc_SO       ( EoC_S         ),
    .GPO_DO_0     ( GPO_D[0]      ),
    .GPO_DO_1     ( GPO_D[1]      ),
    .GPO_DO_2     ( GPO_D[2]      ),
    .GPO_DO_3     ( GPO_D[3]      ),
    .ParO_DO_0    ( parout_data[0]),
    .ParO_DO_1    ( parout_data[1]),
    .ParO_DO_2    ( parout_data[2]),
    .ParO_DO_3    ( parout_data[3]),
    .ParO_DO_4    ( parout_data[4]),
    .ParO_DO_5    ( parout_data[5]),
    .ParO_DO_6    ( parout_data[6]),
    .ParO_DO_7    ( parout_data[7]),
    .ParO_valid_S0( parout_valid  )
  );
endmodule
