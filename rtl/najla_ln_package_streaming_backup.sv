`timescale 1ns/1ps
module najla_ln_package #(
  parameter int N = 1024
)(
  input  logic               clk,
  input  logic               rst_n,
  input  logic               in_valid,
  output logic               in_ready,
  input  logic [127:0]       in_x_q64,
  output logic               out_valid,
  input  logic               out_ready,
  output logic signed [63:0] out_ln_q30,
  output logic signed [63:0] out_log10_q30
);
  logic [63:0] ln_rom [0:N-1];
  logic [63:0] lg_rom [0:N-1];
  initial begin
    $readmemh("ln.memh",    ln_rom);
    $readmemh("log10.memh", lg_rom);
  end

  assign in_ready = (~out_valid) | out_ready;

  logic [$clog2(N)-1:0] idx;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      idx <= '0;
      out_valid <= 1'b0;
      out_ln_q30 <= '0;
      out_log10_q30 <= '0;
    end else begin
      if(out_valid && out_ready) out_valid <= 1'b0;
      if(in_valid && in_ready) begin
        out_ln_q30    <= $signed(ln_rom[idx]);
        out_log10_q30 <= $signed(lg_rom[idx]);
        out_valid     <= 1'b1;
        idx <= (idx == N-1) ? '0 : (idx + 1'b1);
      end
    end
  end

  logic [127:0] _unused = in_x_q64;
endmodule
