module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

reg [2:0] n_state;
reg [2:0] c_state;

reg [2:0] max_index;
reg [2:0] max;
reg [2:0] sortlist [0:7];
reg directions [0:7];
reg sortable;
reg [2:0] list_index;
reg [9:0] cost_sum;
reg [9:0] cost_min;

parameter IDLE          = 3'd0,
          CAL_COST      = 3'd1,
          MIN_CONFIRM   = 3'd2,
          MOVE          = 3'd3,
          FIN           = 3'd4
;

//c_state
always@(posedge CLK or posedge RST) begin
    if (RST) c_state <= IDLE;
    else c_state <= n_state;
end

//n_state
always@(*) begin
    case(c_state)
        IDLE : n_state = CAL_COST;
        CAL_COST : n_state = (W == 3'd7) ? MIN_CONFIRM : c_state;
        MIN_CONFIRM : n_state = MOVE;
        MOVE : n_state = (sortable == 1'b0) ? FIN : CAL_COST;
        default : n_state = c_state;
    endcase
end

//list_index
always @(posedge CLK or posedge RST) begin
    if(RST) list_index <= 3'd0;
    else if(n_state == CAL_COST) list_index <= list_index + 3'd1;
    else list_index <= 3'd0;
end

//sortlist
always @(posedge CLK or posedge RST) begin
    if(RST)begin
        sortlist[0] <= 3'd0;
        sortlist[1] <= 3'd1;
        sortlist[2] <= 3'd2;
        sortlist[3] <= 3'd3;
        sortlist[4] <= 3'd4;
        sortlist[5] <= 3'd5;
        sortlist[6] <= 3'd6;
        sortlist[7] <= 3'd7;
    end
    else if(c_state == MOVE && sortable == 1'b1)begin
        if(directions[sortlist[max_index]] == 1'b0)begin
            sortlist[max_index] <= sortlist[max_index-1];
            sortlist[max_index-1] <= sortlist[max_index];
        end
        else if(directions[sortlist[max_index]] == 1'b1)begin
            sortlist[max_index] <= sortlist[max_index+1];
            sortlist[max_index+1] <= sortlist[max_index];
        end
    end
end

//directions
always @(posedge CLK or posedge RST) begin
    if(RST)begin
        directions[0] <= 1'b0;
        directions[1] <= 1'b0;
        directions[2] <= 1'b0;
        directions[3] <= 1'b0;

        directions[4] <= 1'b0;
        directions[5] <= 1'b0;
        directions[6] <= 1'b0;
        directions[7] <= 1'b0;
    end
    else if(c_state == MOVE && sortable == 1'b1)begin
        directions[sortlist[0]] <= (sortlist[max_index] < sortlist[0]) ? ~directions[sortlist[0]] : directions[sortlist[0]];
        directions[sortlist[1]] <= (sortlist[max_index] < sortlist[1]) ? ~directions[sortlist[1]] : directions[sortlist[1]];
        directions[sortlist[2]] <= (sortlist[max_index] < sortlist[2]) ? ~directions[sortlist[2]] : directions[sortlist[2]];
        directions[sortlist[3]] <= (sortlist[max_index] < sortlist[3]) ? ~directions[sortlist[3]] : directions[sortlist[3]];

        directions[sortlist[4]] <= (sortlist[max_index] < sortlist[4]) ? ~directions[sortlist[4]] : directions[sortlist[4]];
        directions[sortlist[5]] <= (sortlist[max_index] < sortlist[5]) ? ~directions[sortlist[5]] : directions[sortlist[5]];
        directions[sortlist[6]] <= (sortlist[max_index] < sortlist[6]) ? ~directions[sortlist[6]] : directions[sortlist[6]];
        directions[sortlist[7]] <= (sortlist[max_index] < sortlist[7]) ? ~directions[sortlist[7]] : directions[sortlist[7]];
    end
end

//max_index && max
always @(*) begin
    if(c_state == MIN_CONFIRM)begin
        max_index = 3'd0;
        max = 3'd0;
        if(max < sortlist[0] && (directions[sortlist[0]] == 1'b1 && sortlist[0] > sortlist[1]))begin
            max = sortlist[0];
            max_index = 3'd0;
        end
        if(max < sortlist[1] &&((directions[sortlist[1]] == 1'b0 && sortlist[1] > sortlist[0])||(directions[sortlist[1]] == 1'b1 && sortlist[1] > sortlist[2])))begin
            max = sortlist[1];
            max_index = 3'd1;
        end
        if(max < sortlist[2] &&((directions[sortlist[2]] == 1'b0 && sortlist[2] > sortlist[1])||(directions[sortlist[2]] == 1'b1 && sortlist[2] > sortlist[3])))begin
            max = sortlist[2];
            max_index = 3'd2;
        end
        if(max < sortlist[3] &&((directions[sortlist[3]] == 1'b0 && sortlist[3] > sortlist[2])||(directions[sortlist[3]] == 1'b1 && sortlist[3] > sortlist[4])))begin
            max = sortlist[3];
            max_index = 3'd3;
        end
        if(max < sortlist[4] &&((directions[sortlist[4]] == 1'b0 && sortlist[4] > sortlist[3])||(directions[sortlist[4]] == 1'b1 && sortlist[4] > sortlist[5])))begin
            max = sortlist[4];
            max_index = 3'd4;
        end
        if(max < sortlist[5] &&((directions[sortlist[5]] == 1'b0 && sortlist[5] > sortlist[4])||(directions[sortlist[5]] == 1'b1 && sortlist[5] > sortlist[6])))begin
            max = sortlist[5];
            max_index = 3'd5;
        end
        if(max < sortlist[6] &&((directions[sortlist[6]] == 1'b0 && sortlist[6] > sortlist[5])||(directions[sortlist[6]] == 1'b1 && sortlist[6] > sortlist[7])))begin
            max = sortlist[6];
            max_index = 3'd6;
        end
        if(max < sortlist[7] &&((directions[sortlist[7]] == 1'b0 && sortlist[7] > sortlist[6])))begin
            max = sortlist[7];
            max_index = 3'd7;
        end
    end
    else begin
        max_index = max_index;
        max = max_index;
    end
end
//sortable
always @(*) begin
    sortable = 1'b0;
    sortable = ( directions[sortlist[0]] == 1'b1 && sortlist[0] > sortlist[1]) ? 1'b1 : sortable;
    sortable = ((directions[sortlist[1]] == 1'b0 && sortlist[1] > sortlist[0])||(directions[sortlist[1]] == 1'b1 && sortlist[1] > sortlist[2])) ? 1'b1 : sortable;
    sortable = ((directions[sortlist[2]] == 1'b0 && sortlist[2] > sortlist[1])||(directions[sortlist[2]] == 1'b1 && sortlist[2] > sortlist[3])) ? 1'b1 : sortable;
    sortable = ((directions[sortlist[3]] == 1'b0 && sortlist[3] > sortlist[2])||(directions[sortlist[3]] == 1'b1 && sortlist[3] > sortlist[4])) ? 1'b1 : sortable;
    sortable = ((directions[sortlist[4]] == 1'b0 && sortlist[4] > sortlist[3])||(directions[sortlist[4]] == 1'b1 && sortlist[4] > sortlist[5])) ? 1'b1 : sortable;
    sortable = ((directions[sortlist[5]] == 1'b0 && sortlist[5] > sortlist[4])||(directions[sortlist[5]] == 1'b1 && sortlist[5] > sortlist[6])) ? 1'b1 : sortable;
    sortable = ((directions[sortlist[6]] == 1'b0 && sortlist[6] > sortlist[5])||(directions[sortlist[6]] == 1'b1 && sortlist[6] > sortlist[7])) ? 1'b1 : sortable;
    sortable = ( directions[sortlist[7]] == 1'b0 && sortlist[7] > sortlist[6]) ? 1'b1 : sortable;
end

//W
always @(posedge CLK or posedge RST) begin
    if(RST) W <= 3'd0;
    else if(c_state == CAL_COST) W <= list_index;
end

//J
always @(*) begin
    J = sortlist[W];
end

//cost_sum
always @(posedge CLK or posedge RST) begin
    if(RST) cost_sum <= 10'd0;
    else if(c_state == CAL_COST) cost_sum <= cost_sum + Cost;
    else cost_sum <= 10'd0;
end

//cost_min
always @(posedge CLK or posedge RST) begin
    if(RST) cost_min <= 10'd1023;
    else if(c_state == MIN_CONFIRM) cost_min <= (cost_min > cost_sum) ? cost_sum : cost_min;
end

//MinCost
always @(posedge CLK or posedge RST) begin
    if(RST) MinCost <= 10'd0;
    else if(c_state == FIN) MinCost <= cost_min;
end

//MatchCount
always @(posedge CLK or posedge RST) begin
    if(RST) MatchCount <= 4'd0;
    else if(c_state == MIN_CONFIRM)begin
        if(cost_min > cost_sum) MatchCount <= 4'd1;
        else if(cost_min == cost_sum) MatchCount <= MatchCount + 4'd1;
    end
end

//Valid
always @(posedge CLK or posedge RST) begin
    if(RST) Valid <= 1'b0;
    else if(c_state == FIN) Valid <= 1'b1;
end

endmodule