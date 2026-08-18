module is_leap_year (
    input wire [15:0] year, //Year in BCD format
    output wire is_leap_year,
);

wire [3:0] thousands, hundreds, tens, units;
wire div4, div100, div400;

assign thousands = year[15:12];
assign hundreds = year[11:8];
assign tens = year[7:4];
assign units = year[3:0];

//Check if the year is divisible by 4
//If tens is even, then units must be divisible by 4
//If tens is odd, then units must be 2 or 6
assign div4 = (~tens[0] && (units[1:0] == 2'b00)) ||
              ( tens[0] && (units[1:0] == 2'b10);

//Check if the year is divisible by 100
assign div100 = {tens, units} == 8'b00000000;

//Check if the year is divisible by 400
//The year must be divisible by 100 and the century prefix must be divisible by 4
assign div400 = div100 && 
                (~thousands[0] && (hundreds[1:0] == 2'b00)) ||
                ( thousands[0] && (hundreds[1:0] == 2'b10);

assign is_leap_year = div4 && (!div100 || div400);

endmodule
