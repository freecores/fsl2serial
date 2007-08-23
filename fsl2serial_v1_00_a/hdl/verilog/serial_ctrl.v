// This module controls the serial modules.
//
// Alex Marschner
// 2007.02.20

`timescale 1 ns / 100 ps 

module serial_ctrl (
	fsl_data_i, fsl_senddata_i, fsl_cts_o,
	fsl_data_o, fsl_rxdata_o,   fsl_cts_i,
	rs232_tx_data_o, rs232_rx_data_i, rs232_rts_i, rs232_cts_o,
	clock, reset
);

parameter CLOCK_FREQ_MHZ = 50;
parameter BAUD_RATE = 115200;

input  wire [7:0] fsl_data_i;
input  wire       fsl_senddata_i;
output reg        fsl_cts_o;
output reg  [7:0] fsl_data_o;
output reg        fsl_rxdata_o;
input  wire       fsl_cts_i;
output wire       rs232_tx_data_o;
input  wire       rs232_rx_data_i;  // serial == 1 wire :)
input  wire       rs232_rts_i;
output reg        rs232_cts_o;

input  wire       clock, reset;

wire [7:0] rs232_rx_data;
wire       rs232_tx_ready;
reg        rs232_rts;
wire       rs232_rx_have_data;

	///////////////////////////////////////////////////////////////////////////
	// Serial In Module
    serial_in 
        #(
            .clk_freq(CLOCK_FREQ_MHZ * 1000000),
            .data_rate(BAUD_RATE),
			.delay_size(14)
		) serial_in0 (
            .clk(clock), 
            .rst(reset), 
            .serial_i(rs232_rx_data_i), 		// serial input line
            .data_o(rs232_rx_data), 			// parallel data received
            .have_data_o(rs232_rx_have_data)	// data_exists line
		);
    
	///////////////////////////////////////////////////////////////////////////
	// Serial Out Module
    serial_out
        #(
            .clk_freq(CLOCK_FREQ_MHZ * 1000000),
            .data_rate(BAUD_RATE))
        serial_out0(
            .clk(clock), 
            .rst(reset), 
            .data_size_i(8),
            .data_i(fsl_data_i),			// data to send out serially
            .start_i(fsl_senddata_i),		// start sending trigger
            .serial_o(rs232_tx_data_o),		// serial output line
            .ready_o(rs232_tx_ready)		// serial out !busy
		);

    always @ (posedge clock) begin
		if(reset) begin
			fsl_cts_o       <= 1'b0;
			fsl_data_o      <= 8'h00;
			fsl_rxdata_o    <= 1'b0;
			rs232_cts_o     <= 1'b0;
			rs232_rts       <= 1'b0;
		end
		else begin
			rs232_cts_o <= 1'b1;	// always accept data from outside
			fsl_cts_o <= rs232_tx_ready;
			fsl_data_o <= rs232_rx_data;
			rs232_rts <= rs232_rts_i;	// incoming data?
			fsl_rxdata_o <= fsl_cts_i ? rs232_rx_have_data : fsl_rxdata_o;	// we have data
		end
	end

endmodule

///////////////////////////////////////////////////////////////////////////////

module serial_ctrl_tb ( );

reg  [7:0] fsl_data_i;
reg        fsl_senddata_i;
wire       fsl_cts_o;
wire [7:0] fsl_data_o;
wire       fsl_rxdata_o;
reg        fsl_cts_i;
wire       rs232_tx_data_o;
reg        rs232_rx_data_i;
reg        rs232_rts_i;
wire       rs232_cts_o;
reg        clock, reset;

serial_ctrl serial_ctrl_0(
	.fsl_data_i      (fsl_data_i),
    .fsl_senddata_i  (fsl_senddata_i),
    .fsl_cts_o       (fsl_cts_o),
	.fsl_data_o      (fsl_data_o),
    .fsl_rxdata_o    (fsl_rxdata_o),
    .fsl_cts_i       (fsl_cts_i),
	.rs232_tx_data_o (rs232_tx_data_o),
    .rs232_rx_data_i (rs232_rx_data_i),
    .rs232_rts_i     (rs232_rts_i),
    .rs232_cts_o     (rs232_cts_o),
	.clock           (clock),
    .reset           (reset)
);

initial begin
	clock <= 1'b0;
	reset <= 1'b1;
	fsl_data_i <= 8'h00;
	fsl_senddata_i <= 1'b0;
	fsl_cts_i <= 1'b0;
	rs232_rx_data_i <= 1'b1;
	rs232_rts_i <= 1'b0;

	#1000 reset <= 1'b0;

	#1000 fsl_data_i <= 8'hAB;
	      fsl_senddata_i <= 1'b1;
	#60   fsl_senddata_i <= 1'b0;

	#4166400 rs232_rx_data_i <= 1'b0;	// start bit
	#416640 rs232_rx_data_i <= 1'b1;	
	#416640 rs232_rx_data_i <= 1'b1;	
	#416640 rs232_rx_data_i <= 1'b0;	
	#416640 rs232_rx_data_i <= 1'b1;	
	#416640 rs232_rx_data_i <= 1'b0;	
	#416640 rs232_rx_data_i <= 1'b1;	
	#416640 rs232_rx_data_i <= 1'b0;	
	#416640 rs232_rx_data_i <= 1'b1;	
	#416640 rs232_rx_data_i <= 1'b1;	// stop bit

	// test logic goes here . . .

end


always @ (posedge clock) begin
//	fsl_senddata_i <= 1'b0;
end

always begin
	#20 clock <= ~clock;
end

endmodule

