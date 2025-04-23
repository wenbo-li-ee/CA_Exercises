//Module: CPU
//Function: CPU is the top design of the RISC-V processor

//Inputs:
//	clk: main clock
//	arst_n: reset 
// enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory

// Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[63:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[63:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [63:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[63:0]  rdata_ext_2

   );

wire              zero_flag;
wire [      63:0] branch_pc,updated_pc,current_pc,jump_pc;
wire [      31:0] instruction;

//IF_ID_reg
wire [      31:0] instruction_IF_ID;
wire [      63:0] current_pc_IF_ID;
wire [      95:0] IF_ID_reg_D;
wire [      95:0] IF_ID_reg_Q;
reg               IF_ID_reg_enable;

assign IF_ID_reg_D = {current_pc,instruction};

assign current_pc_IF_ID  = IF_ID_reg_Q [95:32];
assign instruction_IF_ID = IF_ID_reg_Q [31:0];


// middle variable
wire [       1:0] alu_op;
wire [       3:0] alu_control;
wire              reg_dst,branch,mem_read,mem_2_reg,
                  mem_write,alu_src, reg_write, jump;
wire [       4:0] regfile_waddr;
wire [      63:0] regfile_wdata,mem_data,alu_out,
                  regfile_rdata_1,regfile_rdata_2,
                  alu_operand_2;
wire signed [63:0] immediate_extended;


//ID_EX_reg
wire [       1:0] alu_op_ID_EX;
wire              reg_dst_ID_EX,branch_ID_EX,mem_read_ID_EX,mem_2_reg_ID_EX,
                  mem_write_ID_EX,alu_src_ID_EX, reg_write_ID_EX, jump_ID_EX;      
wire [      63:0] current_pc_ID_EX;
wire [      63:0] regfile_rdata_1_ID_EX,regfile_rdata_2_ID_EX;
wire [      63:0] immediate_extended_ID_EX;
wire [      31:0] instruction_ID_EX;
wire [     297:0] ID_EX_reg_D;
wire [     297:0] ID_EX_reg_Q;
reg               ID_EX_reg_enable;

assign ID_EX_reg_D = {alu_op, reg_dst, branch, mem_read, mem_2_reg, mem_write, alu_src, reg_write, jump, current_pc_IF_ID, regfile_rdata_1, regfile_rdata_2, immediate_extended, instruction_IF_ID};

assign alu_op_ID_EX             = ID_EX_reg_Q[297:296];
assign reg_dst_ID_EX            = ID_EX_reg_Q[295];
assign branch_ID_EX             = ID_EX_reg_Q[294];
assign mem_read_ID_EX           = ID_EX_reg_Q[293];
assign mem_2_reg_ID_EX          = ID_EX_reg_Q[292];
assign mem_write_ID_EX          = ID_EX_reg_Q[291];
assign alu_src_ID_EX            = ID_EX_reg_Q[290];
assign reg_write_ID_EX          = ID_EX_reg_Q[289];
assign jump_ID_EX               = ID_EX_reg_Q[288];
assign current_pc_ID_EX         = ID_EX_reg_Q[287:224];
assign regfile_rdata_1_ID_EX    = ID_EX_reg_Q[223:160];
assign regfile_rdata_2_ID_EX    = ID_EX_reg_Q[159:96];
assign immediate_extended_ID_EX = ID_EX_reg_Q[95:32];
assign instruction_ID_EX        = ID_EX_reg_Q[31:0];


//forwarding_unit and mux_3
wire [ 1:0] mux_select_forward_a;
wire [ 1:0] mux_select_forward_b;
wire [63:0] mux_3_alu_operand_1;
wire [63:0] mux_3_alu_operand_2;

//EX_MEM_reg
wire jump_EX_MEM, branch_EX_MEM, mem_read_EX_MEM, mem_2_reg_EX_MEM, mem_write_EX_MEM,reg_write_EX_MEM;
wire [      63:0] branch_pc_EX_MEM;
wire [      63:0] jump_pc_EX_MEM;
wire              zero_flag_EX_MEM;
wire [      63:0] alu_out_EX_MEM;
wire [      63:0] regfile_rdata_2_EX_MEM;
wire [      31:0] instruction_EX_MEM;
wire [     294:0] EX_MEM_reg_D;
wire [     294:0] EX_MEM_reg_Q;
reg               EX_MEM_reg_enable;

