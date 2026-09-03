module top_module(
    input wire clk,            
    input wire rst_btn,        
    input wire btn_up,         
    input wire btn_down,       
    input wire edit_enable,    
    input wire [6:0] edit_sw,  
    input wire sw,                // Công tắc chọn hiển thị: 0 = Giờ/Phút/Giây, 1 = Ngày/Tháng/Năm
    
    output wire [13:0] led_display_1, 
    output wire [13:0] led_display_2, 
    output wire [13:0] led_display_3, 
    output wire [13:0] led_display_4
);

    // Các dây nối nội bộ
    wire w_rst_clean, w_switch, w_tick_1s, w_inc, w_dec;
    wire [6:0] w_enable, w_blink_mask;
    wire [7:0] w_sec, w_min, w_hr, w_day, w_mon, w_yr, w_cen;

    // =========================================================
    // 1. KHỐI CONTROLLER TỔNG HỢP (Chứa Debounce & Blink)
    // =========================================================
    controller_v2 u_controller (
        .clk(clk),
        .rst_btn(rst_btn),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .edit_enable(edit_enable),
        .edit_sw(edit_sw),

        .rst_clean(w_rst_clean),
        .switch(w_switch),
        .enable(w_enable),
        .inc_out(w_inc),
        .dec_out(w_dec),
        .mode(), // Không cần lôi ra top nữa
        .tick_1s(w_tick_1s),
        .blink_mask(w_blink_mask)
    );

    // =========================================================
    // 2. KHỐI ĐẾM THỜI GIAN THỰC
    // =========================================================
    top_module_time_counter u_time_counter (
        .clk_i(clk),
        .rst(w_rst_clean),     // Nhận lệnh reset đã qua lọc nhiễu
        .tick(w_tick_1s),      
        .enable(w_enable),     
        .inc(w_inc),           // Nhận xung tăng đã lọc nhiễu
        .dec(w_dec),           // Nhận xung giảm đã lọc nhiễu
        .mode(edit_enable),    
        .second(w_sec), .minute(w_min), .hour(w_hr), 
        .day(w_day), .month(w_mon), .year(w_yr), .century(w_cen)
    );

    // =========================================================
    // 3. KHỐI HIỂN THỊ
    // =========================================================
    Display u_display (
        .switch(sw),
        .edit_enable(edit_enable),
        .blink_mask(w_blink_mask), // Nhận mặt nạ nháy từ controller
        .second(w_sec), .minute(w_min), .hour(w_hr), 
        .day(w_day), .month(w_mon), .year(w_yr), .century(w_cen),
        .led1(led_display_1), .led2(led_display_2),
        .led3(led_display_3), .led4(led_display_4)
    );

endmodule
