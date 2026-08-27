module controller_v2 (
    input wire clk,
    input wire rst_btn,       // Nút reset (chưa qua chống dội)
    input wire btn_up,        // Nút up (chưa qua chống dội)
    input wire btn_down,      // Nút down (chưa qua chống dội)
    input wire edit_enable,   // Công tắc bật/tắt mode chỉnh sửa
    input wire [6:0] edit_sw, // 7 công tắc chọn trường chỉnh sửa
    
    output wire rst_clean,    // Xuất nút reset đã làm sạch ra ngoài để reset các khối khác
    output reg switch,          // 0 = Giờ/Phút/Giây, 1 = Ngày/Tháng/Năm
    output reg [3:0] sel,
    output wire [6:0] enable, // Xuất trực tiếp tín hiệu enable cho bộ đếm
    output wire inc_out,      // TÁCH: Xung tăng (đã làm sạch)
    output wire dec_out,      // TÁCH: Xung giảm (đã làm sạch)
    output reg mode,
    output wire tick_1s,      // Xung 1s cho bộ đếm
    output wire [6:0] blink_mask // Mặt nạ chớp tắt cho Display
);

    // =========================================================
    // 1. NHÚNG MODULE CHỐNG DỘI (DEBOUNCE)
    // =========================================================
    wire [2:0] db_tick;
    debounce #(
        .WIDTH(3), 
        .COUNTER_WIDTH(21)
    ) btn_debouncer (
        .clk(clk),
        .reset(1'b0),
        .sw({rst_btn, btn_up, btn_down}),
        .db_level(),
        .db_tick(db_tick)
    );
    
    // Gán tín hiệu đã làm sạch
    assign rst_clean = db_tick[2];
    assign inc_out   = db_tick[1]; // Tách xung tăng
    assign dec_out   = db_tick[0]; // Tách xung giảm
    
    // Tạm thời nối thẳng switch vào enable (nếu sau này viết FSM thì đổi thành reg sau)
    assign enable = edit_sw;

    // =========================================================
    // 2. NHÚNG MODULE TẠO NHẤP NHÁY (BLINK MASK)
    // =========================================================
    blink_mask_generator u_blink (
        .clk(clk),
        .rst_n(~rst_clean), // Tích cực mức thấp nên đảo lại
        .edit_sw(edit_sw),
        .blink_mask(blink_mask)
    );

    // =========================================================
    // 3. LOGIC TIMER VÀ switch
    // =========================================================
    wire tick_60s;
    
    timer_tick #(.CLK_FREQ(50000000), .SECONDS(60)) timer_inst (
        .clk(clk), .rst_n(~rst_clean), .en(~mode), .tick_out(tick_60s)
    );
    
    timer_tick #(.CLK_FREQ(50000000), .SECONDS(1)) timer_1s_inst (
        .clk(clk), .rst_n(~rst_clean), .en(~mode), .tick_out(tick_1s)
    );

    always @(posedge clk or posedge rst_clean) begin
        if(rst_clean) begin
            sel <= 4'b0000;
            mode <= 1'b0;
            switch <= 1'b0;
        end
        else begin
            mode <= edit_enable; 
            if(tick_60s) begin
                switch <= ~switch;
            end
        end
    end
endmodule