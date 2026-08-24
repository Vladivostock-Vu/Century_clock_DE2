module find_max_day(
    input [7:0] month,
    input [15:0] year,
    output reg [7:0] max_day
);
    wire leap_year;
    is_leap_year leap_year_inst(
        .year(year),
        .is_leap_year(leap_year)
    );
    always @(*) begin
        case (month)
            8'h1, 8'h3, 8'h5, 8'h7, 8'h8, 8'h10, 8'h12: max_day = 8'h31;
            8'h4, 8'h6, 8'h9, 8'h11: max_day = 8'h30;
            8'h2: max_day = leap_year ? 8'h29 : 8'h28;
            default: max_day = 8'h0; // Invalid month
        endcase
    end
endmodule