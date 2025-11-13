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

  // ---------------------------------------------------
  // Insert your design here
  // ---------------------------------------------------

    typedef enum logic[3:0]{
        idle, read_no_comp, read_comp, write_comp, done
    } state_t;

  reg [23:0][7:0] read_reg, next_read_reg;
  reg [3:0][7:0] write_reg;
  logic [15:0] address;
  logic [3:0] pixel_counter;
  state_t state, next_state;

    always_comb begin
        next_state = state;
        next_read_reg = read_reg;
        addr = address;

        case(state)
            idle:
                if (start) begin
                    en = 1;
                    we = 0;
                    address = 0;
                    pixel_counter = 0;

                    next_state = read_no_comp;
                end

            read_no_comp: begin
                // Read something
                case(pixel_counter)
                    0: begin
                        {next_read_reg[3], next_read_reg[2], next_read_reg[1], next_read_reg[0]} = dataR;
                        pixel_counter = pixel_counter + 1;
                        address = address + 88;
                        next_state = read_no_comp;
                    end
                    1: begin
                        {next_read_reg[7], next_read_reg[6], next_read_reg[5], next_read_reg[4]} = dataR;
                        pixel_counter = pixel_counter + 1;
                        address = address + 88;
                        next_state = read_no_comp;
                    end
                    2: begin
                        {next_read_reg[11], next_read_reg[10], next_read_reg[9], next_read_reg[8]} = dataR;
                        pixel_counter = 0;
                        address = address - 175; // 88 * 2 + 1

                        
                        next_state = read_comp;
                    end
                    default: // For now should not happen
                        assert(0);
                endcase
            end
            read_comp: begin
                // do something for first three pixels
                case(pixel_counter)
                    0: begin
                        {next_read_reg[15], next_read_reg[14], next_read_reg[13], next_read_reg[12]} = dataR;
                        // if edge do nothing
                        write_reg[0] = 255; // FIXME dummy value
                        

                        address = address + 88; // Have the next adress ready for next read



                    end

                    1: begin
                        {next_read_reg[19], next_read_reg[18], next_read_reg[17], next_read_reg[16]} = dataR;
                        write_reg[1] = 255; // FIXME dummy value
                        

                        address = address + 88; // Have the next adress ready for next read

                    end

                    2: begin
                        {next_read_reg[23], next_read_reg[22], next_read_reg[21], next_read_reg[20]} = dataR;
                        write_reg[2] = 255; // FIXME dummy value
                        


                        address = address + 25344; // Have the next adress ready for next write

                    end
                    default: // For now should not happen
                        assert(0);
                endcase
            end

            write_comp: begin
                // comp and then write
                logic [7:0] result = 255; // FIXME dummy value
                

                dataW = {result, write_reg[2], write_reg[1], write_reg[0]};
                we = 1; // Set write-enable to 1 for a write transaction
                
                if(address >= 50687) begin
                    next_state = read_comp;
                end else begin
                    next_state = done;
                

            end

            done: begin
                // en = 0;
                // we = 0;

                // if(address >= 50687) begin
                //     finish = 1;
                // end else begin
                //     // addr - 25344 + 1 (jump back to the source image, but on next memory line)
                //     address = address - 25343;
                //     next_state = read_comp;
                // end
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
        end
    end;

endmodule
