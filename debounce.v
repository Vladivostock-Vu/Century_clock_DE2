module debounce #(
    parameter WIDTH = 8,          // Số lượng tín hiệu đầu vào cần debounce
    parameter COUNTER_WIDTH = 21  // Số bit của bộ đếm thời gian (quyết định thời gian debounce)
)(
    input wire clk, 
    input wire reset,
    input wire [WIDTH-1:0] sw,      // Mảng tín hiệu đầu vào
    output reg [WIDTH-1:0] db_level, // Mảng tín hiệu đầu ra mức (level)
    output reg [WIDTH-1:0] db_tick   // Mảng tín hiệu đầu ra xung (tick)
);

    // Khai báo mảng thanh ghi cho FSM và bộ đếm của từng tín hiệu
    reg [COUNTER_WIDTH-1:0] q_next [0:WIDTH-1];
    reg [COUNTER_WIDTH-1:0] q_reg  [0:WIDTH-1];
    reg [1:0] state_next [0:WIDTH-1];
    reg [1:0] state_reg  [0:WIDTH-1];

    // Định nghĩa các trạng thái
    localparam [1:0] 
        zero  = 2'b00,
        wait1 = 2'b01,
        one   = 2'b10,
        wait0 = 2'b11;

    integer i;

    // Khối cập nhật trạng thái (Sequential Logic)
    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            for (i = 0; i < WIDTH; i = i + 1) begin
                state_reg[i] <= zero;
                q_reg[i]     <= 0;
            end
        end else begin 
            for (i = 0; i < WIDTH; i = i + 1) begin
                state_reg[i] <= state_next[i]; 
                q_reg[i]     <= q_next[i]; 
            end
        end
    end

    // Khối tính toán trạng thái tiếp theo (Combinational Logic)
    always @(*) begin
        for (i = 0; i < WIDTH; i = i + 1) begin
            // Gán giá trị mặc định tránh sinh Latch
            state_next[i] = state_reg[i];
            q_next[i]     = q_reg[i];
            db_tick[i]    = 1'b0;
            db_level[i]   = 1'b0; 

            case(state_reg[i])
                zero: begin 
                    db_level[i] = 1'b0; 
                    if (sw[i]) begin 
                        q_next[i] = {COUNTER_WIDTH{1'b1}}; 
                        state_next[i] = wait1; 
                    end
                end
                wait1: begin
                    db_level[i] = 1'b0; 
                    if (sw[i]) begin
                        q_next[i] = q_reg[i] - 1;
                        if (q_next[i] == 0) begin
                            state_next[i] = one;
                            db_tick[i] = 1'b1;
                        end
                    end else begin 
                        state_next[i] = zero;
                    end
                end
                one: begin
                    db_level[i] = 1'b1; 
                    if (~sw[i]) begin
                        q_next[i] = {COUNTER_WIDTH{1'b1}};
                        state_next[i] = wait0;
                    end else begin
                        state_next[i] = one;
                    end
                end
                wait0: begin
                    db_level[i] = 1'b1; 
                    if (~sw[i]) begin
                        q_next[i] = q_reg[i] - 1;
                        if (q_next[i] == 0) begin
                            state_next[i] = zero;
                        end
                    end else begin 
                        state_next[i] = one; // SỬA LỖI: Nếu dội ngược về 1 thì quay lại state 'one'
                    end
                end
                default: state_next[i] = zero;
            endcase
        end
    end

endmodule