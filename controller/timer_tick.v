module timer_tick #(
    parameter CLK_FREQ = 50000000, 
    parameter SECONDS  = 60     
)(
    input wire clk,
    input wire rst_n,
    input wire en, // Tín hiệu cho phép đếm (1 = đếm, 0 = dừng)
    output wire tick_out 
);

    localparam MAX_COUNT = CLK_FREQ * SECONDS;

    reg [31:0] counter; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
        end else if (en) begin // Chỉ tăng biến đếm khi en = 1
            if (counter == MAX_COUNT - 1)
                counter <= 0;
            else
                counter <= counter + 1'b1;
        end
    end

    assign tick_out = (en && counter == MAX_COUNT - 1) ? 1'b1 : 1'b0;

endmodule