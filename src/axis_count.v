`timescale 1ns / 1ps

//A simple 32-bit AXI Stream counter. Obeys backpressure

module axis_count (
    input wire clk,
    input wire rst,
    
    output wire [31:0] count_TDATA,
    output wire count_TVALID,
    input wire count_TREADY
);

    reg [31:0] cnt = 0;
    
    always @(posedge clk) begin
        if (count_TREADY) begin
            cnt <= cnt + 1;
        end
        
        if (rst) begin
            cnt <= 0; //Uses last assignment wins rule
        end
    end
    
    assign count_TVALID = !rst;
    assign count_TDATA = cnt;

endmodule

