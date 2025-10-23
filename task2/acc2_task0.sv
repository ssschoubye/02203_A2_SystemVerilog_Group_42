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

typedef enum logic[2:0]{
    idle, req_data, read, compute, write, done
} state_t;

byte unsigned reg_a, reg_b, reg_c, reg_d, next_reg_a, next_reg_b, next_reg_c, next_reg_d;

state_t state, next_state;

always_comb begin
    next_state = state;
    next_reg_a = reg_a;
    next_reg_b = reg_b;
    next_reg_c = reg_c;
    next_reg_d = reg_d;
    
    case(state)
        idle: begin
            finish = 0;
            next_reg_a = 0;
            next_reg_b = 0;
            next_reg_c = 0;
            next_reg_d = 0;
            
            if(start) next_state = req_data;
        end
        
        req_data: begin
            en = 1;
            we = 0;
            addr = 0; // FIXME:
            
            next_state = read;            
        end
        
        read: begin
            next_reg_a = dataR[7:0];
            next_reg_b = dataR[15:8];
            next_reg_c = dataR[23:16];
            next_reg_d = dataR[31:24];
            
            en = 0;
            next_state = compute;
        end
        
        compute: begin
            next_reg_a = 255 - reg_a;
            next_reg_b = 255 - reg_b;
            next_reg_c = 255 - reg_c;
            next_reg_d = 255 - reg_d;
        
            next_state = write;
        end
        write: begin
            en = 1;
            we = 1;
            addr = 25344;
            
            dataW = {reg_d, reg_c, reg_b, reg_a};
            next_state = done;
        end
        done: begin
            en = 0;
            we = 0; 
            finish = 1;
        end  
    endcase
end

always_ff @(posedge clk or posedge reset) begin
    if(reset)
        state <= idle;
    else begin
        state <= next_state;
        reg_a <= next_reg_a;
        reg_b <= next_reg_b;
        reg_c <= next_reg_c;
        reg_d <= next_reg_d;
    end
    
end

endmodule
