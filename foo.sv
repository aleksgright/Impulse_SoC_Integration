module foo # (parameter width = 32)
 (
    input clk,
    input rst,

    input signed [width-1:0] a_in,
    input signed [width-1:0] b_in,
    input signed [width-1:0] c_in,
    input signed [width-1:0] d_in,
    input             arg_vld,

    output logic signed [width-1:0] res,
    output logic             res_vld 
 );
 
    localparam depth = 4;
    logic [depth-1:0] vld;

    logic signed [width-1:0] a_reg;
    logic signed [width-1:0] b_reg;
    logic signed [width-1:0] c_reg;
    logic signed [width-1:0] d_reg;

    logic signed [width-1:0] pre_res;
    
    logic signed [width-1:0] reg_arg1, reg_arg2, reg_arg3;
    logic signed [width-1:0] arg1, arg2, arg3;
    
    logic signed [width-1:0] mul_reg, tmp_reg;
    logic signed [width-1:0] mul;
    
    logic signed [width-1:0] shift_c, summ_c, diff;    


    always_comb begin
        arg1 = a_reg - b_reg;
        shift_c = c_reg <<< 1;
        summ_c = shift_c + c_reg;
        arg2 = summ_c + 1;
        arg3 = d_reg <<< 2;
    end
        
    always_comb begin
        mul = $signed(reg_arg1) * $signed(reg_arg2);
    end
    
    always_comb begin
        diff = mul_reg - tmp_reg;
    end

    always_ff @(posedge clk)
        if (rst)
            vld <= '0;
        else
            vld <= {vld[depth-2:0], arg_vld};
        
    assign res_vld = vld[depth-1];

    always_ff @(posedge clk)
        if (arg_vld) begin
            a_reg <= a_in;
            b_reg <= b_in;
            c_reg <= c_in;
            d_reg <= d_in;
        end
        
    always_ff @(posedge clk)
        if (vld[0]) begin
            reg_arg1 <= arg1;
            reg_arg2 <= arg2;
            reg_arg3 <= arg3;
        end
        
    always_ff @(posedge clk)
        if (vld[1]) begin
            tmp_reg <= reg_arg3;
            mul_reg <= mul;
        end

    always_ff @(posedge clk)
        if (vld[2])
            pre_res <= diff>>>1;
 
    assign res = pre_res[width-1] ? pre_res + 1 : pre_res;
    
endmodule