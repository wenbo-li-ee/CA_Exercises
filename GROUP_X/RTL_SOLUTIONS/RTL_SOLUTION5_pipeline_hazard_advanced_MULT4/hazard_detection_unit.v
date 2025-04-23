module hazard_detection_unit
(
    input            mem_read_ID_EX,
    input wire [4:0] rd_ID_EX,
    input wire [4:0] rs1_IF_ID,
    input wire [4:0] rs2_IF_ID,
    output reg       PC_write_enable,
    output reg       IF_ID_write_enable,
    output reg       mux_control_EX
);


    always@(*) begin
        if(mem_read_ID_EX && ((rd_ID_EX == rs1_IF_ID) || (rd_ID_EX == rs2_IF_ID))) begin
            //load hazard detected
            PC_write_enable    = 1'b0;
            IF_ID_write_enable = 1'b0;
            mux_control_EX     = 1'b0;
        end

        else
        begin
            PC_write_enable    = 1'b1;
            IF_ID_write_enable = 1'b1;
            mux_control_EX     = 1'b1;
        end
    end

endmodule
