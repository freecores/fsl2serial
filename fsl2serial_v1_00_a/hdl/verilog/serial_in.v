// Todd Fleming 2005

`timescale 1 ns / 100 ps

module serial_in(
    clk, 
    rst, 
    serial_i, 
    data_o, 
    have_data_o, 
    frame_error_o, 
    serial_samping_o);
    
    input clk, rst, serial_i;
    output[7:0] data_o;
    output have_data_o, frame_error_o, serial_samping_o;

    parameter clk_freq = 100000000;
    parameter data_rate = 115200;
    parameter bit_length = clk_freq / data_rate;
    parameter delay_size = 12;  // Must be large enough to store bit_length
    parameter use_parity = 0;
    parameter parity_is_odd = 1;
    
    reg[7:0] data_o;
    reg parity;
    reg have_data_o, frame_error_o, serial_samping_o;
    reg temp, buffered_serial;
    reg[2:0] state;
    reg[delay_size-1:0] delay;
    reg[3:0] bits_received;
    
    parameter state_wait_for_start = 3'd0;
    parameter state_wait_for_bit = 3'd1;
    parameter state_wait_for_stop = 3'd2;
    parameter state_wait_for_parity = 3'd3;
    parameter state_frame_error = 3'd4;
    
    always @(posedge clk) begin
        temp <= serial_i;
        buffered_serial <= temp;
        serial_samping_o <= 1'd0;
        
        if(rst) begin
            data_o <= 8'd0;
            have_data_o <= 1'd0;
            frame_error_o <= 1'd0;
            state <= state_wait_for_start;
        end else begin
            case(state)
                state_wait_for_start: begin
                    have_data_o <= 1'b0;
                    frame_error_o <= 1'b0;
                    if(!buffered_serial) begin
                        serial_samping_o <= 1'd1;
                        state <= state_wait_for_bit;
                        delay <= bit_length + bit_length / 2;
                        bits_received <= 0;
                    end
                end
                
                state_wait_for_bit: begin
                    if(delay == 1) begin
                        serial_samping_o <= 1'd1;
                        data_o <= {buffered_serial, data_o[7:1]};
                        delay <= bit_length;
                        bits_received <= bits_received + 1;
                        if(bits_received == 7)
                            if(use_parity)
                                state <= state_wait_for_parity;
                            else
                                state <= state_wait_for_stop;
                    end else
                        delay <= delay - 1;
                end
                
                state_wait_for_parity: begin
                    if(delay == 1) begin
                        serial_samping_o <= 1'd1;
                        parity <= buffered_serial;
                        delay <= bit_length;
                        state <= state_wait_for_stop;
                    end else
                        delay <= delay - 1;
                end
                
                state_wait_for_stop: begin
                    if(delay == 1) begin
                        serial_samping_o <= 1'd1;
                        if(buffered_serial) begin
                            if(!use_parity || ((^data_o) ^ parity) == parity_is_odd)
                                have_data_o <= 1'b1;
                            frame_error_o <= 1'b0;
                            state <= state_wait_for_start;
                        end else begin
                            have_data_o <= 1'b0;
                            frame_error_o <= 1'b1;
                            state <= state_frame_error;
                        end
                    end else
                        delay <= delay - 1;
                end
                
                state_frame_error: begin
                    if(buffered_serial)
                        state <= state_wait_for_start;
                end
            endcase
        end
    end
endmodule // serial_in
