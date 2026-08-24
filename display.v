module Display(
    input mode_switch,              // 1: Giờ/Phút/Giây, 0: Ngày/Tháng/Năm
    input [6:0] blink_mask,         // Nhận từ khối blink_mask_generator
    input [7:0] second, minute, hour, day, month, year, century, // Nhận từ top_module_time_counter
    output reg [13:0] led1, led2, led3, led4
);

    // Khai báo dây nối giải mã
    wire [13:0] seg_s, seg_mi, seg_h;
    wire [13:0] seg_d, seg_mo, seg_y, seg_c;

    // Gọi các bộ giải mã BCD sang 7 đoạn (Module bcd2seg bạn tự giữ nguyên nhé)
    bcd2seg bcd2seg_s(.bcd(second), .sseg(seg_s));
    bcd2seg bcd2seg_mi(.bcd(minute), .sseg(seg_mi));
    bcd2seg bcd2seg_h(.bcd(hour), .sseg(seg_h));
    bcd2seg bcd2seg_d(.bcd(day), .sseg(seg_d));
    bcd2seg bcd2seg_mo(.bcd(month), .sseg(seg_mo));
    bcd2seg bcd2seg_y(.bcd(year), .sseg(seg_y));
    bcd2seg bcd2seg_c(.bcd(century), .sseg(seg_c));

    always @(*) begin
        if(mode_switch) begin
            // ================= CHẾ ĐỘ THỜI GIAN =================
            // bit 0: giây, bit 1: phút, bit 2: giờ
            led1 = blink_mask[0] ? seg_s  : 14'b11111111111111; 
            led2 = blink_mask[1] ? seg_mi : 14'b11111111111111; 
            led3 = blink_mask[2] ? seg_h  : 14'b11111111111111; 
            led4 = 14'b11111111111111; // Luôn tắt ở chế độ thời gian
        end
        else begin
            // ================= CHẾ ĐỘ NGÀY THÁNG =================
            // bit 3: ngày, bit 4: tháng, bit 5: năm, bit 6: thế kỉ
            led1 = blink_mask[3] ? seg_d  : 14'b11111111111111; 
            led2 = blink_mask[4] ? seg_mo : 14'b11111111111111; 
            led4 = blink_mask[5] ? seg_y  : 14'b11111111111111; // Lấy theo đúng vị trí code cũ của bạn
            led3 = blink_mask[6] ? seg_c  : 14'b11111111111111; 
        end
    end
endmodule