`timescale 1ns/1ps

module tb_top_module;
    reg clk;

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    reg rst_btn;
    reg btn_up;
    reg btn_down;
    reg edit_enable;
    reg [6:0] edit_sw;
    reg sw;

    wire [7:0] second, minute, hour, day, month, year, century;

    top_module dut (
        .clk(clk),
        .rst_btn(rst_btn),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .edit_enable(edit_enable),
        .edit_sw(edit_sw),
        .sw(sw),

        .led_display_1(led_display_1),
        .led_display_2(led_display_2),
        .led_display_3(led_display_3),
        .led_display_4(led_display_4)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    //Reset taask
    task reset_dut;
    begin
        // Force reset đã debounce để không phải chờ 21-bit debounce
        force dut.w_rst_clean = 1'b1;

        #100;

        force dut.w_rst_clean = 1'b0;

        #100;

        release dut.w_rst_clean;
    end
    endtask

    //Increase pulse task
    task pulse_inc;
    begin
        force dut.w_inc = 1'b1;
        @(posedge clk);
        #1;
        force dut.w_inc = 1'b0;
        @(posedge clk);
        #1;
    end
    endtask

    //Decrease pulse task
    task pulse_dec;
    begin
        force dut.w_dec = 1'b1;
        @(posedge clk);
        #1;
        force dut.w_dec = 1'b0;
        @(posedge clk);
        #1;
    end
    endtask

    //Display time task
    task show_time;
    begin
        $display(
            "%02d:%02d:%02d %02d/%02d/%02d%02d",
            dut.w_hr,
            dut.w_min,
            dut.w_sec,
            dut.w_day,
            dut.w_mon,
            dut.w_cen
            dut.w_yr,
        );
    end
    endtask

    //Select field task
        task select_field;
        input [6:0] field;
    begin
        force dut.w_enable = field;
        #20;
    end
    endtask


    initial begin
        //Initialization
        rst_btn     = 1'b0;
        btn_up      = 1'b0;
        btn_down    = 1'b0;
        edit_enable = 1'b1;       // Enable edit mode
        edit_sw     = 7'b0000000;
        sw          = 1'b0;
   
        reset_dut;
        
        // TC4.1. Underflow
        $display("");
        $display("========================================");
        $display("TC4.1 - MIN UNDERFLOW");
        $display("========================================");

        // Second
        select_field(7'b0000001);
        $display("Second underflow: 00 -> 59");
        
        pulse_dec;

        if (dut.w_sec !== 8'd59) begin
            $display("FAIL: Actual second = %02d", dut.w_sec);
        end
        else begin
            $display("PASS: Second 00 -> 59");
        end

        // Minute
        select_field(7'b0000010);
        $display("Minute underflow: 00 -> 59");
        
        pulse_dec;

        if (dut.w_min !== 8'd59) begin
            $display("FAIL: Actual minute = %02d", dut.w_min);
        end
        else begin
            $display("PASS: Minute 00 -> 59");
        end

        // Hour
        select_field(7'b0000100);
        $display("Hour underflow: 00 -> 23");

        pulse_dec;

        if (dut.w_hr !== 8'd23) begin
            $display("FAIL: Actual hour = %02d", dut.w_hr);
        end
        else begin
            $display("PASS: Hour 00 -> 23");
        end

        // Month
        select_field(7'b0010000);
        $display("Month underflow: 01 -> 12");

        pulse_dec;

        if (dut.w_mon !== 8'd12) begin
            $display("FAIL: Actual month = %02d", dut.w_mon);
        end
        else begin
            $display("PASS: Month 01 -> 12");
        end

        // Year
        select_field(7'b0100000);
        $display("Year underflow: 00 -> 99");

        pulse_dec;

        if (dut.w_yr !== 8'd99) begin
            $display("FAIL: Actual year = %02d", dut.w_yr);
        end
        else begin
            $display("PASS: Year 00 -> 99");
        end

        // Century
        select_field(7'b1000000);
        $display("Century underflow: 00 -> 99");

        pulse_dec;

        if (dut.w_cen !== 8'd99) begin
            $display("FAIL: Actual century = %02d", dut.w_cen);
        end
        else begin
            $display("PASS: Century 00 -> 99");
        end
    
        release dut.w_sec;
        release dut.w_min;
        release dut.w_hr;
        release dut.w_mon;
        release dut.w_yr;
        release dut.w_cen;

    // TC4.2. Overflow
        $display("");
        $display("========================================");
        $display("TC4.2 - MAX OVERFLOW");
        $display("========================================");

        // Second
        force dut.w_sec = 8'd59;
        select_field(7'b0000001);
        $display("Second overflow: 59 -> 00");
        
        pulse_inc;

        if (dut.w_sec !== 8'd0) begin
            $display("FAIL: Actual second = %02d", dut.w_sec);
        end
        else begin
            $display("PASS: Second 59 -> 00");
        end

        // Minute
        force dut.w_min = 8'd59;
        select_field(7'b0000010);
        $display("Minute overflow: 59 -> 00");
        
        pulse_inc;

        if (dut.w_min !== 8'd0) begin
            $display("FAIL: Actual minute = %02d", dut.w_min);
        end
        else begin
            $display("PASS: Minute 59 -> 00");
        end

        // Hour
        force dut.w_hr = 8'd23;
        select_field(7'b0000100);
        $display("Hour overflow: 23 -> 00");

        pulse_inc;

        if (dut.w_hr !== 8'd0) begin
            $display("FAIL: Actual hour = %02d", dut.w_hr);
        end
        else begin
            $display("PASS: Hour 23 -> 00");
        end

        // Month
        force dut.w_mon = 8'd12;
        select_field(7'b0010000);
        $display("Month overflow: 12 -> 01");

        pulse_inc;

        if (dut.w_mon !== 8'd1) begin
            $display("FAIL: Actual month = %02d", dut.w_mon);
        end
        else begin
            $display("PASS: Month 12 -> 01");
        end

        // Year
        force dut.w_yr = 8'd99;
        select_field(7'b0100000);
        $display("Year overflow: 99 -> 00");

        pulse_inc;

        if (dut.w_yr !== 8'd0) begin
            $display("FAIL: Actual year = %02d", dut.w_yr);
        end
        else begin
            $display("PASS: Year 99 -> 00");
        end

        // Century
        force dut.w_cen = 8'd99;
        select_field(7'b1000000);
        $display("Century overflow: 99 -> 00");

        pulse_inc;

        if (dut.w_cen !== 8'd0) begin
            $display("FAIL: Actual century = %02d", dut.w_cen);
        end
        else begin
            $display("PASS: Century 99 -> 00");
        end

        release dut.w_sec;
        release dut.w_min;
        release dut.w_hr;
        release dut.w_mon;
        release dut.w_yr;
        release dut.w_cen;

    // TC4.3. Force max day 
        $display("");
        $display("========================================");
        $display("TC4.3 - FORCE MAX DAY");
        $display("========================================");

        // February in a leap year: 29 days

        $display("February in a leap year:");

        // Set month to Feb
        force dut.w_mon = 8'd2;

        // Set initial date: 29/02/2000 (leap year)
        
        force dut.w_mon = 8'd2;
        force dut.w_cen = 8'd20;
        force dut.w_yr = 8'd00;
        force dut.w_day = 8'd29;

        //Change year to 2010 (not a leap year)

        select_field(7'b1000000); 

        pulse_inc;

        if (dut.w_day !== 8'd28) begin
            $display("FAIL: Actual day = %02d", dut.w_day);
        end
        else begin
            $display("PASS: Day 29 -> 28");
        end
        #100;
        $finish;

        release dut.w_day;
        release dut.w_mon;
        release dut.w_cen;
        release dut.w_yr;    

    end

endmodule

