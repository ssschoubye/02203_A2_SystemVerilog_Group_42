// -----------------------------------------------------------------------------
//
//  Title      :  Edge-Detection design project - task 2.
//             :
//  Developers :  YOUR NAME HERE - s??????@student.dtu.dk
//             :  YOUR NAME HERE - s??????@student.dtu.dk
//             :
//  Purpose    :  This design contains an entity for the accelerator that must be build
//             :  in task two of the Edge Detection design project. It contains an
//             :  architecture skeleton for the entity as well.
//             :
//  Revision   :  1.0   ??-??-??     Final version
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

    typedef enum logic[3:0]{
        idle, read_no_comp, read_comp1, read_comp2, write_comp1, write_comp2, done
    } state_t;

  reg [23:0][7:0] read_reg, next_read_reg;
  reg [3:0][7:0] write_reg;
  logic [15:0] read_address, write_address_offset, address;
  logic [7:0] result;
  logic [3:0] next_pixel_counter, pixel_counter;
  state_t state, next_state;

    always_comb begin
        next_state = state;
        next_read_reg = read_reg;
        next_pixel_counter = pixel_counter;
        we = 0; // ALWAYS set write enable to false
        //addr = address;

        case(state)
            idle: begin
                if (start) begin
                    finish = 0;
                    en = 1;
                    we = 0;
                    addr = 0;
                    address = 0;
                    read_address = 0;
                    write_address_offset = 25344; // FIXME:
                    next_pixel_counter = 0;
                    result = 0;

                    next_state = read_no_comp;
                end
            end

            read_no_comp: begin
                // Read something
                case(pixel_counter)
                    0: begin
                        {next_read_reg[3], next_read_reg[2], next_read_reg[1], next_read_reg[0]} = dataR;
                        next_pixel_counter = pixel_counter + 1;
                        read_address = read_address + 88;
                        next_state = read_no_comp;
                    end
                    1: begin
                        {next_read_reg[7], next_read_reg[6], next_read_reg[5], next_read_reg[4]} = dataR;
                        next_pixel_counter = pixel_counter + 1;
                        read_address = read_address + 88;
                        next_state = read_no_comp;
                    end
                    2: begin
                        {next_read_reg[11], next_read_reg[10], next_read_reg[9], next_read_reg[8]} = dataR;
                        next_pixel_counter = 0;
                        read_address = read_address - 175; // 88 * 2 + 1

                        next_state = read_comp1;
                    end
                    //default: // For now should not happen
                        // assert(0);
                endcase
                    address = read_address;
            end
            read_comp1: begin
                we = 0;
                case(pixel_counter)
                    0: begin
                        {next_read_reg[15], next_read_reg[14], next_read_reg[13], next_read_reg[12]} = dataR;
                        // if edge do nothing
                        if((read_address-1) % 88 == 0) begin
                            write_reg[0] = 00; // FIXME
                        end else begin
                            s11 = read_reg[15];
                            s12 = read_reg[0];
                            s13 = read_reg[1];
                            s21 = read_reg[19];
                            s23 = read_reg[5];
                            s31 = read_reg[23];
                            s32 = read_reg[8];
                            s33 = read_reg[9];
                            write_reg[0] = out;
                        end

                        read_address = read_address + 88; // Have the next adress ready for next read
                        address = read_address;
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
                        write_reg[1] = out;

                        read_address = read_address + 88; // Have the next adress ready for next read
                        address = read_address;
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
                        write_reg[2] = out;

                        address = write_address_offset + read_address;
                        next_pixel_counter = 0;
                        next_state = write_comp1;
                    end
                    //default: // For now should not happen
                        //assert(0);
                endcase
            end

            read_comp2: begin
                we = 0;
                case(pixel_counter)
                    0: begin
                        {next_read_reg[3], next_read_reg[2], next_read_reg[1], next_read_reg[0]} = dataR;
                        s11 = read_reg[3];
                        s12 = read_reg[12];
                        s13 = read_reg[13];
                        s21 = read_reg[7];
                        s23 = read_reg[17];
                        s31 = read_reg[11];
                        s32 = read_reg[20];
                        s33 = read_reg[21];
                        write_reg[0] = out;

                        read_address = read_address + 88; // Have the next adress ready for next read
                        address = read_address;
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
                        write_reg[1] = out;

                        read_address = read_address + 88; // Have the next adress ready for next read
                        address = read_address;
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
                        write_reg[2] = out;

                        address = read_address + write_address_offset; // Have the next adress ready for next write
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
                s31 = read_reg[19];
                s32 = read_reg[11];
                s33 = read_reg[20];
                result = out;

                we = 1; // Set write-enable to 1 for a write transaction
                dataW = {result, write_reg[2], write_reg[1], write_reg[0]};

                if(read_address < 25344) begin
                    next_state = read_comp2;
                end else begin
                    next_state = done;
                end

            end
            write_comp2: begin
                // comp and then write
                if((read_address + 1) % 88 == 0) begin
                    result = 00;
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

                we = 1; // Set write-enable to 1 for a write transaction
                dataW = {result, write_reg[2], write_reg[1], write_reg[0]};

                if(read_address < 25344) begin
                    next_state = read_comp1;
                end else begin
                    next_state = done;
                end

            end

            done: begin
                en = 0;
                finish = 1; // True
            end
        endcase
    end;

    always_ff @(posedge clk or posedge reset) begin
        if(reset)
            state <= idle;
        else begin
            state <= next_state;
            read_reg <= next_read_reg;
            addr <= address;
            pixel_counter <= next_pixel_counter;
        end
    end;

endmodule
