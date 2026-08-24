`timescale 1ms / 1us

module tb_adjust_time_in_day();
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

    // Tạo xung clock
    always #1 clk_i = ~clk_i;

    // Task tạo xung tăng
    task apply_inc;
        begin
            @(posedge clk_i);
            inc = 1;
            @(posedge clk_i);
            inc = 0;
        end
    endtask

    // Task tạo xung giảm
    task apply_dec;
        begin
            @(posedge clk_i);
            dec = 1;
            @(posedge clk_i);
            dec = 0;
        end
    endtask

    // Task gán nhanh thời gian (chỉ quan tâm giờ, phút, giây)
    task set_time(input [7:0] h, input [7:0] m, input [7:0] s);
        begin
            uut.hour_counter.counter   = h;
            uut.minute_counter.counter = m;
            uut.second_counter.counter = s;
        end
    endtask

    initial begin
        // 1. Khởi tạo
        clk_i = 0; rst = 1; tick = 0; enable = 7'b0; inc = 0; dec = 0;
        
        #10;
        rst = 0;
        mode = 1; // Chuyển sang chế độ điều chỉnh thời gian
        #10;

        $display("==================================================");
        $display("KIEM TRA CHE DO DIEU CHINH THOI GIAN (MODE = 1)");
        $display("==================================================");

        // ---------------------------------------------------------
        $display("--- 1. DIEU CHINH GIAY (enable[0]) ---");
        enable = 7'b0000001; // Bật bit enable cho giây[cite: 4]
        set_time(8'h12, 8'h30, 8'h58); 
        
        apply_inc(); // 58 -> 59
        #5; $display("INC giay: %x:%x:%x", hour, minute, second);
        
        apply_inc(); // 59 -> 00 (Tràn giá trị max_value, phút không đổi)
        #5; $display("INC giay (Max->00): %x:%x:%x", hour, minute, second);
        
        apply_dec(); // 00 -> 59 (Giảm qua mức 0, vòng về max_value)
        #5; $display("DEC giay (00->Max): %x:%x:%x", hour, minute, second);

        // ---------------------------------------------------------
        $display("\n--- 2. DIEU CHINH PHUT (enable[1]) ---");
        enable = 7'b0000010; // Bật bit enable cho phút[cite: 4]
        set_time(8'h12, 8'h58, 8'h00); 
        
        apply_inc(); // 58 -> 59
        #5; $display("INC phut: %x:%x:%x", hour, minute, second);
        
        apply_inc(); // 59 -> 00 (Tràn giá trị max_value, giờ không đổi)[cite: 3]
        #5; $display("INC phut (Max->00): %x:%x:%x", hour, minute, second);
        
        apply_dec(); // 00 -> 59 
        #5; $display("DEC phut (00->Max): %x:%x:%x", hour, minute, second);

        // ---------------------------------------------------------
        $display("\n--- 3. DIEU CHINH GIO (enable[2]) ---");
        enable = 7'b0000100; // Bật bit enable cho giờ[cite: 4]
        set_time(8'h22, 8'h00, 8'h00); 
        
        apply_inc(); // 22 -> 23
        #5; $display("INC gio: %x:%x:%x", hour, minute, second);
        
        apply_inc(); // 23 -> 00 (Tràn giá trị max_value 23 về 00)[cite: 3, 4]
        #5; $display("INC gio (Max->00): %x:%x:%x", hour, minute, second);
        
        apply_dec(); // 00 -> 23 
        #5; $display("DEC gio (00->Max): %x:%x:%x", hour, minute, second);

        $display("==================================================");
        $finish;
    end
endmodule