`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 01:21:51 AM
// Design Name: 
// Module Name: control_word_store
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Min Control Store RTL
/* Provides the control word stored at the rom address as a registered output 
at every positive edge of the clock. The control word register is cleared using an initial statement.
Later on a reset input can be used for the purpose of clearing the control word register */
module controlstore (address, clock, controlword);
input [4:0] address;
input clock;
output [24:0] controlword;
reg [24:0] controlword;
reg [24:0] rom [0:31];
//define the ROM data (control word) stored at each address (address <-> state ID)
//format of control word:
//asrccntl_adestcntl_bsrccntl_bdestcntl_alucntl_memcntl_irecntl_nssel_dbin
initial
begin
rom [0] = 25 'b011_00_000_000_001_010_0_00_10111;		//start0
rom [1] = 25 'b011_00_000_000_001_001_0_00_00010;    	//abdm1
rom [2] = 25 'b101_11_000_000_000_000_0_00_00011;		//abdm2
rom [3] = 25 'b010_00_111_000_010_000_0_00_00100;		//abdm3
rom [4] = 25 'b101_01_000_000_000_001_0_10_00000;		//abdm4
rom [5] = 25 'b000_00_010_100_000_101_0_10_00000;		//adrm1
rom [6] = 25 'b011_00_000_000_001_010_0_00_00111;		//brzz3
rom [7] = 25 'b000_00_101_011_000_000_1_01_00000;		//brzz2
rom [8] = 25 'b110_00_101_011_100_000_1_01_00000;		//ldrm2
rom [9] = 25 'b010_00_000_000_001_010_0_11_00110;		//brzz1
rom [10] = 25 'b011_00_111_101_001_010_0_00_01000;	//ldrm1
rom [11] = 25 'b001_00_110_000_100_111_0_00_00110;	//strm1
rom [12] = 25 'b001_00_111_000_110_000_0_00_01101;	//oprm1
rom [13] = 25 'b101_00_110_000_000_111_0_00_00110;	//oprm2
rom [14] = 25 'b011_00_111_100_001_010_0_00_01000;	//test1
rom [15] = 25 'b011_00_010_101_001_010_0_00_01000;	//ldrr1
rom [16] = 25 'b011_00_001_110_001_010_0_00_01000;	//strr1
rom [17] = 25 'b001_00_010_000_110_000_0_00_10010;	//oprr1
rom [18] = 25 'b011_00_101_010_001_010_0_00_00111;	//oprr2
rom [19] = 25 'b010_00_000_000_001_001_0_00_10100;	//popr1
rom [20] = 25 'b101_10_111_001_000_000_0_00_00110;	//popr2
rom [21] = 25 'b010_00_000_000_011_000_0_00_10110;	//push1
rom [22] = 25 'b001_00_101_010_000_111_0_00_00110;	//push2
rom [23] = 25 'b101_11_000_000_000_000_1_01_00000;	//start1
//contents at remaining ROM addresses are not used and are left undefined
end
 initial
//initialize the value of control word register
controlword = 25 'b000_00_000_000_000_000_0_00_00000;
always @(posedge clock)
controlword <=  rom [address];
endmodule

