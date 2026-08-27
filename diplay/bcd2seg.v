module bcd2seg(
    input [7:0] bcd,
    output reg [13:0] sseg
);
     always @(*) begin
        case (bcd[3:0])
            4'h0: sseg[6:0] = 7'b1000000;
            4'h1: sseg[6:0] = 7'b1111001;
            4'h2: sseg[6:0] = 7'b0100100;
            4'h3: sseg[6:0] = 7'b0110000;
            4'h4: sseg[6:0] = 7'b0011001;
            4'h5: sseg[6:0] = 7'b0010010;
            4'h6: sseg[6:0] = 7'b0000010;
            4'h7: sseg[6:0] = 7'b1111000;
            4'h8: sseg[6:0] = 7'b0000000;
            4'h9: sseg[6:0] = 7'b0010000;
            default: sseg[6:0] = 7'b1111111;
        endcase
        case (bcd[7:4])
            4'h0: sseg[13:7] = 7'b1000000;
            4'h1: sseg[13:7] = 7'b1111001;
            4'h2: sseg[13:7] = 7'b0100100;
            4'h3: sseg[13:7] = 7'b0110000;
            4'h4: sseg[13:7] = 7'b0011001;
            4'h5: sseg[13:7] = 7'b0010010;
            4'h6: sseg[13:7] = 7'b0000010;
            4'h7: sseg[13:7] = 7'b1111000;
            4'h8: sseg[13:7] = 7'b0000000;
            4'h9: sseg[13:7] = 7'b0010000;
            default: sseg[13:7] = 7'b1111111;
        endcase
    end
endmodule
    
