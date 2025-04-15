module forwarding_unit
(
  input wire[4:0] rs1_ID_EX,
  input wire[4:0] rs2_ID_EX,
  input wire[4:0] rd_EX_MEM,
  input wire[4:0] rd_MEM_WB,
  input wire      reg_write_EX_MEM,
  input wire      reg_write_MEM_WB,
  output reg [1:0] forward_a,
  output reg [1:0] forward_b
);

always@(*) begin

    if(reg_write_EX_MEM && (rd_EX_MEM != 0) && (rd_EX_MEM == rs1_ID_EX)) begin
        forward_a = 2'b10;
    end
    else if(reg_write_MEM_WB && (rd_MEM_WB != 0) && (rd_MEM_WB == rs1_ID_EX) && !(reg_write_EX_MEM && (rd_EX_MEM != 0) && (rd_EX_MEM == rs1_ID_EX))) begin
        forward_a = 2'b01;
    end
    else begin
        forward_a = 2'b00;
    end


    if(reg_write_EX_MEM && (rd_EX_MEM != 0) && (rd_EX_MEM == rs2_ID_EX)) begin
        forward_b = 2'b10;
    end
    else if(reg_write_MEM_WB && (rd_MEM_WB != 0) && (rd_MEM_WB == rs2_ID_EX) && !(reg_write_EX_MEM && (rd_EX_MEM != 0) && (rd_EX_MEM == rs2_ID_EX))) begin
        forward_b = 2'b01;
    end
    else begin
        forward_b = 2'b00;
    end

end

endmodule
