`timescale 1ms / 1us

module tb_normal_run_rtc();
    reg clk_i;
    reg rst;
    reg tick;
    reg [6:0] enable;
    reg inc;
    reg dec;
    reg mode;

    wire [7:0] second, minute, hour, day, month, year, century;

    // Khởi tạo khối top module
    top_module_time_counter uut (
        .clk_i(clk_i),
        .rst(rst),
        .tick(tick),
        .enable(enable),
        .inc(inc),
        .dec(dec),
        .mode(mode),
        .second(second),
        .minute(minute),
        .hour(hour),
        .day(day),
        .month(month),
        .year(year),
        .century(century)
    );

    // Tạo xung clock 500Hz (T = 2ms -> nửa chu kỳ = 1ms)
    always #1 clk_i = ~clk_i;

    integer i; // Biến vòng lặp đếm số giây

    initial begin
        // 1. Khởi tạo tín hiệu ban đầu
        clk_i = 0;
        rst = 1;
        tick = 0;
        enable = 7'b0;
        inc = 0;
        dec = 0;
        mode = 0; // Chế độ chạy bình thường

        #10;
        rst = 0;

        // 2. Thiết lập thời gian xuất phát là 00:00:00 ngày 01/01/2024
        uut.century_counter.counter = 8'h20;
        uut.year_counter.counter    = 8'h24;
        uut.month_counter.counter   = 8'h01;
        uut.day_counter.counter     = 8'h01;
        uut.hour_counter.counter    = 8'h00;
        uut.minute_counter.counter  = 8'h00;
        uut.second_counter.counter  = 8'h00;
        #10;

        $display("=====================================================");
        $display("BAT DAU CHAY TUAN TU 1 NGAY (86400 GIAY)");
        $display("Thoi gian bat dau: %x:%x:%x - %x/%x/%x%x", 
                 hour, minute, second, day, month, century, year);
        $display("=====================================================");

        // Theo dõi sự thay đổi của giờ và ngày để in ra log
        $monitor("Thoi gian cap nhat: %x:%x:%x - Ngay %x Thang %x Nam %x%x", 
                 hour, minute, second, day, month, century, year);

        // 3. Chạy vòng lặp 86405 lần (1 ngày = 86400 giây + 5 giây dư để xem bước sang ngày mới)
        for (i = 0; i < 86405; i = i + 1) begin
            // Tạo 1 xung tick kéo dài đúng 1 chu kỳ clk_i
            @(posedge clk_i);
            tick = 1;
            @(posedge clk_i);
            tick = 0;
            
            // Tạm dừng việc in log toàn bộ giây, chỉ bật in ($monitor) ở 2 giây đầu, 
            // các phút/giờ quan trọng, hoặc vài giây cuối ngày để tránh spam log
            if (i > 5 && i < 86395 && (minute != 8'h00 || second != 8'h00)) begin
                $monitoroff; // Tắt tự động in
            end else begin
                $monitoron;  // Bật lại tự động in ở các mốc chẵn giờ hoặc cuối ngày
            end
        end

        #20;
        $display("=====================================================");
        $display("KET THUC MO PHONG 1 NGAY");
        $display("=====================================================");
        $finish;
    end
endmodule