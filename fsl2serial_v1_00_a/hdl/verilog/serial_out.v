// Todd Fleming 2005

`timescale 1 ns / 100 ps

module serial_out(
    clk, 
    rst, 
    data_size_i,
    data_i,
    start_i,
    serial_o,
    ready_o,
    bit_sync_o);
    
    parameter clk_freq = 100000000;
    parameter data_rate = 115200;
    parameter bit_length = clk_freq / data_rate;
    parameter delay_size = 32;  // Must be large enough to store bit_length
    parameter max_data_size = 8;
    parameter data_size_size = 4; // Must be large enough to store max_data_size
    parameter use_start = 1;
    parameter use_stop = 1;
    parameter use_parity = 0;
    parameter stop_value = 1;
    parameter parity_is_odd = 1;
    
    input clk, rst;
    input[data_size_size-1:0] data_size_i;
    input[max_data_size-1:0] data_i;
    input start_i;
    output serial_o;
    output ready_o;
    output bit_sync_o;
    
    reg[2:0] state;
    reg[data_size_size-1:0] data_size;
    reg[max_data_size-1:0] data;
    reg[delay_size-1:0] delay;
    reg[max_data_size-1:0] num_sent;
    reg serial_o;
    reg bit_sync_o;
    
    parameter state_wait_for_start = 3'd0;
    parameter state_send_start = 3'd1;
    parameter state_send_bit = 3'd2;
    parameter state_send_parity = 3'd3;
    parameter state_send_stop = 3'd4;
    
    assign ready_o = 
        (state == state_wait_for_start || state == state_send_stop && delay == 1) && !start_i;
    
    always @(posedge clk) begin
        bit_sync_o <= 0;
    
        if(rst) begin
            state <= state_wait_for_start;
        end else begin
            delay <= delay - 1;
            
            case(state)
                state_wait_for_start: begin
                    serial_o <= stop_value;
                    if(start_i) begin
                        data_size <= data_size_i;
                        data <= data_i;
                        num_sent <= 0;
                        if(use_start) begin
                            serial_o <= ~stop_value;
                            delay <= bit_length - 1;
                            state <= state_send_start;
                        end else begin
                            serial_o <= data_i[0];
                            delay <= bit_length - 1;
                            state <= state_send_bit;
                        end
                    end
                end
                state_send_start: begin
                    serial_o <= ~stop_value;
                    if(delay == 1) begin
                        delay <= bit_length;
                        state <= state_send_bit;
                    end
                end
                state_send_bit: begin
                    serial_o <= data[0];
                    if(delay == bit_length - 2)
                        bit_sync_o <= 1;
                    if(delay == 1) begin
                        delay <= bit_length;
                        data <= data >> 1;
                        num_sent <= num_sent + 1;
                        if(num_sent == data_size - 1)
                            if(use_parity)
                                state <= state_send_parity;
                            else if(use_stop)
                                state <= state_send_stop;
                            else
                                state <= state_wait_for_start;
                    end
                end
                state_send_parity: begin
                    serial_o <= (^data[0]) ^ parity_is_odd;
                    if(delay == 1) begin
                        delay <= bit_length;
                        state <= state_send_stop;
                    end
                end
                state_send_stop: begin
                    serial_o <= stop_value;
                    if(delay == 1) begin
                        delay <= bit_length;
                        state <= state_wait_for_start;
                    end
                end
            endcase
        end
    end
endmodule // serial_out

///////////////////////////////////////////////////////////////////////////////

module serial_out_tb ( );

reg clock, reset;
reg [7:0] fsl_data_i;
reg       fsl_senddata_i;
wire      rs232_tx_data_o;
wire      rs232_tx_ready;

initial begin
	clock <= 1'b0;
	reset <= 1'b1;
	fsl_data_i <= 8'h00;
	fsl_senddata_i <= 1'b0;

	#1000 reset <= 1'b0;
	#1000 fsl_data_i <= 8'h0A;
	      fsl_senddata_i <= 1'b1;
    #60   fsl_senddata_i <= 1'b0;
end

always begin
	#10 clock <= ~clock;
end

// Serial Out Module
    serial_out
    #(
        .clk_freq(50000000),
        .data_rate(115200))
    serial_out0(
        .clk(clock), 
        .rst(reset), 
        .data_size_i(8),
        .data_i(fsl_data_i),			// data to send out serially
        .start_i(fsl_senddata_i),		// start sending trigger
        .serial_o(rs232_tx_data_o),		// serial output line
        .ready_o(rs232_tx_ready)		// serial out !busy
	);

endmodule
