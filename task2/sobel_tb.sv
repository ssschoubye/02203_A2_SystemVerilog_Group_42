`timescale 1ns / 1ps

module sobel_tb;

    // Inputs
    logic [7:0] s11, s21, s31, s12, s22, s32, s13, s23, s33;
    // Output
    logic [7:0] out;

    // Instantiate the sobel module
    sobel uut (
        .s11(s11), .s21(s21), .s31(s31),
        .s12(s12), .s22(s22), .s32(s32),
        .s13(s13), .s23(s23), .s33(s33),
        .out(out)
    );

    // Task to apply a test vector and display result
    task run_test(
        input [7:0] t_s11, t_s21, t_s31, t_s12, t_s22, t_s32, t_s13, t_s23, t_s33
    );
        begin
            s11 = t_s11; s21 = t_s21; s31 = t_s31;
            s12 = t_s12; s22 = t_s22; s32 = t_s32;
            s13 = t_s13; s23 = t_s23; s33 = t_s33;
            #1; // Wait for combinational logic to settle
            $display("Inputs: %d %d %d | %d %d %d | %d %d %d => Output: %d",
                s11, s12, s13,
                s21, s22, s23,
                s31, s32, s33,
                out
            );
        end
    endtask

    initial begin
        $display("Starting Sobel Testbench...");

        // Test 1: All zeros
        run_test(0,0,0,0,0,0,0,0,0);

        // Test 2: All max
        run_test(8'd255,8'd255,8'd255,8'd255,8'd255,8'd255,8'd255,8'd255,8'd255);

        // Test 3: Horizontal edge
        run_test(0,0,0,255,255,255,0,0,0);

        // Test 4: Vertical edge
        run_test(0,255,0,0,255,0,0,255,0);

        // Test 5: Diagonal edge
        run_test(255,0,0,0,255,0,0,0,255);

        // Test 6: Random values
        run_test(10,20,30,40,50,60,70,80,90);

        $display("Testbench completed.");
        $finish;
    end

endmodule
