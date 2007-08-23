// This top level module ties together the FSL control and Serial control
// modules to make an active, two way serial to FSL / FSL to serial bridge.
//
// Alex Marschner
// 2007.02.20

`timescale 1 ns / 100 ps

module fsl2serial( clock, reset, 		// clock and reset
		rs232_tx_data_o, 	//
		rs232_rx_data_i, 
		rs232_rts_i, 
		rs232_cts_o,

		FSL_S_CLK, FSL_S_DATA, FSL_S_CONTROL, FSL_S_EXISTS, FSL_S_READ,
		FSL_M_CLK, FSL_M_DATA, FSL_M_CONTROL, FSL_M_FULL,   FSL_M_WRITE
);

	parameter EXT_RESET_ACTIVE_HI = 0;
	parameter CLOCK_FREQ_MHZ = 50;
	parameter BAUD_RATE = 115200;

    input  wire        clock, reset;
    output wire        rs232_tx_data_o;
    input  wire        rs232_rx_data_i;
    input  wire        rs232_rts_i;
    output wire        rs232_cts_o;

	input  wire [0:31] FSL_S_DATA;
	input  wire        FSL_S_CONTROL;
	input  wire        FSL_S_EXISTS;
	input  wire        FSL_M_FULL;

	output wire [0:31] FSL_M_DATA;
	output wire        FSL_M_CONTROL;
	output wire        FSL_M_WRITE;
	output wire        FSL_S_READ;

	output wire        FSL_M_CLK;
	output wire        FSL_S_CLK;

    wire               ser2fsl_cts, fsl2ser_cts;
    wire               fsl2ser_start, ser2fsl_dataexists;
    wire         [7:0] ser2fsl_data;
    wire         [7:0] fsl2ser_data;
	
	wire              reset_correct_polarity;

	assign reset_correct_polarity = EXT_RESET_ACTIVE_HI ? reset : ~reset;

	assign FSL_M_DATA[0:23] = 24'b0; // only use last byte since we are dealing with serial characters	

fsl_ctrl fsl_ctrl0(
	.FSL_S_CLK       (FSL_S_CLK),
    .FSL_S_DATA      (FSL_S_DATA[24:31]),
    .FSL_S_CONTROL   (FSL_S_CONTROL),
    .FSL_S_EXISTS    (FSL_S_EXISTS),
    .FSL_S_READ      (FSL_S_READ),
	.FSL_M_CLK       (FSL_M_CLK),
    .FSL_M_DATA      (FSL_M_DATA[24:31]),
    .FSL_M_CONTROL   (FSL_M_CONTROL),
    .FSL_M_FULL      (FSL_M_FULL),
    .FSL_M_WRITE     (FSL_M_WRITE),
	.rs232_tx_ready  (ser2fsl_cts),
    .rs232_tx_data   (fsl2ser_data),
    .rs232_tx_start  (fsl2ser_start),
	.rs232_rx_ready  (fsl2ser_cts),
    .rs232_rx_data   (ser2fsl_data),
    .rs232_rx_exists (ser2fsl_dataexists),
	.clock           (clock),
    .reset           (reset_correct_polarity)
);

serial_ctrl #(
	.CLOCK_FREQ_MHZ(CLOCK_FREQ_MHZ),
	.BAUD_RATE(BAUD_RATE)
    ) serial_ctrl0 (
	.fsl_data_i      (fsl2ser_data),
    .fsl_senddata_i  (fsl2ser_start),
    .fsl_cts_o       (ser2fsl_cts),
	.fsl_data_o      (ser2fsl_data),
    .fsl_rxdata_o    (ser2fsl_dataexists),
    .fsl_cts_i       (fsl2ser_cts),
	.rs232_tx_data_o (rs232_tx_data_o),
    .rs232_rx_data_i (rs232_rx_data_i),
    .rs232_rts_i     (rs232_rts_i),
    .rs232_cts_o     (rs232_cts_o),
	.clock           (clock),
    .reset           (reset_correct_polarity)
);

/*
  //-----------------------------------------------------------------
  //
  //  ICON/ILA core wire declarations
  //
  //-----------------------------------------------------------------
  wire [35:0] control0;
  wire [31:0] trig0;

	assign trig0 = {FSL_S_DATA[24:31],FSL_S_READ,FSL_S_EXISTS,
		            fsl2ser_data,fsl2ser_start,ser2fsl_cts,
                    rs232_tx_data_o, rs232_cts_o, reset_correct_polarity, 9'b0};

  //-----------------------------------------------------------------
  //
  //  ICON core instance
  //
  //-----------------------------------------------------------------
  icon i_icon
    (
      .control0(control0)
    );

  //-----------------------------------------------------------------
  //
  //  ILA core instance
  //
  //-----------------------------------------------------------------
  ila i_ila
    (
      .control(control0),
      .clk(clock),
      .trig0(trig0)
    );

endmodule


//-------------------------------------------------------------------
//
//  ICON core module declaration
//
//-------------------------------------------------------------------
module icon 
  (
      control0
  );
  output [35:0] control0;
endmodule

//-------------------------------------------------------------------
//
//  ILA core module declaration
//
//-------------------------------------------------------------------
module ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [31:0] trig0;*/
endmodule

///////////////////////////////////////////////////////////////////////////////

// TBD:
// [x] test the FSL 2 Serial direction
// [ ] test the Serial 2 FSL direction

module fsl2serial_tb ( );

reg  clock, reset_n;
wire rs232_tx_data_o;
reg  rs232_rx_data_i;
reg  rs232_rts_i;
wire rs232_cts_o;

reg  [0:31] FSL_S_DATA;
reg         FSL_S_CONTROL;
wire [0:31] FSL_M_DATA;
wire        FSL_M_CONTROL;
wire        FSL_S_CLK, FSL_M_CLK;
wire        FSL_M_WRITE, FSL_S_READ;
reg         FSL_M_FULL, FSL_S_EXISTS;

initial begin
	clock <= 1'b0;
	reset_n <= 1'b0;
	rs232_rx_data_i <= 1'b1;
	rs232_rts_i <= 1'b0;
	FSL_S_DATA <= 32'h00000000;
	FSL_S_CONTROL <= 1'b0;
	FSL_M_FULL <= 1'b0;
	FSL_S_EXISTS <= 1'b0;

	#1000 reset_n <= 1'b1;
	
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
	
	#2070750 rs232_rx_data_i <= 1'b0;	// start bit
	#207075 rs232_rx_data_i <= 1'b1;	
	#207075 rs232_rx_data_i <= 1'b1;	
	#207075 rs232_rx_data_i <= 1'b0;	
	#207075 rs232_rx_data_i <= 1'b1;	
	#207075 rs232_rx_data_i <= 1'b0;	
	#207075 rs232_rx_data_i <= 1'b1;	
	#207075 rs232_rx_data_i <= 1'b0;	
	#207075 rs232_rx_data_i <= 1'b1;	
	#207075 rs232_rx_data_i <= 1'b1;	// stop bit

	

end

always begin
	#10 clock <= ~clock;	// 50MHz
end

fsl2serial bridge( 
    .clock           (clock),
    .reset           (reset_n),
    .rs232_tx_data_o (rs232_tx_data_o),
    .rs232_rx_data_i (rs232_rx_data_i),
    .rs232_rts_i     (rs232_rts_i),
    .rs232_cts_o     (rs232_cts_o),
    .FSL_S_CLK       (FSL_S_CLK),
    .FSL_S_DATA      (FSL_S_DATA),
    .FSL_S_CONTROL   (FSL_S_CONTROL),
    .FSL_S_EXISTS    (FSL_S_EXISTS),
    .FSL_S_READ      (FSL_S_READ),
    .FSL_M_CLK       (FSL_M_CLK),
    .FSL_M_DATA      (FSL_M_DATA),
    .FSL_M_CONTROL   (FSL_M_CONTROL),
    .FSL_M_FULL      (FSL_M_FULL),
    .FSL_M_WRITE     (FSL_M_WRITE)
);

endmodule 

