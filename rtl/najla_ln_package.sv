`timescale 1ns/1ps
module najla_ln_package #(
  parameter int N   = 1024,
  parameter int LAT = 6
)(
  input  logic               clk,
  input  logic               rst_n,

  input  logic               in_valid,
  output logic               in_ready,
  input  logic [127:0]       in_x_q64,        // reference model: ignored

  output logic               out_valid,
  input  logic               out_ready,
  output logic signed [63:0] out_ln_q30,
  output logic signed [63:0] out_log10_q30
);

  // -------------------------
  // Reference ROMs
  // -------------------------
  logic [63:0] ln_rom [0:N-1];
  logic [63:0] lg_rom [0:N-1];
  initial begin
    $readmemh("ln.memh",    ln_rom);
    $readmemh("log10.memh", lg_rom);
  end

  // -------------------------
  // Pipeline regs
  // -------------------------
  localparam int IW = (N <= 2) ? 1 : $clog2(N);

  logic [IW-1:0] idx_ctr;
  logic [IW-1:0] idx_pipe [0:LAT-1];
  logic          v_pipe   [0:LAT-1];

  logic signed [63:0] out_ln_r, out_lg_r;
  assign out_ln_q30    = out_ln_r;
  assign out_log10_q30 = out_lg_r;

  assign out_valid = v_pipe[LAT-1];

  wire stall   = out_valid && !out_ready;
  wire advance = !stall;

  // -------------------------
  // OneShot control
  // -------------------------
  logic done;
  logic [IW:0] sent_cnt;         // counts accepted inputs 0..N

  assign in_ready = advance && !done;
  wire fire_in = in_valid && in_ready;

  // token reaches last stage (explicit)
  wire token_to_last = (LAT >= 2) && advance && v_pipe[LAT-2];
  wire [IW-1:0] idx_to_last = idx_pipe[LAT-2];

  integer s;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      idx_ctr   <= '0;
      done      <= 1'b0;
      sent_cnt  <= '0;
      out_ln_r  <= '0;
      out_lg_r  <= '0;
      for (s = 0; s < LAT; s++) begin
        idx_pipe[s] <= '0;
        v_pipe[s]   <= 1'b0;
      end
    end else begin
      if (advance) begin
        // shift pipeline
        for (s = LAT-1; s > 0; s--) begin
          idx_pipe[s] <= idx_pipe[s-1];
          v_pipe[s]   <= v_pipe[s-1];
        end

        // stage0 load
        if (fire_in) begin
          idx_pipe[0] <= idx_ctr;
          v_pipe[0]   <= 1'b1;

          idx_ctr  <= idx_ctr + 1'b1;      // no wrap in OneShot
          sent_cnt <= sent_cnt + 1'b1;

          if (sent_cnt + 1 == N) done <= 1'b1; // stop after N accepts
        end else begin
          v_pipe[0] <= 1'b0;
        end

        // output update exactly when token reaches last stage
        if (token_to_last) begin
          out_ln_r <= $signed(ln_rom[idx_to_last]);
          out_lg_r <= $signed(lg_rom[idx_to_last]);
        end
      end
      // else: stall -> freeze pipe + hold outputs
    end
  end

  // reference note
  logic [127:0] _unused = in_x_q64;

endmodule

