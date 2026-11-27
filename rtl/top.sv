// -----------------------------------------------------------------------
//
// top: board bring-up design for the RK-XCKU5P-F V1.2
//
//   led[3:0]  4-bit counter: key[0] up, key[1] down, key[2] reset (0),
//             key[3] set to max (15)
//
// MIT License
//
// Copyright (C) 2026 Philipp Kraft
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// -----------------------------------------------------------------------

`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter int unsigned CLK_HZ         = 200_000_000,
    parameter bit          KEY_ACTIVE_LOW = 1'b1          // flip if it counts on release
) (
    input  wire logic       sys_clk_p,  // 200 MHz differential system clock
    input  wire logic       sys_clk_n,
    input  wire logic [3:0] key,        // push buttons (asynchronous)
    output logic      [3:0] led
);

  // ------------------------------------------------------------------
  // Clock
  // ------------------------------------------------------------------
  logic clk_ibuf;
  logic clk;

  IBUFDS u_clk_ibuf (
      .I (sys_clk_p),
      .IB(sys_clk_n),
      .O (clk_ibuf)
  );
  BUFG u_clk_bufg (
      .I(clk_ibuf),
      .O(clk)
  );

  // ------------------------------------------------------------------
  // Button synchronizer
  // ------------------------------------------------------------------
  (* ASYNC_REG = "TRUE" *)logic [3:0] key_meta = '0;
  (* ASYNC_REG = "TRUE" *)logic [3:0] key_sync = '0;

  always_ff @(posedge clk) begin
    key_meta <= key;
    key_sync <= key_meta;
  end

  // ------------------------------------------------------------------
  // Debounce: sample the keys every 10 ms
  // ------------------------------------------------------------------
  localparam int unsigned TICK = CLK_HZ / 100;

  logic [$clog2(TICK)-1:0] tick_cnt = '0;
  logic [             3:0] key_db = '0;  // debounced, 1 = pressed
  logic [             3:0] key_db_q = '0;
  logic [             3:0] press;  // one-cycle pulse per press

  always_ff @(posedge clk) begin
    if (tick_cnt == TICK - 1) begin
      tick_cnt <= '0;
      key_db   <= KEY_ACTIVE_LOW ? ~key_sync : key_sync;
    end else begin
      tick_cnt <= tick_cnt + 1'b1;
    end
    key_db_q <= key_db;
  end

  assign press = key_db & ~key_db_q;

  // ------------------------------------------------------------------
  // Counter
  // ------------------------------------------------------------------
  logic [3:0] count = '0;

  always_ff @(posedge clk) begin
    if (press[2]) count <= '0;
    else if (press[3]) count <= '1;
    else if (press[0] && !press[1]) count <= count + 1'b1;
    else if (press[1] && !press[0]) count <= count - 1'b1;
  end

  assign led = count;

endmodule

`default_nettype wire
