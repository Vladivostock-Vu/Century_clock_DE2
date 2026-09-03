`timescale 1ns / 1ns

module tb_clock_ha;
    // phần 1: dut và nối dây
    reg clk, rst_btn, btn_up, btn_down, edit_enable;
    reg [6:0] edit_sw;

    wire [13:0] led_display_1, led_display_2, led_display_3, led_display_4;

    top_module dut_top (
        .clk(clk), .rst_btn(rst_btn), .btn_up(btn_up), .btn_down(btn_down),
        .edit_enable(edit_enable), .edit_sw(edit_sw),
        .led_display_1(led_display_1), .led_display_2(led_display_2),
        .led_display_3(led_display_3), .led_display_4(led_display_4)
    );

    // phần 4: tạo clock
    parameter CLK_PER = 20; 
    initial begin
        clk = 1'b0; 
        forever #(CLK_PER/2) clk = ~clk; 
    end

    // phần 3: monitor  
    initial begin
        $display("---------------------------------------------------------");
        $display("   Thoi gian thuc   | Ngay/Thang/Nam | Gio:Phut:Giay ");
        $display("---------------------------------------------------------");
        
        $monitor("%t |  %h/%h/%h%h   |  %h:%h:%h", 
                $time, 
                dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, 
                dut_top.w_hr, dut_top.w_min, dut_top.w_sec);
    end

    // phần 2: 12 test case CÓ KÈM TỰ ĐỘNG CHECK PASS/FAIL
    initial begin
        rst_btn = 0; edit_enable = 0; edit_sw = 0; btn_up = 0; btn_down = 0;
        #100; rst_btn = 1; #100; rst_btn = 0; #100;

        //TC1: KIỂM TRA GIÂY, PHÚT, GIỜ        
        $display("---> TC1.1 - Tran giay");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h26;
        force dut_top.u_time_counter.month_counter.counter   = 8'h01; force dut_top.u_time_counter.day_counter.counter     = 8'h01;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h12; force dut_top.u_time_counter.minute_counter.counter  = 8'h30;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/01/2026 - 12:31:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_01_20_26_12_31_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC1.2 - Tran phut");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h26;
        force dut_top.u_time_counter.month_counter.counter   = 8'h01; force dut_top.u_time_counter.day_counter.counter     = 8'h01;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h12; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/01/2026 - 13:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_01_20_26_13_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC1.3 - Tran gio (Qua ngay moi)");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h26;
        force dut_top.u_time_counter.month_counter.counter   = 8'h01; force dut_top.u_time_counter.day_counter.counter     = 8'h01;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 02/01/2026 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h02_01_20_26_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        // TC2: KIỂM TRA NGÀY, THÁNG, NĂM
        $display("---> TC2.1 - Thang 30 ngay");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h26;
        force dut_top.u_time_counter.month_counter.counter   = 8'h04; force dut_top.u_time_counter.day_counter.counter     = 8'h30;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/05/2026 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_05_20_26_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC2.2 - Thang 31 ngay (Chuyen nam)");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h26;
        force dut_top.u_time_counter.month_counter.counter   = 8'h12; force dut_top.u_time_counter.day_counter.counter     = 8'h31;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/01/2027 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_01_20_27_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC2.3 - Thang 2 nam KHONG nhuan");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h26;
        force dut_top.u_time_counter.month_counter.counter   = 8'h02; force dut_top.u_time_counter.day_counter.counter     = 8'h28;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/03/2026 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_03_20_26_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC2.4 - Thang 2 nam NHUAN (ngay 28)");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h24;
        force dut_top.u_time_counter.month_counter.counter   = 8'h02; force dut_top.u_time_counter.day_counter.counter     = 8'h28;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 29/02/2024 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h29_02_20_24_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC2.5 - Thang 2 nam NHUAN (ngay 29)");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h24;
        force dut_top.u_time_counter.month_counter.counter   = 8'h02; force dut_top.u_time_counter.day_counter.counter     = 8'h29;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/03/2024 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_03_20_24_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        //TC3: BIÊN THẾ KỶ
        $display("---> TC3.1 - Chuyen giao the ky");
        force dut_top.u_time_counter.century_counter.counter = 8'h19; force dut_top.u_time_counter.year_counter.counter    = 8'h99;
        force dut_top.u_time_counter.month_counter.counter   = 8'h12; force dut_top.u_time_counter.day_counter.counter     = 8'h31;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/01/2000 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_01_20_00_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC3.2 - Nam nhuan the ky (2000)");
        force dut_top.u_time_counter.century_counter.counter = 8'h20; force dut_top.u_time_counter.year_counter.counter    = 8'h00;
        force dut_top.u_time_counter.month_counter.counter   = 8'h02; force dut_top.u_time_counter.day_counter.counter     = 8'h28;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 29/02/2000 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h29_02_20_00_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC3.3 - Nam KHONG nhuan the ky (2100)");
        force dut_top.u_time_counter.century_counter.counter = 8'h21; force dut_top.u_time_counter.year_counter.counter    = 8'h00;
        force dut_top.u_time_counter.month_counter.counter   = 8'h02; force dut_top.u_time_counter.day_counter.counter     = 8'h28;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/03/2100 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_03_21_00_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("---> TC3.4 - Tran nam BCD cuc dai");
        force dut_top.u_time_counter.century_counter.counter = 8'h99; force dut_top.u_time_counter.year_counter.counter    = 8'h99;
        force dut_top.u_time_counter.month_counter.counter   = 8'h12; force dut_top.u_time_counter.day_counter.counter     = 8'h31;
        force dut_top.u_time_counter.hour_counter.counter    = 8'h23; force dut_top.u_time_counter.minute_counter.counter  = 8'h59;
        force dut_top.u_time_counter.second_counter.counter  = 8'h59;
        #20; 
        release dut_top.u_time_counter.century_counter.counter; release dut_top.u_time_counter.year_counter.counter;
        release dut_top.u_time_counter.month_counter.counter;   release dut_top.u_time_counter.day_counter.counter;
        release dut_top.u_time_counter.hour_counter.counter;    release dut_top.u_time_counter.minute_counter.counter;
        release dut_top.u_time_counter.second_counter.counter;
        #20; force dut_top.w_tick_1s = 1'b1; #20; release dut_top.w_tick_1s; #100;
        // Kiem tra: 01/01/0000 - 00:00:00
        if ({dut_top.w_day, dut_top.w_mon, dut_top.w_cen, dut_top.w_yr, dut_top.w_hr, dut_top.w_min, dut_top.w_sec} == 56'h01_01_00_00_00_00_00)
            $display("   => [PASS]\n"); else $display("   => [FAIL]\n");


        $display("HOAN THANH MO PHONG 12 TEST CASE!");
        $finish; 
    end

endmodule