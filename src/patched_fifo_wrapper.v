`timescale 1ns / 1ps
//The vanilla AXI Stream FIFO has an unforgivable bug: if its _data_ capacity is X,
//its _packet_ capacity is X/4. For example, if your capacity is 2048, you can only
//store 512 packets. Problem is, the FIFO won't stop you from putting in more 
//packets, and at that point its internal state is messed up.

//So, I added extra logic in this wrapper to fix that problem. This artifically sets
//axi_str_rxd_ready to 0 if there are more than 500 flits in the FIFO. This is 
//very hacky and inefficient, but hey, at least it works

module patched_fifo_wrapper (
	output wire interrupt                 ,
	input wire clk                        ,
	input wire s_axi_aresetn              ,
	input wire [31 : 0] s_axi_awaddr      ,
	input wire s_axi_awvalid              ,
	output wire s_axi_awready             ,
	input wire [31 : 0] s_axi_wdata       ,
	input wire [3 : 0] s_axi_wstrb        ,
	input wire s_axi_wvalid               ,
	output wire s_axi_wready              ,
	output wire [1 : 0] s_axi_bresp       ,
	output wire s_axi_bvalid              ,
	input wire s_axi_bready               ,
	input wire [31 : 0] s_axi_araddr      ,
	input wire s_axi_arvalid              ,
	output wire s_axi_arready             ,
	output wire [31 : 0] s_axi_rdata      ,
	output wire [1 : 0] s_axi_rresp       ,
	output wire s_axi_rvalid              ,
	input wire s_axi_rready               ,
	output wire mm2s_prmry_reset_out_n    ,
	output wire axi_str_txd_tvalid        ,
	input wire axi_str_txd_tready         ,
	output wire axi_str_txd_tlast         ,
	output wire [31 : 0] axi_str_txd_tdata,
	output wire s2mm_prmry_reset_out_n    ,
	input wire axi_str_rxd_tvalid         ,
	output wire axi_str_rxd_tready        ,
	input wire axi_str_rxd_tlast          ,
	input wire [31 : 0] axi_str_rxd_tdata 
);
	
	localparam MAX_FLITS = 500;
	
	//Self-maintained occupancy count.    
    reg [9:0] occupancy_count = 0;
    
    //Pulses when a request is made to read from the FIFO. Technically, the FIFO's occupancy
    //doesn't lower until a few cycles later when the AXI Stream FIFO actually sends back
    //the data on RDATA, but this is better than a complicated bug-prone state machine.
    wire flit_rd_sig = (s_axi_araddr[7:0] == 8'h20 && s_axi_arvalid && s_axi_arready);
    
    //Pulses when a flit is added to the FIFO
    wire flit_wr_sig = (axi_str_rxd_tvalid && axi_str_rxd_tready);   
   
    //These wires plug into the FIFO...
    wire axi_str_rxd_tvalid_internal;
    wire axi_str_rxd_tready_internal;
    //...and this is the ready output of this module. We are only allowed to accept flits
    //from the AXI Stream slave if our self-maintained (approximate) occupancy count is 
    //below 500, which gives us a good safety margin for avoiding that hideous bug I
    //described in the big comment at the top of this file. 
    assign axi_str_rxd_tready = (axi_str_rxd_tready_internal && (occupancy_count <= MAX_FLITS)); 
    assign axi_str_rxd_tvalid_internal = (axi_str_rxd_tvalid && (occupancy_count <= MAX_FLITS));
    
    //Maintain the count of flits in the FIFO
    always @(posedge clk) begin
		//Check for resets. Technically, address and data don't have to
		//be handshaked at the same time, but I've noticed that most AXI
		//Lite receivers will do this
		if ((s_axi_awaddr[7:0] == 8'h28 || s_axi_awaddr[7:0] == 8'h18) &&
			(s_axi_wdata == 32'hA5) &&
			(s_axi_awvalid && s_axi_awready))
			occupancy_count <= 0;
		else
    		//Fingers crossed that this works!
    		occupancy_count <= occupancy_count + flit_wr_sig - flit_rd_sig; 
    end
    
    
patched_fifo your_instance_name (
  .interrupt(interrupt),                            // output wire interrupt
  .s_axi_aclk(clk),                                 // input wire clk
  .s_axi_aresetn(s_axi_aresetn),                    // input wire s_axi_aresetn
  .s_axi_awaddr(s_axi_awaddr),                      // input wire [31 : 0] s_axi_awaddr
  .s_axi_awvalid(s_axi_awvalid),                    // input wire s_axi_awvalid
  .s_axi_awready(s_axi_awready),                    // output wire s_axi_awready
  .s_axi_wdata(s_axi_wdata),                        // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb(s_axi_wstrb),                        // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid(s_axi_wvalid),                      // input wire s_axi_wvalid
  .s_axi_wready(s_axi_wready),                      // output wire s_axi_wready
  .s_axi_bresp(s_axi_bresp),                        // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),                      // output wire s_axi_bvalid
  .s_axi_bready(s_axi_bready),                      // input wire s_axi_bready
  .s_axi_araddr(s_axi_araddr),                      // input wire [31 : 0] s_axi_araddr
  .s_axi_arvalid(s_axi_arvalid),                    // input wire s_axi_arvalid
  .s_axi_arready(s_axi_arready),                    // output wire s_axi_arready
  .s_axi_rdata(s_axi_rdata),                        // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp(s_axi_rresp),                        // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid(s_axi_rvalid),                      // output wire s_axi_rvalid
  .s_axi_rready(s_axi_rready),                      // input wire s_axi_rready
  .mm2s_prmry_reset_out_n(mm2s_prmry_reset_out_n),  // output wire mm2s_prmry_reset_out_n
  .axi_str_txd_tvalid(axi_str_txd_tvalid),          // output wire axi_str_txd_tvalid
  .axi_str_txd_tready(axi_str_txd_tready),          // input wire axi_str_txd_tready
  .axi_str_txd_tlast(axi_str_txd_tlast),            // output wire axi_str_txd_tlast
  .axi_str_txd_tdata(axi_str_txd_tdata),            // output wire [31 : 0] axi_str_txd_tdata
  .s2mm_prmry_reset_out_n(s2mm_prmry_reset_out_n),  // output wire s2mm_prmry_reset_out_n
  .axi_str_rxd_tvalid(axi_str_rxd_tvalid_internal), // input wire axi_str_rxd_tvalid
  .axi_str_rxd_tready(axi_str_rxd_tready_internal), // BUG FIX: this is our internal wire
  .axi_str_rxd_tlast(axi_str_rxd_tlast),            // input wire axi_str_rxd_tlast
  .axi_str_rxd_tdata(axi_str_rxd_tdata)             // input wire [31 : 0] axi_str_rxd_tdata
);    
    
endmodule

