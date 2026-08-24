`timescale 1ms / 1us

module tb_full_year_run();
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

    always #1 clk_i = ~clk_i;

    integer i;

    initial begin
        // 1. Khởi tạo tín hiệu ban đầu ở chế độ bình thường (mode = 0)
        clk_i = 0;
        rst = 1;
        tick = 0;
        enable = 7'b0;
        inc = 0;
        dec = 0;
        mode = 0; 

        #10;
        rst = 0;

        // 2. Thiết lập thời gian xuất phát là 23:59:55 ngày 31/12/2023
        // Để quan sát khoảnh khắc chuyển sang năm 2024 ngay lập tức
        uut.century_counter.counter = 8'h20;
        uut.year_counter.counter    = 8'h23;
        uut.month_counter.counter   = 8'h12;
        uut.day_counter.counter     = 8'h31;
        uut.hour_counter.counter    = 8'h23;
        uut.minute_counter.counter  = 8'h59;
        uut.second_counter.counter  = 8'h55;
        #10;

        $display("===============================================================");
        $display("BAT DAU MO PHONG 1 NAM (TU 31/12/2023 DEN 01/01/2025)");
        $display("Thoi gian bat dau: %x:%x:%x - Ngay %x Thang %x Nam %x%x", 
                 hour, minute, second, day, month, century, year);
        $display("===============================================================");

        // 3. Chạy vòng lặp 31,622,410 lần (Trọn vẹn 366 ngày + vài giây dư)
        for (i = 0; i < 31622410; i = i + 1) begin
            // Tạo 1 xung tick[cite: 3, 4]
            @(posedge clk_i);
            tick = 1;
            @(posedge clk_i);
            tick = 0;
            
            // 4. BỘ LỌC HIỂN THỊ LOG (Tránh spam)
            // Chỉ in ra khi bắt đầu một ngày mới (00:00:00)
            if (hour == 8'h00 && minute == 8'h00 && second == 8'h00) begin
                // In mùng 1 đầu tháng, hoặc các ngày cuối tháng 2 (28, 29) để check năm nhuận[cite: 1, 2],
                // hoặc ngày 31/12 cuối năm
                if (day == 8'h01 || 
                   (month == 8'h02 && day >= 8'h28) || 
                   (month == 8'h12 && day >= 8'h31)) begin
                    
                    $display("Cap nhat: %x:%x:%x - Ngay %x Thang %x Nam %x%x", 
                             hour, minute, second, day, month, century, year);
                end
            end
            
            // In riêng giây phút giao thừa sang năm 2025
            if (i >= 31622405) begin
                 $display("Nhung giay cuoi cung / dau nam moi: %x:%x:%x - Ngay %x/%x/%x%x", 
                          hour, minute, second, day, month, century, year);
            end
        end

        #20;
        $display("===============================================================");
        $display("KET THUC MO PHONG");
        $display("===============================================================");
        $finish;
    end
endmodule