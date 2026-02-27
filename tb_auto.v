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

priority_engine_advanced uut(
    clk, rst, start,

    current1, target1, diff1,
    current2, target2, diff2,
    current3, target3, diff3,
    current4, target4, diff4,

    fatigue_factor,

    done,

    p1,p2,p3,p4,

    rank1,rank2,rank3,rank4,

    cycle_count
);

always #5 clk = ~clk;

initial begin

    $dumpfile("waveform.vcd");
    $dumpvars(0, priority_engine_advanced_tb);

    clk=0;
    rst=1;
    start=0;

    #20 rst=0;

    current1=15;
    target1=80;
    diff1=4;

    current2=30;
    target2=95;
    diff2=4;

    current3=0;
    target3=75;
    diff3=10;

    current4=50;
    target4=100;
    diff4=3;

    fatigue_factor=7;

    #10 start=1;
    #10 start=0;

    wait(done);

    $display("RESULT %d %d %d %d %d %d %d %d",
             p1,p2,p3,p4,
             rank1,rank2,rank3,rank4);

    #20 $finish;

end

endmodule
