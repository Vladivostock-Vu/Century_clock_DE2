module top_module_time_counter(
    input wire clk_i,      // clk hệ thống
    input wire rst,        // reset bất đồng bộ
    input wire tick,       // xung tick (nên kéo dài 1 chu kỳ clk)
    input wire [6:0]enable,     // tín hiệu cho phép điều chỉnh từ controller
    input wire inc,        // tăng giá trị (xung 1 chu kỳ clk)
    input wire dec,        // giảm giá trị (xung 1 chu kỳ clk)
    input wire mode,       // 0: chế độ bth, 1: điều chỉnh
    output wire [7:0] second, minute, hour, day, month, year, century
);
// tìm max day cho tháng hiện tại dựa vào năm hiện tại
wire [7:0] max_day;
find_max_day find_max_day_inst(
    .month(month),
    .year({century, year}),
    .max_day(max_day)
);
//counter giây
wire carry_second;
time_unit_counter #(.MIN_VALUE(8'h0))second_counter(
    .clk_i(clk_i),
    .max_value(8'h59),
    .rst(rst),
    .tick(tick),
    .en(enable[0]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(second),
    .carry_out(carry_second)
);
//counter phút
wire carry_minute;
time_unit_counter #(.MIN_VALUE(8'h0)) minute_counter(
    .clk_i(clk_i),
    .max_value(8'h59),
    .rst(rst),
    .tick(carry_second),
    .en(enable[1]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(minute),
    .carry_out(carry_minute)
);
//counter giờ
wire carry_hour;
time_unit_counter #(.MIN_VALUE(8'h0)) hour_counter(
    .max_value(8'h23),
    .clk_i(clk_i),
    .rst(rst),
    .tick(carry_minute),
    .en(enable[2]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(hour),
    .carry_out(carry_hour)
);
//counter ngày
wire carry_day;
time_unit_counter #(.MIN_VALUE(8'h1)) day_counter(
    .max_value(max_day),
    .clk_i(clk_i),
    .rst(rst),
    .tick(carry_hour),
    .en(enable[3]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(day),
    .carry_out(carry_day)
);
//counter tháng
wire carry_month;
time_unit_counter #(.MIN_VALUE(8'h1)) month_counter(
    .max_value(8'h12),
    .clk_i(clk_i),
    .rst(rst),
    .tick(carry_day),
    .en(enable[4]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(month),
    .carry_out(carry_month)
);
//counter năm
wire carry_year;
time_unit_counter #(.MIN_VALUE(8'h0)) year_counter(
    .max_value(8'h99),
    .clk_i(clk_i),
    .rst(rst),
    .tick(carry_month),
    .en(enable[5]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(year),
    .carry_out(carry_year)
);
//counter thế kỷ
time_unit_counter #(.MIN_VALUE(8'h0)) century_counter(
    .max_value(8'h99),
    .clk_i(clk_i),
    .rst(rst),
    .tick(carry_year),
    .en(enable[6]),
    .inc(inc),
    .dec(dec),
    .mode(mode),
    .counter(century),
    .carry_out()
);

endmodule