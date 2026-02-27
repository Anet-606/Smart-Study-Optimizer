`timescale 1ns/1ps

module priority_engine_advanced_tb;

    reg clk;
    reg rst;
    reg start;

    reg [7:0] current1, target1;
    reg [3:0] diff1;

    reg [7:0] current2, target2;
    reg [3:0] diff2;

    reg [7:0] current3, target3;
    reg [3:0] diff3;

    reg [7:0] current4, target4;
    reg [3:0] diff4;

    reg [3:0] fatigue_factor;

    wire done;
    wire [15:0] p1, p2, p3, p4;
    wire [1:0] rank1, rank2, rank3, rank4;
    wire [7:0] cycle_count;

    // Instantiate DUT (Named Mapping – safer)
    priority_engine_advanced uut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .current1(current1), .target1(target1), .diff1(diff1),
        .current2(current2), .target2(target2), .diff2(diff2),
        .current3(current3), .target3(target3), .diff3(diff3),
        .current4(current4), .target4(target4), .diff4(diff4),

        .fatigue_factor(fatigue_factor),

        .done(done),
        .p1(p1), .p2(p2), .p3(p3), .p4(p4),
        .rank1(rank1), .rank2(rank2),
        .rank3(rank3), .rank4(rank4),
        .cycle_count(cycle_count)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Create waveform file
        $dumpfile("waveform.vcd");
        $dumpvars(0, priority_engine_advanced_tb);

        clk = 0;
        rst = 1;
        start = 0;

        #20;
        rst = 0;

        // ================= TEST CASE 1 =================
        current1 = 50; target1 = 90; diff1 = 5;
        current2 = 60; target2 = 85; diff2 = 3;
        current3 = 40; target3 = 95; diff3 = 6;
        current4 = 70; target4 = 88; diff4 = 2;

        fatigue_factor = 1;

        #10;
        start = 1;
        #10;
        start = 0;

        wait(done);
        #10;   // small delay for stability

        $display("---- Test Case 1 ----");
        $display("P1=%d P2=%d P3=%d P4=%d", p1, p2, p3, p4);
        $display("Rank order: %d %d %d %d", rank1, rank2, rank3, rank4);
        $display("Cycle Count=%d", cycle_count);

        #20;

        // ================= TEST CASE 2 =================
        current1 = 80; target1 = 90; diff1 = 4;
        current2 = 30; target2 = 95; diff2 = 7;
        current3 = 50; target3 = 70; diff3 = 3;
        current4 = 60; target4 = 100; diff4 = 5;

        fatigue_factor = 2;

        #10;
        start = 1;
        #10;
        start = 0;

        wait(done);
        #10;

        $display("---- Test Case 2 ----");
        $display("P1=%d P2=%d P3=%d P4=%d", p1, p2, p3, p4);
        $display("Rank order: %d %d %d %d", rank1, rank2, rank3, rank4);
        $display("Cycle Count=%d", cycle_count);

        #50;
        $finish;
    end

endmodule