assign EX_MEM_reg_D = {jump_ID_EX, branch_ID_EX, mem_read_ID_EX, mem_2_reg_ID_EX, mem_write_ID_EX, reg_write_ID_EX, branch_pc, jump_pc, zero_flag, alu_out, regfile_rdata_2_ID_EX, instruction_ID_EX};

assign jump_EX_MEM            = EX_MEM_reg_Q[294];
assign branch_EX_MEM          = EX_MEM_reg_Q[293];
assign mem_read_EX_MEM        = EX_MEM_reg_Q[292];
assign mem_2_reg_EX_MEM       = EX_MEM_reg_Q[291];
assign mem_write_EX_MEM       = EX_MEM_reg_Q[290];
assign reg_write_EX_MEM       = EX_MEM_reg_Q[289];
assign branch_pc_EX_MEM       = EX_MEM_reg_Q[288:225];
assign jump_pc_EX_MEM         = EX_MEM_reg_Q[224:161];
assign zero_flag_EX_MEM       = EX_MEM_reg_Q[160];
assign alu_out_EX_MEM         = EX_MEM_reg_Q[159:96];
assign regfile_rdata_2_EX_MEM = EX_MEM_reg_Q[95:32];
assign instruction_EX_MEM     = EX_MEM_reg_Q[31:0];



//MEM_WB_reg
wire mem_2_reg_MEM_WB, reg_write_MEM_WB;
wire [      63:0] mem_data_MEM_WB;
wire [      63:0] alu_out_MEM_WB;
wire [      31:0] instruction_MEM_WB;
wire [     161:0] MEM_WB_reg_D;
wire [     161:0] MEM_WB_reg_Q;
reg               MEM_WB_reg_enable;

assign MEM_WB_reg_D = {mem_2_reg_EX_MEM, reg_write_EX_MEM, mem_data, alu_out_EX_MEM, instruction_EX_MEM};

assign mem_2_reg_MEM_WB     = MEM_WB_reg_Q[161];
assign reg_write_MEM_WB     = MEM_WB_reg_Q[160];
assign mem_data_MEM_WB      = MEM_WB_reg_Q[159:96];
assign alu_out_MEM_WB       = MEM_WB_reg_Q[95:32];
assign instruction_MEM_WB   = MEM_WB_reg_Q[31:0];



pc #(
   .DATA_W(64)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (branch_pc_EX_MEM ),
   .jump_pc   (jump_pc_EX_MEM   ),
   .zero_flag (zero_flag_EX_MEM ),
   .branch    (branch_EX_MEM    ),
   .jump      (jump_EX_MEM      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);



sram_BW32 #(
   .ADDR_W(9 )
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);



reg_arstn_en#(
   .DATA_W(96)
)signal_pipe_IF_ID(
   .clk    (clk),
   .arst_n (arst_n),
   .en     (IF_ID_reg_enable),
   .din    (IF_ID_reg_D),
   .dout   (IF_ID_reg_Q)
);



control_unit control_unit(
   .opcode   (instruction_IF_ID[6:0]),
   .alu_op   (alu_op          ),
   .reg_dst  (reg_dst         ),
   .branch   (branch          ),
   .mem_read (mem_read        ),
   .mem_2_reg(mem_2_reg       ),
   .mem_write(mem_write       ),
   .alu_src  (alu_src         ),
   .reg_write(reg_write       ),
   .jump     (jump            )
);




register_file #(
   .DATA_W(64)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write_MEM_WB  ),
   .raddr_1  (instruction_IF_ID[19:15]),
   .raddr_2  (instruction_IF_ID[24:20]),
   .waddr    (instruction_MEM_WB[11:7]),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_rdata_1   ),
   .rdata_2  (regfile_rdata_2   )
);




immediate_extend_unit immediate_extend_u(
    .instruction         (instruction_IF_ID),
    .immediate_extended  (immediate_extended)
);


reg_arstn_en#(
   .DATA_W(298)
)signal_pipe_ID_EX(
   .clk    (clk),
   .arst_n (arst_n),
   .en     (ID_EX_reg_enable),
   .din    (ID_EX_reg_D),
   .dout   (ID_EX_reg_Q)
);





