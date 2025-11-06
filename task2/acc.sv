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
        idle, read_no_comp, read_and_comp, write_and_comp, done
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
                    next_state = read_no_comp;
                    en = 1;
                    we = 0;
                    address = 0;
                    pixel_counter = 0;
                end

            read_no_comp: begin
                // Read something
                case(pixel_counter)
                    0: begin
                        {next_read_reg[3], next_read_reg[2], next_read_reg[1], next_read_reg[0]} = dataR;
                        pixel_counter = pixel_counter + 1;
                        address = address + 88;
                    end
                    1: begin
                        {next_read_reg[7], next_read_reg[6], next_read_reg[5], next_read_reg[4]} = dataR;
                        pixel_counter = pixel_counter + 1;
                        address = address + 88;
                    end
                    2: begin
                        {next_read_reg[11], next_read_reg[10], next_read_reg[9], next_read_reg[8]} = dataR;
                        pixel_counter = 0;
                        address = address - 175; // 88 * 2 + 1
                    end
                    default: // For now should not happen
                        assert(0);
                endcase
            end
            read_and_comp: begin
                // do something for first three pixels
                case(pixel_counter)
                    0: begin
                        // if edge do nothing

                    end

                    1: begin
                    end

                    2: begin

                    end
                endcase
            end

            write_and_comp: begin
                // comp and then write
                logic [7:0] result = 0;

                dataW = {result, write_reg[2], write_reg[1], write_reg[0]};

            end

            done:
                finish = 1; // True
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
