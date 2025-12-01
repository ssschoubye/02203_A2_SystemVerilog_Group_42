// -----------------------------------------------------------------------------
//
//  Title      :  Edge-Detection design project - task 2.
//             :
//  Developers :  Christian Søtorp - s195041@student.dtu.dk
//             :  Lucas Sjøstrøm   - s224742@student.dtu.dk
//             :  Marilouise Arbøl - s214401@student.dtu.dk
//             :  Søren Schoubye   - s224657@student.dtu.dk
//             :
//  Purpose    :  This design contains an entity for the accelerator that must be build
//             :  in task two of the Edge Detection design project. It contains an
//             :  architecture skeleton for the entity as well.
//             :
//  Revision   :  1.0    Final version
//             :
//
// ----------------------------------------------------------------------------//

//------------------------------------------------------------------------------
// The module for task two. Notice the additional signals for the memory.
// reset is active high.
//------------------------------------------------------------------------------
//

module acc (
    input  logic        clk,        // The clock.
    input  logic        reset,      // The reset signal. Active high.
    output logic [15:0] addr,       // Address bus for data (halfword_t).
    input  logic [31:0] dataR,      // The data bus (word_t).
    output logic [31:0] dataW,      // The data bus (word_t).
    output logic        en,         // Request signal for data.
    output logic        we,         // Read/Write signal for data.
    input  logic        start,
    output logic        finish
);

    logic[7:0] s11, s12, s13, s21, s23, s31, s32, s33, out;
    sobel u_sob(
        .s11(s11),
        .s21(s21),
        .s31(s31),
        .s12(s12),
        .s22(0),
        .s32(s32),
        .s13(s13),
        .s23(s23),
        .s33(s33),
        .out(out)
    );

  // ---------------------------------------------------
  // Insert your design here
  // ---------------------------------------------------

    typedef enum logic[2:0]{
        idle, read_no_comp, read_comp1, read_comp2, write_comp1, write_comp2, border_handler, done
    } state_t;

  reg [24:0][7:0] read_reg, next_read_reg;
  reg [2:0][7:0] write_reg, next_write_reg;
  logic [15:0] write_address_offset, address;
  logic [7:0] result;
  logic [3:0] next_pixel_counter, pixel_counter;
  logic [15:0] next_cycle_counter, cycle_counter;
  logic [6:0] next_cycle_counter_mod_88, cycle_counter_mod_88;
  state_t state, next_state;

    always_comb begin
        // Default assignments for all signals to avoid latches
        write_address_offset = 25344; // 88*288

        // Default assignments to avoid latches
        next_state = state;
        next_read_reg = read_reg;
        next_write_reg = write_reg;
        next_pixel_counter = pixel_counter;
        next_cycle_counter = cycle_counter;
        next_cycle_counter_mod_88 = cycle_counter_mod_88;
        we = 0;
        finish = 0;
        result = 0;

        // no latches variables
        address = 0;
        dataW = 0;

        s11 = 0;
        s12 = 0;
        s13 = 0;
        s21 = 0;
        s23 = 0;
        s31 = 0;
        s32 = 0;
        s33 = 0;
        en = 0;

        case(state)
            idle: begin
                if (start) begin
                    finish = 0;
                    en = 1;
                    next_pixel_counter = 0;
                    next_cycle_counter = 0;
                    next_cycle_counter_mod_88 = 0;
                    next_state = border_handler;
                end
            end

            border_handler: begin
                // Write zeros to borders
                en = 1;
                we = 1;
                dataW = 32'h00000000;
                if(cycle_counter < 88) begin
                    // Top border
                    address = cycle_counter + write_address_offset;
                    next_cycle_counter = cycle_counter + 1;
                    next_cycle_counter_mod_88 = cycle_counter_mod_88 + 1;
                    next_state = border_handler;
                end else if (cycle_counter == 88) begin
                    next_cycle_counter = cycle_counter + 1;
                    // next_cycle_counter_mod_88 = cycle_counter_mod_88 + 1;
                    next_state = read_no_comp;
                end else if (cycle_counter == 25344) begin
                    // determine next state
                    next_state = done;
                end else if (cycle_counter >= 25256) begin
                    // Bottom border
                    address = cycle_counter + write_address_offset;
                    next_cycle_counter = cycle_counter + 1;
                    next_cycle_counter_mod_88 = cycle_counter_mod_88 + 1;
                    next_state = border_handler;
                end

            end

            read_no_comp: begin
                // Avoid latches
                en = 1;
                // Read something
                case(pixel_counter)
                    0: begin
                        {next_read_reg[3], next_read_reg[2], next_read_reg[1], next_read_reg[0]} = dataR;
                        next_pixel_counter = pixel_counter + 1;
                        address = cycle_counter - 1;
                        next_state = read_no_comp;
                    end
                    1: begin
                        {next_read_reg[7], next_read_reg[6], next_read_reg[5], next_read_reg[4]} = dataR;
                        next_pixel_counter = pixel_counter + 1;
                        address = 88 + cycle_counter - 1;
                        next_state = read_no_comp;
                    end
                    2: begin
                        {next_read_reg[11], next_read_reg[10], next_read_reg[9], next_read_reg[8]} = dataR;
                        next_pixel_counter = 0;
                        address = cycle_counter - 88;
                        next_state = read_comp1;
                    end
                endcase
            end
            read_comp1: begin
                en = 1;
                case(pixel_counter)
                    0: begin

                        next_read_reg[15] = read_reg[24] === 8'bxxxxxxxx ? read_reg[15] : read_reg[24];

                        // first cycle special case
                        if (cycle_counter == 89)
                            {next_read_reg[15], next_read_reg[14], next_read_reg[13], next_read_reg[12]} = dataR;

                        // if edge do nothing
                        if(cycle_counter_mod_88 == 0) begin
                            next_write_reg[0] = 8'h0;
                        end else begin
                            s11 = read_reg[15];
                            s12 = read_reg[0];
                            s13 = read_reg[1];
                            s21 = read_reg[19];
                            s23 = read_reg[5];
                            s31 = read_reg[23];
                            s32 = read_reg[8];
                            s33 = read_reg[9];
                            next_write_reg[0] = out;
                        end

                        address = cycle_counter; // Have the next adress ready for next read
                        next_pixel_counter = pixel_counter + 1;
                        next_state = read_comp1;

                    end

                    1: begin
                        {next_read_reg[19], next_read_reg[18], next_read_reg[17], next_read_reg[16]} = dataR;
                        s11 = read_reg[0];
                        s12 = read_reg[1];
                        s13 = read_reg[2];
                        s21 = read_reg[4];
                        s23 = read_reg[6];
                        s31 = read_reg[8];
                        s32 = read_reg[9];
                        s33 = read_reg[10];
                        next_write_reg[1] = out;

                        address = 88 + cycle_counter; // Have the next adress ready for next read
                        next_pixel_counter = pixel_counter + 1;
                        next_state = read_comp1;

                    end

                    2: begin
                        {next_read_reg[23], next_read_reg[22], next_read_reg[21], next_read_reg[20]} = dataR;
                        s11 = read_reg[1];
                        s12 = read_reg[2];
                        s13 = read_reg[3];
                        s21 = read_reg[5];
                        s23 = read_reg[7];
                        s31 = read_reg[9];
                        s32 = read_reg[10];
                        s33 = read_reg[11];
                        next_write_reg[2] = out;

                        address = cycle_counter + 1 - 88; // offset due to next column
                        next_pixel_counter = 0;
                        next_state = write_comp1;
                    end
                endcase
            end

            read_comp2: begin
                en = 1;
                case(pixel_counter)
                    0: begin
                        next_read_reg[3] = read_reg[24] === 8'bxxxxxxxx ? read_reg[3] : read_reg[24];
                        s11 = read_reg[3];
                        s12 = read_reg[12];
                        s13 = read_reg[13];
                        s21 = read_reg[7];
                        s23 = read_reg[17];
                        s31 = read_reg[11];
                        s32 = read_reg[20];
                        s33 = read_reg[21];
                        next_write_reg[0] = out;

                        address = cycle_counter; // Have the next adress ready for next read
                        next_pixel_counter = pixel_counter + 1;
                        next_state = read_comp2;

                    end

                    1: begin
                        {next_read_reg[7], next_read_reg[6], next_read_reg[5], next_read_reg[4]} = dataR;
                        s11 = read_reg[12];
                        s12 = read_reg[13];
                        s13 = read_reg[14];
                        s21 = read_reg[16];
                        s23 = read_reg[18];
                        s31 = read_reg[20];
                        s32 = read_reg[21];
                        s33 = read_reg[22];
                        next_write_reg[1] = out;

                        address = 88 + cycle_counter; // Have the next adress ready for next read
                        next_pixel_counter = pixel_counter + 1;
                        next_state = read_comp2;

                    end

                    2: begin
                        {next_read_reg[11], next_read_reg[10], next_read_reg[9], next_read_reg[8]} = dataR;
                        s11 = read_reg[13];
                        s12 = read_reg[14];
                        s13 = read_reg[15];
                        s21 = read_reg[17];
                        s23 = read_reg[19];
                        s31 = read_reg[21];
                        s32 = read_reg[22];
                        s33 = read_reg[23];
                        next_write_reg[2] = out;

                        address = cycle_counter + 1 - 88; // Have the next adress ready for next write
                        next_pixel_counter = 0;
                        next_state = write_comp2;
                    end
                    //default: // For now should not happen
                        //assert(0);
                endcase
            end

            write_comp1: begin
                // comp and then write
                s11 = read_reg[2];
                s12 = read_reg[3];
                s13 = read_reg[12];
                s21 = read_reg[6];
                s23 = read_reg[16];
                s31 = read_reg[10];
                s32 = read_reg[11];
                s33 = read_reg[20];
                result = out;
                address = cycle_counter + write_address_offset - 1;
                // read input from dataR
                {next_read_reg[24], next_read_reg[2], next_read_reg[1], next_read_reg[0]} = dataR;

                en = 1;
                we = 1; // Set write-enable to 1 for a write transaction
                dataW = {result, write_reg[2], write_reg[1], write_reg[0]};
                next_cycle_counter = cycle_counter + 1;
                next_cycle_counter_mod_88 = cycle_counter_mod_88 + 1;
                next_state = read_comp2;

            end
            write_comp2: begin
                // comp and then write
                if(cycle_counter_mod_88 == 87) begin
                    result = 8'h0; // FIXME
                end else begin
                    s11 = read_reg[14];
                    s12 = read_reg[15];
                    s13 = read_reg[0];
                    s21 = read_reg[18];
                    s23 = read_reg[4];
                    s31 = read_reg[22];
                    s32 = read_reg[23];
                    s33 = read_reg[8];
                    result = out;
                end

                en = 1;
                we = 1; // Set write-enable to 1 for a write transaction
                dataW = {result, write_reg[2], write_reg[1], write_reg[0]};

                address = cycle_counter + write_address_offset - 1;
                {next_read_reg[24], next_read_reg[14], next_read_reg[13], next_read_reg[12]} = dataR;

                if((cycle_counter) < 25256) begin // 25344 - 88
                    next_state = read_comp1;
                    next_cycle_counter_mod_88 = cycle_counter_mod_88 + 1;
                    next_cycle_counter = cycle_counter + 1;
                end else
                    next_state = border_handler;

            end

            done: begin
                finish = 1; // True
                address = 0;
            end
        endcase
        addr = address;
    end;

    always_ff @(posedge clk or posedge reset) begin
        if(reset)
            state <= idle;
        else begin
            state <= next_state;
            read_reg <= next_read_reg;
            write_reg <= next_write_reg;
            pixel_counter <= next_pixel_counter;
            cycle_counter <= next_cycle_counter;
            cycle_counter_mod_88 <= (next_cycle_counter_mod_88 < 88) ? next_cycle_counter_mod_88 : 0;
        end
    end;

endmodule
