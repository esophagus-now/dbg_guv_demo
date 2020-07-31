`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2020 01:57:53 PM
// Design Name: 
// Module Name: help
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Why must Vivado force me to do this hacky BS???

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
  .axi_str_rxd_tvalid(axi_str_rxd_tvalid),          // input wire axi_str_rxd_tvalid
  .axi_str_rxd_tready(axi_str_rxd_tready),          // output wire axi_str_rxd_tready
  .axi_str_rxd_tlast(axi_str_rxd_tlast),            // input wire axi_str_rxd_tlast
  .axi_str_rxd_tdata(axi_str_rxd_tdata)             // input wire [31 : 0] axi_str_rxd_tdata
);    
    
endmodule
