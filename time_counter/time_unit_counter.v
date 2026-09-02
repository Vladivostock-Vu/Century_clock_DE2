module time_unit_counter #(
    parameter MIN_VALUE = 8'h0
)
(
    input wire clk_i,      // clk hệ thống
    input wire rst,        // reset bất đồng bộ
    input wire tick,       // xung tick (nên kéo dài 1 chu kỳ clk)
    input wire en,         // tín hiệu cho phép điều chỉnh từ controller
    input wire inc,        // tăng giá trị (xung 1 chu kỳ clk)
    input wire dec,        // giảm giá trị (xung 1 chu kỳ clk)
    input wire mode,       // 0: chế độ bth, 1: điều chỉnh
    // Chỉ bật cho counter cần ép giá trị
    input  wire clamp_enable,
    input wire [7:0] max_value, // giá trị tối đa của counter 
    output reg [7:0] counter, // counter 0 - max_value (mã BCD)
    output wire carry_out   // tín hiệu báo tràn khi counter = max_value
);
// trước để tuần tự bị trễ mất 1 chu kì, nên cần tạo comb 
    assign carry_out = !mode && tick && (counter == max_value);
     // Giá trị vượt giới hạn
    wire value_invalid;
    assign value_invalid = clamp_enable && (counter > max_value);

    always @(posedge clk_i or posedge rst) begin
        if (rst) begin
            counter <= MIN_VALUE;
        end
        // Ưu tiên ép giá trị hợp lệ
        else if (value_invalid) begin
            counter <= max_value;
        end
        else begin
            if (!mode) begin // chế độ bình thường
                if (tick) begin
                    if (counter == max_value) begin
                        counter <= MIN_VALUE;
                    end
                    else begin
                        if (counter[3:0] == 4'h9) begin
                            counter[3:0] <= 4'd0;
                            counter[7:4] <= counter[7:4] + 1'b1;
                        end
                        else begin
                            counter[3:0] <= counter[3:0] + 1'b1;
                        end
                    end
                end
            end
            else begin // chế độ điều chỉnh
            counter <= counter; // giữ nguyên giá trị counter nếu không có xung inc hoặc dec
                if (en) begin
                    if (inc) begin
                        if (counter == max_value) begin // không làm tăng giá trị phía sau
                            counter <= MIN_VALUE;
                        end
                        else begin
                            if (counter[3:0] == 4'h9) begin
                                counter[3:0] <= 4'd0;
                                counter[7:4] <= counter[7:4] + 1'b1;
                            end
                            else begin
                                counter[3:0] <= counter[3:0] + 1'b1;
                            end
                        end
                    end
                    else if (dec) begin
                        if (counter == MIN_VALUE) begin
                            counter <= max_value;
                        end
                        else begin
                            if (counter[3:0] == 4'h0) begin
                                counter[3:0] <= 4'h9;
                                counter[7:4] <= counter[7:4] - 1'b1;
                            end
                            else begin
                                counter[3:0] <= counter[3:0] - 1'b1;
                            end
                        end
                    end
                end
            end
        end
    end
endmodule
