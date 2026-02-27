`timescale 1ns/1ps

module priority_engine_advanced(
    input clk,
    input rst,
    input start,

    input [7:0] current1, target1,
    input [3:0] diff1,

    input [7:0] current2, target2,
    input [3:0] diff2,

    input [7:0] current3, target3,
    input [3:0] diff3,

    input [7:0] current4, target4,
    input [3:0] diff4,

    input [3:0] fatigue_factor,

    output reg done,
    output reg [15:0] p1, p2, p3, p4,
    output reg [1:0] rank1, rank2, rank3, rank4,
    output reg [7:0] cycle_count
);

    reg [2:0] state;

    localparam IDLE     = 3'd0,
               GAP      = 3'd1,
               MULTIPLY = 3'd2,
               SHIFT    = 3'd3,
               SORT     = 3'd4,
               DONE     = 3'd5;

    reg [7:0] gap1, gap2, gap3, gap4;
    reg [15:0] weighted1, weighted2, weighted3, weighted4;

    reg [15:0] temp_p [0:3];
    reg [1:0]  temp_id [0:3];

    integer i, j;
    reg [15:0] swap_p;
    reg [1:0]  swap_id;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            cycle_count <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 0;
                    cycle_count <= 0;
                    if (start)
                        state <= GAP;
                end

                GAP: begin
                    gap1 <= (target1 > current1) ? target1 - current1 : 0;
                    gap2 <= (target2 > current2) ? target2 - current2 : 0;
                    gap3 <= (target3 > current3) ? target3 - current3 : 0;
                    gap4 <= (target4 > current4) ? target4 - current4 : 0;
                    state <= MULTIPLY;
                    cycle_count <= cycle_count + 1;
                end

                MULTIPLY: begin
                    weighted1 <= gap1 * diff1;
                    weighted2 <= gap2 * diff2;
                    weighted3 <= gap3 * diff3;
                    weighted4 <= gap4 * diff4;
                    state <= SHIFT;
                    cycle_count <= cycle_count + 1;
                end

                SHIFT: begin
                    p1 <= (weighted1 >> 2) >> fatigue_factor;
                    p2 <= (weighted2 >> 2) >> fatigue_factor;
                    p3 <= (weighted3 >> 2) >> fatigue_factor;
                    p4 <= (weighted4 >> 2) >> fatigue_factor;
                    state <= SORT;
                    cycle_count <= cycle_count + 1;
                end

                SORT: begin
                    // copy values
                    temp_p[0] = p1; temp_id[0] = 2'd0;
                    temp_p[1] = p2; temp_id[1] = 2'd1;
                    temp_p[2] = p3; temp_id[2] = 2'd2;
                    temp_p[3] = p4; temp_id[3] = 2'd3;

                    // bubble sort (descending)
                    for (i = 0; i < 3; i = i + 1) begin
                        for (j = 0; j < 3 - i; j = j + 1) begin
                            if (temp_p[j] < temp_p[j+1]) begin
                                swap_p = temp_p[j];
                                temp_p[j] = temp_p[j+1];
                                temp_p[j+1] = swap_p;

                                swap_id = temp_id[j];
                                temp_id[j] = temp_id[j+1];
                                temp_id[j+1] = swap_id;
                            end
                        end
                    end

                    rank1 <= temp_id[0];
                    rank2 <= temp_id[1];
                    rank3 <= temp_id[2];
                    rank4 <= temp_id[3];

                    state <= DONE;
                    cycle_count <= cycle_count + 1;
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
