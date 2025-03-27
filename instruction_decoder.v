`timescale 1ns / 1ps

module instdecoder (
    input [15:0] instcode,
    output reg [4:0] ib, sb,
    output reg [2:0] op_s
);
always @(*) begin
    casex (instcode)
        16'b001100xxxx00xxxx, 16'b010100xxxx00xxxx, 16'b011100xxxx00xxxx: 
            begin ib = 5'd17; sb = 5'd0; op_s = instcode[15:13]; end
        
        16'b001100xxxx01xxxx, 16'b010100xxxx01xxxx, 16'b011100xxxx01xxxx:
            begin ib = 5'd5; sb = 5'd12; op_s = instcode[15:13]; end
        
        16'b001100xxxx10xxxx, 16'b010100xxxx10xxxx, 16'b011100xxxx10xxxx:
            begin ib = 5'd1; sb = 5'd12; op_s = instcode[15:13]; end
        
        16'b000001xxxx00xxxx:
            begin ib = 5'd15; sb = 5'd0; op_s = instcode[15:13]; end
        
        16'b000001xxxx01xxxx:
            begin ib = 5'd5; sb = 5'd10; op_s = instcode[15:13]; end
        
        16'b000001xxxx10xxxx:
            begin ib = 5'd1; sb = 5'd10; op_s = instcode[15:13]; end
        
        16'b000010xxxx00xxxx:
            begin ib = 5'd16; sb = 5'd0; op_s = instcode[15:13]; end
        
        16'b000010xxxx01xxxx:
            begin ib = 5'd5; sb = 5'd11; op_s = instcode[15:13]; end
        
        16'b000010xxxx10xxxx:
            begin ib = 5'd1; sb = 5'd11; op_s = instcode[15:13]; end
        
        16'b000101xxxxxxxxxx:
            begin ib = 5'd9; sb = 5'd0; op_s = instcode[15:13]; end
        
        16'b000110xxxxxxxxxx:
            begin ib = 5'd19; sb = 5'd0; op_s = instcode[15:13]; end
        
        16'b001110xxxxxxxxxx:
            begin ib = 5'd21; sb = 5'd0; op_s = instcode[15:13]; end
        
        16'b000011xxxx01xxxx:
            begin ib = 5'd5; sb = 5'd14; op_s = instcode[15:13]; end
        
        16'b000011xxxx10xxxx:
            begin ib = 5'd1; sb = 5'd14; op_s = instcode[15:13]; end
        
        default:
            begin ib = 5'd31; sb = 5'd31; op_s = 3'd7; end
    endcase
end

endmodule