branch_unit#(
   .DATA_W(64)
)branch_unit(
   .current_pc         (current_pc_ID_EX        ),
   .immediate_extended (immediate_extended_ID_EX),
   .branch_pc          (branch_pc               ),
   .jump_pc            (jump_pc                 )
);


mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (immediate_extended_ID_EX),
   .input_b (mux_3_alu_operand_2   ),
   .select_a(alu_src_ID_EX           ),
   .mux_out (alu_operand_2     )
);


alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (mux_3_alu_operand_1 ),
   .alu_in_1 (alu_operand_2   ),
   .alu_ctrl (alu_control     ),
   .alu_out  (alu_out         ),
   .zero_flag(zero_flag       ),
   .overflow (                )
);



mux_3#(
   .DATA_W(64)
) alu_operand1_mux(
   .input_a  (regfile_rdata_1_ID_EX),
   .input_b  (regfile_wdata),
   .input_c  (alu_out_EX_MEM),
   .select_a (mux_select_forward_a),
   .mux_out  (mux_3_alu_operand_1)
);

mux_3#(
   .DATA_W(64)
) alu_operand2_mux(
   .input_a  (regfile_rdata_2_ID_EX),
   .input_b  (regfile_wdata),
   .input_c  (alu_out_EX_MEM),
   .select_a (mux_select_forward_b),
   .mux_out  (mux_3_alu_operand_2)
);

forwarding_unit forwarding_unit(
   .rs1_ID_EX(instruction_ID_EX[19:15]),
   .rs2_ID_EX(instruction_ID_EX[24:20]),
   .rd_EX_MEM(instruction_EX_MEM[11:7]),
   .rd_MEM_WB(instruction_MEM_WB[11:7]),
   .reg_write_EX_MEM(reg_write_EX_MEM),
   .reg_write_MEM_WB(reg_write_MEM_WB),
   .forward_a(mux_select_forward_a),
   .forward_b(mux_select_forward_b)
);

alu_control alu_ctrl(
   .func7       (instruction_ID_EX[31:25]   ),
   .func3          (instruction_ID_EX[14:12]),
   .alu_op         (alu_op_ID_EX            ),
   .alu_control    (alu_control       )
);


reg_arstn_en#(
   .DATA_W(295)
)signal_pipe_EX_MEM(
   .clk    (clk),
   .arst_n (arst_n),
   .en     (EX_MEM_reg_enable),
   .din    (EX_MEM_reg_D),
   .dout   (EX_MEM_reg_Q)
);





sram_BW64 #(
   .ADDR_W(10)
) data_memory(
   .clk      (clk            ),
   .addr     (alu_out_EX_MEM        ),
   .wen      (mem_write_EX_MEM      ),
   .ren      (mem_read_EX_MEM       ),
   .wdata    (regfile_rdata_2_EX_MEM),
   .rdata    (mem_data       ),
   .addr_ext (addr_ext_2     ),
   .wen_ext  (wen_ext_2      ),
   .ren_ext  (ren_ext_2      ),
   .wdata_ext(wdata_ext_2    ),
   .rdata_ext(rdata_ext_2    )
);




reg_arstn_en#(
   .DATA_W(162)
)signal_pipe_MEM_WB(
   .clk    (clk),
   .arst_n (arst_n),
   .en     (MEM_WB_reg_enable),
   .din    (MEM_WB_reg_D),
   .dout   (MEM_WB_reg_Q)
);




mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (mem_data_MEM_WB     ),
   .input_b  (alu_out_MEM_WB      ),
   .select_a (mem_2_reg_MEM_WB    ),
   .mux_out  (regfile_wdata)
);


always@(posedge clk or negedge arst_n)begin
   if(!arst_n)begin
      IF_ID_reg_enable  <= 0;
      ID_EX_reg_enable  <= 0;
      EX_MEM_reg_enable <= 0;
      MEM_WB_reg_enable <= 0;
   end
   else begin
      IF_ID_reg_enable  <= 1;
      ID_EX_reg_enable  <= 1;
      EX_MEM_reg_enable <= 1;
      MEM_WB_reg_enable <= 1;
   end
end


endmodule


