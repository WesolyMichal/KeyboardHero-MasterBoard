/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

 module top_master_basys3 (
    input  wire clk,
    input  wire btnC,
    inout  wire PS2Clk,
    inout  wire PS2Data,
    
    output wire [7:0] led,
    output wire JA1
);

timeunit 1ns;
timeprecision 1ps;

/**
 * Local variables and signals
 */

wire clk100MHz;
wire clk40MHz;
wire locked;
wire pclk_mirror;

(* KEEP = "TRUE" *)
(* ASYNC_REG = "TRUE" *)
logic [7:0] safe_start = 0;
// For details on synthesis attributes used above, see AMD Xilinx UG 901:
// https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


/**
 * Signals assignments
 */

/**
 * FPGA submodules placement
 */

clk_wiz_0_clk_wiz u_clk_wiz(
    .clk,
    .locked,
    .clk100MHz,
    .clk40MHz
);

// Mirror pclk on a pin for use by the testbench;
// not functionally required for this design to work.

ODDR pclk_oddr (
    .Q(pclk_mirror),
    .C(clk40MHz),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
);


/**
 *  Project functional top module
 */

top_master u_top_master (
    .clk40MHz,
    .clk100MHz,
    .rst_n(!btnC),
    .PS2_clk(PS2Clk),
    .PS2_data(PS2Data),
    .led,
    .uart_tx(JA1)
);

endmodule
