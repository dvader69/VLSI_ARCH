`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 01:19:24 AM
// Design Name: 
// Module Name: execution_unit
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


//RT-level model of MIN Execution Unit including Memory 
//The Memory is word addressable, size = 32 words, word size = 16 bits 
//Memory should be initialized to define its contents
module mineu (eucntl, opcntl, clock, cc, ifd, ,mem17);	
input [17 : 0] eucntl;	//execution unit control word input port
input [2 : 0] opcntl;	//alu static operation code input: op-s input port
input  clock;		//clock
output [3 : 0] cc;	//condition code bits computed
output [15:0] ifd;	//instruction for decoding: pre-fetched in irf
output [15:0] mem17;
reg [3 : 0] cc;
reg signed [15:0] mem17;
reg signed [15 : 0] regfile [0: 15], pc, t1, t2, di, irf, ire, mem [0 : 31]; 
//even pc, irf, ire are declared as signed (why?)
reg signed [15 : 0] a, b;	//data on bus-a and bus-b
reg [2 : 0] alucntl;		//alu function control field in eucntl
reg ldt1; 
reg signed [ 15 : 0 ] aluout;	//output of alu
reg carry;	//carry out from alu
reg ccset;	//signal derived from alucntl, used for updating of condition code register
reg [3 : 0] ccreg;	//condition code register
reg[3 : 0] rx, ry;	//rx and ry fields of the instruction present in ire register
reg [2 : 0] asrccntl, bsrccntl, bdestcntl, memcntl;	//control fields in eucntl specifying:
//bus-a source register, bus-b source register, bus-b destination register and memory transfer //type. 
reg [1 : 0] adestcntl;	//control field in eucntl specifying bus-a destination register
initial 
begin 
mem17<=0;
end
//update ird output whenever register irf changes:  ird is input to the instruction decoder
assign ifd = irf;	
//update rx and ry register pointers
	always @ (*)
begin
	rx = ire [9 : 6];
	ry = ire [3 : 0];
end 
/* 
extract the current bits corresponding to bus-a and bus-b source and destination control fields, alu control field, and memory transfer type control field from the current execution unit control word that is applied
*/
always @(*)
begin	
asrccntl = eucntl [ 17 : 15 ];	//a-bus source register control field
bsrccntl = eucntl [ 12 : 10 ]; 	//b-bus source register control field
alucntl = eucntl [ 6 : 4 ]; 	//alu control field
adestcntl = eucntl [ 14 : 13];	//a-bus destination register control field 
	bdestcntl = eucntl [ 9 : 7 ];	//b-bus destination register control field
memcntl = eucntl [ 3 : 1 ];	//memory transfer control field
$strobe ( $time, "%m : eucntl =  %b", eucntl);
end
//transfer the contents of bus-a source register to bus "a" and bus-b source register to bus "b"
always @ (*)
begin
	case (asrccntl)
		3 'b011  :  a = pc;
		3 'b101  :  a = t1;
		3 'b010  :  a = regfile [ ry ];
		3 'b110  :  a = t2;
		3 'b001  :  a = regfile [ rx ];
		3 'b000  :  a = 0;
		default   : $display ($time, "%m : invalid bus-a source  control signal");
	endcase
	case (bsrccntl)
		3 'b111  :  b = di;
		3 'b010  :  b = regfile [ ry ];
		3 'b101  :  b = t1;
		3 'b110  :  b = t2;
		3 'b001  :  b = regfile [ rx ];
		3 'b000  :  b = 0;
		default  : $display ($time, "%m : invalid bus-b source control signal");
	endcase
	$strobe ($time, "%m : a = %b, b = %b", a, b);
end
// code for data operation by the alu
always @ (*)
begin
case (alucntl)
		3 'b001  :  begin  
		ccset = 0; 
		{carry , aluout} = a + 1; 
		ldt1 = 1;
		 end
		3 'b010  :  begin 
		 ccset = 0; 
		 {carry , aluout} = a + b;
		   ldt1 = 1;
		    end
		3 'b110  :  begin   
        ccset = 1;
        ldt1 = 1; 
			case (opcntl)
				3 'b001  :  {carry , aluout} = a + b;
				3 'b010  :  {carry , aluout} = a - b;
				3 'b011  :  {carry , aluout} = a && b;
				3 'b000  :  {carry , aluout} = a + 0;
				default   :{carry,aluout} = a+b; //  $strobe ($time, "%m : Invalid opcntl signal");
			 endcase
			 end
		3 'b100  :  begin  
		               ccset = 1;  
		              {carry , aluout} = a + 0; 
		               end
		3 'b011  :  begin  ccset = 0;  {carry , aluout} = a - 1;  end
		3 'b000  :  begin  ccset = 0;  {carry , aluout} = a + 0;  end
		default   : {carry,aluout} = a+b ; //  $display ($time, "%m : Invalid alucntl signal");
	endcase
	$strobe ($time, "%m : aluout = %b, carry = %b, ccset = %b, ldt1 = %b", aluout, carry, ccset, ldt1);
end
/* Synchronous part: Performs writes to registers and memory <-> register transfers
     at the end of the current clock cycle*/
always @ (posedge clock)
begin
	if (ldt1) t1 <= aluout;
	case (memcntl)
	3 'b001  :  di <= mem [ a[4:0] ];
	3 'b010  :  irf <= mem [ a[4:0] ];
	3 'b101  :  di <= mem [ b[4:0] ];
	3 'b111  :  
begin
mem [ b[4:0] ] <= a;
mem17<= mem [17];
$strobe($time, " Register mem [17] = %d", mem[17]);
end
	3 'b000  :  
	   $display ($time,"%m : no memory access");
	default  :  
	       
		$display ($time,"%m : illegal memcntl signal");
endcase
case (adestcntl)
	2 'b11  :  pc <= a;
	2 'b01  :  t2 <= a;
	2 'b10  :  regfile[ ry ] <= a;
	2 'b00  :  ;//$display ($time, "%m : no dest-a");
	default  :  ;//$display ($time, "%m : illegal adestcntl");
endcase
case (bdestcntl)
	3 'b100  :  t2 <= b;
	3 'b011  :  pc <= b;
	3 'b101  :  
		begin
			regfile [ rx ] <= b;
			t2 <= b;
		end
	3 'b110  :  
		begin
			regfile [ry ] <= b;
			t2 <= b;
		end
	3 'b010  :  regfile [ ry ] <= b;
	3 'b001  :  regfile [ rx ] <= b;
	3 'b000  : $display ($time, "%m : no dest-b");
	default  : $display ($time, "%m : illegal bdestcntl");
endcase 
$display ($time, "%m : t1, t2, di, irf, ire :  %d, %d, %d, %h, %h", t1, t2, di, irf, ire );  
$strobe ($time, "%m : rx , ry , [rx], [ry] :  %d, %d, %d. %d", rx, ry, regfile[rx], regfile[ry]);
$strobe ($time, "%m : r[%d] = %d, r[%d] = %d, pc = %d", rx, regfile[rx], ry, regfile[ry], pc); 
end
 //computation of condition code bits cc[3 : 0]
always @ (aluout )	
begin
if (aluout == 0) cc[ 0 ] = 1 'b0;		//Z (result is zero) bit setting
else 		cc [ 0 ] = 1 'b0;
		cc [ 1 ] = aluout [ 15 ];	//N (result is negative) bit setting
		cc [ 2 ] = carry;		//C (carry ) bit setting
		cc [ 3 ] = 0; 	// V (the overflow bit) arbitrarily set zero
end
//write to condition code register
always @ (posedge clock)
if (ccset) ccreg <= cc;
//transfer irf to ire
always @(posedge clock)
if (eucntl [ 0 ]) ire <= irf;
//………………………………..I N I T I A L I Z A T I O N S………………………………………………….
/* In the Execution Unit certain registers and memory locations need to be initialized for functional test purposes
These initializations alone are not sufficient. They need to be complemented by the appropriate initializations required in other modules
It is assumed here that in the "controlstore" module  the "controlword" register that provides synchronous output from the module "controlstore" is initialized to have all its bits as "0"
Consequently, no register transfers take place in the Execution Unit at the first
positive edge of the clock. However, at the first positive edge of the clock
the "controword" register is updated with the control word value stored at 
ROM address 0 (state st0)
This control word is the first control word of the two control word long start-up sequence.  It operates during the next clock cycle and achieves the following  
at the next positive edge of the clock: 
(1) stores into "irf" register the instruction fetched from the memory using 
initialized value of the "PC" as address for the memory access.
(2) stores the incremented value of the "PC" in "t1"register. 
(3) "controlword" register value is updated  with the control word value stored at  
ROM address 23 (state st23, the second and last state of the start-up sequence)
This control word operates during the next clock cycle and achieves the following 
at the next positive edge of the clock:
Contents of "irf" are copied into "ire"
Contents of "t1" register are transferred to "PC"
"controlword" register value is updated with the control word stored at ROM address provided by the "ib" port of the instruction decoder
Hereafter, normal execution of the instructions begins with the execution of the first instruction (that was fetched by the start-up sequence */ 

/*………………………………………T E S T - P R O G R A M (1)……………………………………………..
A simple 'C' language statement and its corresponding machine language code   
M [17] = M [16] + M [31] - M [30];
Mnemonic		Mem location			Binary code
ld r1, r7@			0		000 001 0001 01 0111
ld r2, (r7 + 15)@		1		000 001 0010 10 0111
				2		000 000 0000 00 1111
ld r3, (r7 + 14)@		3		000 001 0011 10 0111
				4		000 000 0000 00 1110
add r1, r2			5		001 100 0001 00 0010
sub r2, r3			6		010 100 0010 00 0011
st r3, (r7 + 1)@		7		000 010 0011 10 0111
						000 000 0000 00 0001

Also, we need to put initial values in the registers and memory locations that are being read in  (before being written to) by the above code
We will do the following initialization:
r7 = 16;  M [16] = 248; M [31] = 620; M [30] = 1200
The following Verilog code achieves the required initialization of the program segment of the memory M [0 -15], data segment of the memory M [16 - 31] and the programmer's registers to implement the afore mentioned code with the above mentioned data. */
//data initialization:
initial 
begin 
pc<=0;
end

initial
begin
regfile [7] = 16; 
mem [16] = 248; 
mem [31] = 620;
mem [30] = 1200;
end

//program initialization:
initial
begin
mem [0] = 16 'b000_001_0001_01_0111;
mem [1] = 16'b000_001_0010_10_0111;
mem [2] = 16 'b000_000_0000_00_1111;
mem [3] = 16 'b000_001_0011_10_0111;
mem [4] = 16 'b000_000_0000_00_1110;
mem [5] = 16 'b001_100_0001_00_0010;
mem [6] = 16 'b010_100_0010_00_0011;
mem [7] = 16 'b000_010_0011_10_0111;
mem [8] = 16 'b000_000_0000_00_0001;
 end
endmodule

