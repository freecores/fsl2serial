// This module sends the correct control signals to the slave FSL port in
// order to get the data out.
//
// Alex Marschner
// 2007.02.20

`timescale 1 ns / 100 ps

module fsl_ctrl (
	FSL_S_CLK, FSL_S_DATA, FSL_S_CONTROL, FSL_S_EXISTS, FSL_S_READ,
	FSL_M_CLK, FSL_M_DATA, FSL_M_CONTROL, FSL_M_FULL,   FSL_M_WRITE,
	rs232_tx_ready, rs232_tx_data, rs232_tx_start,
	rs232_rx_ready, rs232_rx_data, rs232_rx_exists,
	clock, reset
);

output wire       FSL_S_CLK;
input  wire [0:7] FSL_S_DATA;
input  wire       FSL_S_CONTROL;
input  wire       FSL_S_EXISTS;
output reg        FSL_S_READ;

output wire       FSL_M_CLK;
output reg  [0:7] FSL_M_DATA;
output reg        FSL_M_CONTROL;
input  wire       FSL_M_FULL;
output reg        FSL_M_WRITE;

output reg        rs232_rx_ready;
input  wire [7:0] rs232_rx_data;
input  wire       rs232_rx_exists;

input  wire       rs232_tx_ready;
output wire [7:0] rs232_tx_data;
output wire       rs232_tx_start;

input  wire       clock, reset;

assign FSL_S_CLK = clock;
//assign FSL_M_CLK = clock;

assign rs232_tx_data = FSL_S_DATA;
assign rs232_tx_start = FSL_S_READ;

always @ (posedge clock) begin
	if(reset) begin
		FSL_S_READ    	 <= 1'b0;
		FSL_M_DATA       <= 8'h00;
		FSL_M_CONTROL    <= 1'b0;
		FSL_M_WRITE      <= 1'b0;
		rs232_rx_ready   <= 1'b0;
	end
	else begin
		FSL_S_READ <= (FSL_S_EXISTS & (~FSL_S_READ) & rs232_tx_ready) ? 1'b1 : 1'b0;
		FSL_M_DATA <= rs232_rx_data;
		FSL_M_CONTROL <= 1'b0;
		FSL_M_WRITE <= (!FSL_M_FULL & (~FSL_M_WRITE) & rs232_rx_exists) ? 1'b1 : 1'b0;
		rs232_rx_ready <= 1'b1;	// always ready to get data from outside
	end
end

endmodule

///////////////////////////////////////////////////////////////////////////////

module fsl_ctrl_tb ( );

reg  clock, reset;
wire FSL_S_CLK, FSL_S_READ;
reg  [0:7] FSL_S_DATA;
reg  FSL_S_CONTROL;
reg  FSL_S_EXISTS;
reg  rs232_tx_ready;
wire [7:0] rs232_tx_data;
wire  rs232_tx_start;
reg  [7:0] registered_out;


fsl_ctrl fsl_ctrl_0(
    .FSL_S_CLK      (FSL_S_CLK),
    .FSL_S_DATA     (FSL_S_DATA),
    .FSL_S_CONTROL  (FSL_S_CONTROL),
    .FSL_S_EXISTS   (FSL_S_EXISTS),
    .FSL_S_READ     (FSL_S_READ),
	.rs232_tx_ready (rs232_tx_ready),
    .rs232_tx_data  (rs232_tx_data),
    .rs232_tx_start (rs232_tx_start),	
	.clock          (clock),
	.reset          (reset)
);

initial begin
	clock <= 1'b0;
	reset <= 1'b1;
	FSL_S_DATA <= 8'h00;
	FSL_S_CONTROL <= 1'b0;
	FSL_S_EXISTS <= 1'b0;
	rs232_tx_ready <= 1'b0;

	#1000 reset <= 1'b0;
	#20   rs232_tx_ready <= 1'b1;

	#1000 FSL_S_DATA <= 8'hA0;
		  FSL_S_EXISTS <= 1'b1;
		  while(~&FSL_S_READ) #1 FSL_S_EXISTS <= 1'b1;
		  while( &FSL_S_READ) #1 FSL_S_EXISTS <= 1'b1;
		  FSL_S_EXISTS <= 1'b0;

	#1000 FSL_S_DATA <= FSL_S_DATA + 1;
		  FSL_S_EXISTS <= 1'b1;
		  while(~&FSL_S_READ) #1 FSL_S_EXISTS <= 1'b1;
		  while( &FSL_S_READ) #1 FSL_S_EXISTS <= 1'b1;
		  FSL_S_EXISTS <= 1'b0;
	
	#1000 FSL_S_DATA <= FSL_S_DATA + 1;
		  FSL_S_EXISTS <= 1'b1;
		  while(~&FSL_S_READ) #1 FSL_S_EXISTS <= 1'b1;
		  while( &FSL_S_READ) #1 FSL_S_EXISTS <= 1'b1;
		  FSL_S_EXISTS <= 1'b0;
	
	#1000 while(1) FSL_S_EXISTS <= 1'b0;
end

always @ (posedge clock) begin
	if(reset) registered_out <= 8'b0;
	else registered_out <= rs232_tx_start ? rs232_tx_data : registered_out;
end

always @ (posedge clock) begin
	if(reset) rs232_tx_ready <= 1'b0;
	else begin
		if(rs232_tx_start) begin
				 rs232_tx_ready <= 1'b0;
			#4000 rs232_tx_ready <= 1'b1;
		end
	end
end

always @ (posedge clock) begin
	FSL_S_EXISTS <= (FSL_S_EXISTS && FSL_S_READ) ? 1'b0 : FSL_S_EXISTS;
	FSL_S_DATA   <= (FSL_S_EXISTS && FSL_S_READ) ? (FSL_S_DATA+1) : FSL_S_DATA;
end

always begin
	#20 clock <= ~clock;
end

endmodule

