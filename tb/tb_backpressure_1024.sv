`timescale 1ns/1ps
module tb_backpressure_1024;
  localparam int N = 1024;

  logic clk=0; always #5 clk=~clk;
  logic rst_n;

  logic in_valid; logic in_ready; logic [127:0] in_x_q64;
  logic out_valid; logic out_ready;
  logic signed [63:0] out_ln_q30;
  logic signed [63:0] out_log10_q30;

  logic [127:0] x_vec [0:N-1];
  logic [63:0]  ln_exp[0:N-1];
  logic [63:0]  lg_exp[0:N-1];

  int i_in, i_out;
  int mism_ln, mism_lg;

  function automatic void must_exist(input string fn);
    int fd;
    begin
      fd = $fopen(fn, "r");
      if (fd == 0) begin
        $display("FATAL: missing file: %s", fn);
        $finish(2);
      end
      $fclose(fd);
    end
  endfunction

  initial begin
    must_exist("x128_1024.memh");
    must_exist("ln.memh");
    must_exist("log10.memh");
    $readmemh("x128_1024.memh", x_vec);
    $readmemh("ln.memh", ln_exp);
    $readmemh("log10.memh", lg_exp);
  end

  najla_ln_package dut (
    .clk(clk), .rst_n(rst_n),
    .in_valid(in_valid),
    .in_ready(in_ready),
    .in_x_q64(in_x_q64),
    .out_valid(out_valid),
    .out_ready(out_ready),
    .out_ln_q30(out_ln_q30),
    .out_log10_q30(out_log10_q30)
  );

  // back-pressure: out_ready = 0 كل ثالث دورة تقريبًا
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) out_ready <= 1'b1;
    else begin
      // pattern: 1,1,0,1,1,0,...
      if (($time/10) % 3 == 2) out_ready <= 1'b0;
      else                     out_ready <= 1'b1;
    end
  end

  initial begin
    rst_n=0; in_valid=0; in_x_q64='0;
    i_in=0; i_out=0; mism_ln=0; mism_lg=0;

    repeat(5) @(posedge clk);
    rst_n=1; @(posedge clk);

    while (i_out < N) begin
      // in_valid: حاول دائمًا تبعث إذا ready
      if (i_in < N && in_ready) begin
        in_valid <= 1;
        in_x_q64 <= x_vec[i_in];
      end else if (i_in >= N) begin
        in_valid <= 0;
      end

      if (in_valid && in_ready) i_in++;

      if (out_valid && out_ready) begin
        if (out_ln_q30 !== $signed(ln_exp[i_out])) begin
          mism_ln++;
          if (mism_ln <= 5) $display("LN MISM @%0d exp=%h got=%h", i_out, ln_exp[i_out], out_ln_q30);
        end
        if (out_log10_q30 !== $signed(lg_exp[i_out])) begin
          mism_lg++;
          if (mism_lg <= 5) $display("LG MISM @%0d exp=%h got=%h", i_out, lg_exp[i_out], out_log10_q30);
        end
        i_out++;
      end
      @(posedge clk);
    end

    $display("DONE(backpressure) N=%0d mism_ln=%0d mism_log10=%0d", N, mism_ln, mism_lg);
    if (mism_ln==0 && mism_lg==0) $display("PASS ✅ backpressure bit-exact");
    else                         $display("FAIL ❌");
    $finish;
  end
endmodule
