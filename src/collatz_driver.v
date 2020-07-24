
`timescale 1ns / 1ps

//A not-so-little state machine for implementing Collatz trajectory counts

`define STATE_GET_INPUT 'd0
`define STATE_LOOP 'd1
`define STATE_WAIT_SEND 'd2

//I use logic where Verilog syntax forces me to use reg, but I really mean
//a combinational wire
`define logic reg

module collatz_driver (
    input wire clk,
    input wire rst,

    input wire [31:0] count_TDATA,
    input wire count_TVALID,
    output wire count_TREADY,
    
    input wire [31:0] collatz_TDATA,
    input wire collatz_TVALID,
    output wire collatz_TREADY,
    
    output wire [31:0] num_TDATA,
    output `logic num_TVALID, //I used an always(*) for this just to simplify my life
    input wire num_TREADY,
    
    output wire [31:0] sink_TDATA,
    output wire sink_TVALID,
    input wire sink_TREADY
);
    
    //State of our FSM
    reg [1:0] state = `STATE_GET_INPUT;
    
    //Stores our output number.
    //These are only declared here because other signals reference them.
    //the logic is at the end of the module.
    reg [31:0] traj_count = 0;
    reg traj_count_vld = 0;
    
    //Collatz loop is finished if value is 1 (success) or 0 (error)
    wire collatz_loop_done = (collatz_TDATA[31:1] == 0) && collatz_TVALID;
    wire collatz_loop_error = !collatz_TDATA[0];
    
    //Send either the input number or the looped Collatz number depending
    //on the state
    assign num_TDATA = (state == `STATE_LOOP) ? collatz_TDATA : count_TDATA;
    //This got too messy to do with the ternary operator (?:)
    always @(*) begin
        //Vivado should auto-simplify this, not that we really care about
        //performance either way
        if (state == `STATE_GET_INPUT) begin
            num_TVALID = count_TVALID;
        end else if (state == `STATE_LOOP) begin
            num_TVALID = collatz_TVALID && !collatz_loop_done; 
        end else begin
            num_TVALID = 1'b0;
        end
    end
    assign count_TREADY = (state == `STATE_GET_INPUT) && num_TREADY;
    assign collatz_TREADY = (state == `STATE_LOOP);
    
    //Next state logic
    always @(posedge clk) begin
        case (state)
        
        `STATE_GET_INPUT: begin
            state <= (count_TVALID && count_TREADY) ? `STATE_LOOP : `STATE_GET_INPUT;
        end
        
        `STATE_LOOP: begin
            state <= collatz_loop_done ? `STATE_WAIT_SEND : `STATE_LOOP;
        end
        
        `STATE_WAIT_SEND: begin
            state <= sink_TREADY ? `STATE_GET_INPUT : `STATE_WAIT_SEND;
        end
        
        endcase
    end
    
    //Trajectory count logic
    always @(posedge clk) begin
        if (state == `STATE_LOOP) begin
            traj_count <= (collatz_loop_done && collatz_loop_error) ? 
                          32'h2BAD2BAD 
                          : traj_count +  (num_TVALID && num_TREADY);
            traj_count_vld <= collatz_loop_done;
        end else if (state == `STATE_WAIT_SEND) begin
            traj_count <= sink_TREADY ? 1 : traj_count; //I was having an off-by-one error
            traj_count_vld <= sink_TREADY ? 0 : traj_count_vld;
        end else begin
            //I think this else clause is needed to prevent Vivado from
            //synthesizing a latch, but I'm not sure. Anyway, it doesn't
            //hurt to put it anyway
            traj_count <= traj_count;
            traj_count_vld <= traj_count_vld;
        end
    end
    
    assign sink_TDATA = traj_count;
    assign sink_TVALID = traj_count_vld;
    
endmodule

