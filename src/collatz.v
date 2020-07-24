`timescale 1ns / 1ps

//Computes the Collatz function on its input. Returns zero if an overflow
//occurred

module collatz (
    input wire clk,
    input wire rst,
    
    
    input wire [31:0] num_TDATA,
    input wire num_TVALID,
    output wire num_TREADY,
    
    output wire [31:0] collatz_TDATA,
    output wire collatz_TVALID,
    input wire collatz_TREADY
);
    
    //Start by computing the Collatz function
    wire is_odd = num_TDATA[0];
    
    //Some intermediate values. Note that we compute an extra 33rd bit
    wire [32:0] two_n_plus_one = {num_TDATA, 1'b1}; //Implements a left-shift
    wire [32:0] three_n_plus_one = (num_TDATA + two_n_plus_one);
    wire overflow = three_n_plus_one[32];
    wire [31:0] half_n = {1'b0, num_TDATA[31:1]}; //Implements a right-shift
    
    //The output TDATA is 3n+1 if the input is odd, otherwise n/2
    //(and we have to check for overflows)
    wire [31:0] c_of_n = is_odd ? (overflow ? 0 : three_n_plus_one)
                         : half_n;
    
    
    //To satisfy the requirements of AXI Stream, we need to have a buffering
    //stage between input and output. Specifically, there cannot be a
    //combinational path from collatz_TREADY to collatz_TVALID (which 
    //implicitly happens when you connect this module to the driver)
    
    //https://github.com/esophagus-now/ye_olde_verilogge/tree/master/buffered_handshake
    //http://fpgacpu.ca/fpga/Pipeline_Skid_Buffer.html
    //https://zipcpu.com/blog/2017/08/14/strategies-for-pipelining.html
    
    bhand # (
        .DATA_WIDTH(32)
    ) buffered_handshake (
        .clk(clk),
        .rst(rst),
        
        .idata(c_of_n),
        .idata_vld(num_TVALID),
        .idata_rdy(num_TREADY),
        
        .odata(collatz_TDATA),
        .odata_vld(collatz_TVALID),
        .odata_rdy(collatz_TREADY)
    );
    

endmodule

