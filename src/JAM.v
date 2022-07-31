//==================================
//Project: IC Design Contest_2022
//Designer: William
//Date: 2022/07/26
//Version: 2.0
//==================================
module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

// FSM
reg [1:0] state;
reg [1:0] n_state;
parameter IDLE     = 2'b00;
parameter REPLACE  = 2'b01;
parameter EXCHANGE = 2'b10;
parameter READ     = 2'b11;
//
reg [2:0] worker_cnt;
reg [2:0] job_cnt;
reg [2:0] job_reg [0:7];
reg [2:0] replace_position;
reg [2:0] replace_value;
//
reg [2:0] exchange_position;
reg [2:0] exchange_value;
reg exchange_flag;
//
reg [2:0] read_cnt;
reg [6:0] cost_table [0:7];
reg job_flag;
reg [2:0] read_addr;
//
reg [9:0] cost_sum;

integer i; 

// FSM current state
always @(posedge CLK or posedge RST) begin
	if (RST) begin
	    state <= 2'd0;
	end
	else begin
		state <= n_state;
	end
end

// FSM next state
always @(*) begin
	case(state)
         IDLE: begin
         	n_state = REPLACE;
         end
         REPLACE: begin
         	if(job_reg[job_cnt] < job_reg[job_cnt + 1]) n_state = EXCHANGE;
         	else n_state = state;
         end
         EXCHANGE: begin
         	if(exchange_flag && job_flag) n_state = READ;
         	else n_state = state;
         end
         READ: begin
            if(job_cnt == 3'd7) n_state = REPLACE;
            else n_state = state;
         end
         default: begin
         	n_state = state;
         end
	endcase
end

// Worker counter
always @(posedge CLK or posedge RST) begin
	if (RST) begin
	    worker_cnt <= 3'd0;
	end
	else begin
		case(state)
             IDLE: begin
             	worker_cnt <= 3'd0;
             end
             /*REPLACE: begin
             	if(worker_cnt == 3'd7) worker_cnt <= 3'd0;
             	else worker_cnt <= worker_cnt + 3'd1;
             end*/
             EXCHANGE: begin
                worker_cnt <= replace_position;
             end 
             READ: begin
                if(worker_cnt == 3'd7) worker_cnt <= 3'd0;
                else worker_cnt <= worker_cnt + 3'd1;
             end
             default: begin
             	worker_cnt <= worker_cnt;
             end
		endcase
	end
end

// Job counter
always @(posedge CLK or posedge RST) begin
	if (RST) begin
	    job_cnt <= 3'd6;
	end
	else begin
		case(state)
             IDLE: begin
             	job_cnt <= 3'd6;
             end
             REPLACE: begin
             	if(job_reg[job_cnt] < job_reg[job_cnt + 1]) job_cnt <= 3'd7;
             	else job_cnt <= job_cnt - 3'd1;
             end
             EXCHANGE: begin
             	if(job_cnt == replace_position) job_cnt <= job_cnt;
             	else job_cnt <= job_cnt - 3'd1;
             end
             READ: begin
                if(job_cnt == 3'd7) job_cnt <= 3'd6;
                else job_cnt <= job_cnt + 3'd1;
             end
             default: begin
             	job_cnt <= job_cnt;
             end
		endcase
	end
end

// Permutation
always @(posedge CLK or posedge RST) begin
	if (RST) begin
	    job_reg[0] <= 3'd0;
        job_reg[1] <= 3'd1;
        job_reg[2] <= 3'd2;
        job_reg[3] <= 3'd3;
        job_reg[4] <= 3'd4;
        job_reg[5] <= 3'd5;
        job_reg[6] <= 3'd6;
        job_reg[7] <= 3'd7;
	end
	else begin
		case(state)
             EXCHANGE: begin
                if(job_cnt == replace_position && !exchange_flag) begin
                	job_reg[replace_position] <= job_reg[exchange_position];
                	job_reg[exchange_position] <= job_reg[replace_position];
                end
             	else if(exchange_flag) begin
             		case(replace_position)
                         0: begin
                         	job_reg[1] <= job_reg[7];
                         	job_reg[7] <= job_reg[1];
                         	job_reg[2] <= job_reg[6];
                         	job_reg[6] <= job_reg[2];
                         	job_reg[3] <= job_reg[5];
                         	job_reg[5] <= job_reg[3];
                         end
                         1: begin
                         	job_reg[2] <= job_reg[7];
                         	job_reg[7] <= job_reg[2];
                         	job_reg[3] <= job_reg[6];
                         	job_reg[6] <= job_reg[3];
                         	job_reg[4] <= job_reg[5];
                         	job_reg[5] <= job_reg[4];
                         end
                         2: begin
                         	job_reg[3] <= job_reg[7];
                         	job_reg[7] <= job_reg[3];
                         	job_reg[4] <= job_reg[6];
                         	job_reg[6] <= job_reg[4];
                         end
                         3: begin
                         	job_reg[7] <= job_reg[4];
                         	job_reg[4] <= job_reg[7];
                         	job_reg[5] <= job_reg[6];
                         	job_reg[6] <= job_reg[5];
                         end
                         4: begin
                         	job_reg[5] <= job_reg[7];
                         	job_reg[7] <= job_reg[5];
                         end
                         5: begin
                         	job_reg[6] <= job_reg[7];
                         	job_reg[7] <= job_reg[6];
                         end
                         default: begin
                         	for(i = 0; i < 8; i = i + 1) begin
                         		job_reg[i] <= job_reg[i];
                         	end
                         end
             		endcase
             	end
                else begin
                    for(i = 0; i < 8; i = i + 1) begin
                        job_reg[i] <= job_reg[i];
                    end
                end
             end
             default: begin
             	for(i = 0; i < 8; i = i + 1) begin
             		job_reg[i] <= job_reg[i];
             	end
             end
		endcase
	end
end

// Replace position
always @(posedge CLK or posedge RST) begin
	if (RST) begin
	    replace_position <= 3'd0;
	end
	else begin
		case(state)
             REPLACE: begin
             	if(job_reg[job_cnt] < job_reg[job_cnt + 1]) replace_position <= job_cnt;
             	else replace_position <= replace_position;
             end
             default: begin
             	replace_position <= replace_position;
             end
		endcase
	end
end

// Replace value
always @(posedge CLK or posedge RST) begin
	if (RST) begin
	    replace_value <= 3'd0;
	end
	else begin
		case(state)
             REPLACE: begin
             	if(job_reg[job_cnt] < job_reg[job_cnt + 1]) replace_value <= job_reg[job_cnt];
             	else replace_value <= replace_value;
             end
             /*READ: begin
                replace_value <= 3'd0;
             end*/
             default: begin
             	replace_value <= replace_value;
             end
		endcase
	end
end

// Exchange position
always @(posedge CLK or posedge RST) begin
	if (RST) begin
		exchange_position <= 3'd0;
	end
	else begin
		case(state)
             REPLACE: begin
                exchange_position <= 3'd7;
             end
             EXCHANGE: begin
                if((job_reg[job_cnt] > replace_value) && (job_reg[job_cnt] <= exchange_value)) exchange_position <= job_cnt;
             	else exchange_position <= exchange_position; 
             end
             default: begin
             	exchange_position <= exchange_position;
             end
		endcase
	end
end

// Exchange value
always @(posedge CLK or posedge RST) begin
	if (RST) begin
		exchange_value <= 3'd0;
	end
	else begin
		case(state)
             REPLACE: begin
                exchange_value <= 3'd7;
             end
             EXCHANGE: begin
                if((job_reg[job_cnt] > replace_value) && (job_reg[job_cnt] <= exchange_value)) exchange_value <= job_reg[job_cnt];
             	else exchange_value <= exchange_value;
             end
             default: begin
             	exchange_value <= exchange_value;
             end
		endcase
	end
end

// Exchange flag
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        exchange_flag <= 1'd0;
    end
    else begin
        case(state)
             EXCHANGE: begin
                 if(job_cnt == replace_position) exchange_flag <= 1'd1;
                 else exchange_flag <= 1'd0;
             end
             default: begin
                 exchange_flag <= 1'd0;
             end
        endcase
    end
end

// Read counter
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        read_cnt <= 3'd0;
    end
    else begin
        case(state)
             IDLE: begin
                 read_cnt <= 3'd0;
             end
             default: begin
                 if(read_cnt == 3'd7) read_cnt <= 3'd0;
                 else read_cnt <= read_cnt + 3'd1;
             end
        endcase
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        job_flag <= 1'd0;
    end
    else begin
        if(read_cnt == 3'd5) job_flag <= 1'd1;
        else job_flag <= job_flag;
    end
end

// Job
always @(*) begin
    J = (state == READ && job_flag) ? job_reg[job_cnt] : job_reg[read_cnt];
end

// Worker
always @(*) begin
    W = (state == READ) ? worker_cnt : read_cnt;
end

// Address of cost table
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        read_addr <= 3'd0;
    end
    else begin
        case(state)
             IDLE: begin
                 read_addr <= 3'd0;
             end
             READ: begin
                 read_addr <= job_cnt;
             end
             default: begin
                 read_addr <= read_cnt;
             end
        endcase
    end
end

// Cost table
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        for(i = 0; i < 8; i = i + 1) begin
            cost_table[i] <= 7'd0;
        end
    end
    else begin
        case(state)
             READ: begin
                 cost_table[read_addr] <= Cost;
             end
             REPLACE: begin
                 cost_table[read_addr] <= Cost;
             end
             EXCHANGE: begin
                 cost_table[read_addr] <= Cost;
             end
             default: begin
                 for(i = 0; i < 8; i = i + 1) begin
                     cost_table[i] <= cost_table[i];
                 end
             end
        endcase   
    end
end

// Summation of cost 
always @(*) begin
     cost_sum = cost_table[0] + cost_table[1] + cost_table[2] + cost_table[3] + cost_table[4] + cost_table[5] + cost_table[6] + cost_table[7];
end

// MinCost
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        MinCost <= 10'd1023;
    end
    else begin
        case(state)
             EXCHANGE: begin
                 if(job_flag && job_cnt == 3'd7) begin
                    if(cost_sum < MinCost) MinCost <= cost_sum;
                    else MinCost <= MinCost; 
                 end
                 else begin
                     MinCost <= MinCost;
                 end
             end
             default: begin
                 MinCost <= MinCost;
             end
        endcase
    end
end

// Match Count
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        MatchCount <= 4'd0;
    end
    else begin
        case(state)
             EXCHANGE: begin
                 if(job_flag && job_cnt == 3'd7) begin
                    if(cost_sum < MinCost) MatchCount <= 4'd1;
                    else if(cost_sum == MinCost) MatchCount <= MatchCount + 4'd1;
                    else MatchCount <= MatchCount; 
                 end
                 else begin
                     MatchCount <= MatchCount;
                 end
             end
             default: begin
                 MatchCount <= MatchCount;
             end
        endcase
    end
end

// Valid
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Valid <= 1'd0;
    end
    else if(job_reg[0] == 7 && job_reg[1] == 6 && job_reg[2] == 5 && job_reg[3] == 4 && job_reg[4] == 3 && job_reg[5] == 2 && job_reg[6] == 1 && job_reg[7] == 0) begin
        Valid <= 1'd1;
    end
    else begin
        Valid <= Valid;
    end
end

endmodule