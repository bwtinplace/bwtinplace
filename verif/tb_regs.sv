`timescale 1ns/10ps

`define CLKPERIOD   200

`define N_SZ    16
`define N_LOG2  4
`define MARKER  36

module tb();

  logic rst_n;
  logic ch_in_valid;
  logic [7:0] ch_in;
  logic [7:0] ch_out;
  logic ch_out_valid;

  logic clk;
  initial begin
    clk <= 0;
    forever #(`CLKPERIOD/2) clk <= ~clk;
  end

  int i;

  string texts[] = {"mississippipipi$", "alabamaalabamaa$"};
  string golds[] = {"ipppssm$iipissii", "aammlla$bbaaaaaa"};

  initial begin
    reset();
    fork
      begin // scan in blocks
        int block;
        for (block = 0; block < texts.size(); block = block + 1) begin
          $display("texts[%0d]: %s", block, texts[block]);
          for (i = `N_SZ-1; i >= 0; i = i-1) begin
            ch_in       <= texts[block][i];
            ch_in_valid <= 1;
            wait_cycles(1);
            ch_in_valid <= 0;
            wait_cycles(5);
          end
        end
        ch_in       <= `MARKER;
        ch_in_valid <= 1;
      end
      begin // read out result
        int block;
        string bwt;
        for (block = 0; block < texts.size(); block = block + 1) begin
          bwt = "";
          $display("golds[%0d]: %s", block, golds[block]);
          while (bwt.len() < `N_SZ) begin
            if (ch_out_valid)
              bwt = { string'(ch_out), bwt };
            wait_cycles(1);
          end
          $display("     bwt: %s", bwt);
          assert(bwt == golds[block]);
        end
      end
    join

    $finish();
  end

  top
`ifdef RTL
    #( .N_SZ   ( `N_SZ   ),
       .N_LOG2 ( `N_LOG2 ),
       .MARKER ( `MARKER ) )
`endif
    DUT (
      .clk          ( clk          ) ,
      .rst_n        ( rst_n        ) ,
      .ch_in_valid  ( ch_in_valid  ) ,
      .ch_in        ( ch_in        ) ,
      .ch_out       ( ch_out       ) ,
      .ch_out_valid ( ch_out_valid ) );

  task reset();
    rst_n       <= 1'b0;
    ch_in_valid <= 1'b0;
    ch_in       <= 8'b0;

    wait_cycles(4);
    rst_n <= 1'b1;
    wait_cycles(1);
  endtask

  task wait_cycles(input int n);
    repeat(n) @(posedge clk);
  endtask

endmodule

