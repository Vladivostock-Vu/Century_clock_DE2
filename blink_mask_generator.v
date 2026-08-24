module blink_mask_generator (
    input wire clk,
    input wire rst_n,
    input wire [6:0] edit_sw,      // 7 switch: [6]Thế kỉ, [5]Năm, [4]Tháng, [3]Ngày, [2]Giờ, [1]Phút, [0]Giây
    output reg [6:0] blink_mask    // 1: Sáng bình thường, 0: Ép tắt
);

    // Khởi tạo bộ đếm 2 giây từ module có sẵn của bạn
    wire tick_2s;
    timer_tick #(
        .CLK_FREQ(50000000), // Đổi thành tần số thật của board bạn (VD: 50MHz)
        .SECONDS(2)          // Đếm 2 giây
    ) u_timer_2s (
        .clk(clk),
        .rst_n(rst_n),
        .en(1'b1),           // Luôn chạy ngầm
        .tick_out(tick_2s)
    );

    // Cờ lật trạng thái Sáng/Tối mỗi 2 giây
    reg blink_state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            blink_state <= 1'b1; 
        else if (tick_2s)
            blink_state <= ~blink_state;
    end

    // So sánh Switch và Trạng thái để ra lệnh tắt LED
    integer i;
    always @(*) begin
        for (i = 0; i < 7; i = i + 1) begin
            if (edit_sw[i] && (blink_state == 1'b0))
                blink_mask[i] = 1'b0; // Tắt
            else
                blink_mask[i] = 1'b1; // Sáng
        end
    end
endmodule
