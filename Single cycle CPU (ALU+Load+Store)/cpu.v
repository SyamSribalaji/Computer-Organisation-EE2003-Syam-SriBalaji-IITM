//SINGLE CYCLE CPU
//Syam SriBalaji T
//EE20B136
//09.10.22

module cpu (
    input clk, 
    input reset,

    output [31:0] iaddr,
    input [31:0] idata,

    output [31:0] daddr,
    input [31:0] drdata,
    
    output [31:0] dwdata,
    output [3:0] dwe

    //output [32*32-1:0] registers  // EXTRA PORT
);

    reg [31:0] iaddr;
    reg [31:0] daddr;
    reg [31:0] dwdata;
    reg [3:0]  dwe;

    //Address DQ
    reg [31:0] iaddrd;

    //Important variables
    reg [4:0] rs1, rs2, rd;
    wire [31:0] dreg1, dreg2;
    reg [31:0] dreg3;

    //Primary Important variables
    reg unsigned [5:0] instrno;

    //Flags for Load
    reg regload;



     reg [31:0] regfile [31:0]; //Register file

     //assign registers = {regfile[31], regfile[30], regfile[29], regfile[28], regfile[27], regfile[26], regfile[25], regfile[24], regfile[23], regfile[22], regfile[21], regfile[20], regfile[19], regfile[18], regfile[17], regfile[16], regfile[15], regfile[14], regfile[13], regfile[12], regfile[11], regfile[10], regfile[9], regfile[8], regfile[7], regfile[6], regfile[5], regfile[4], regfile[3], regfile[2], regfile[1], regfile[0]};
     

     //Very Important variables New way
     reg [6:0] opcode;
     reg [31:0] imm_12; //For LUI & AUIPC
     reg [31:0] imm_store; //For Store
     reg [31:0] imm_branch; //For Branch
     reg [31:0] imm_jal; //For Jal
     reg [31:0] imm_s, imm_us;

     reg [4:0] shamt;

     //For identifying
     reg [2:0] iden3;
     reg [6:0] iden7;

     //For Load and Store daddr
     reg [31:0] daddr_store;
     reg [31:0] daddr_load;


     integer i;

     assign dreg1 = regfile [rs1];
     assign dreg2 = regfile [rs2];

//ALWAYS POSEDGE
     always @(posedge clk) begin
          if (reset) begin
               iaddr <= 0;
               for(i=0 ; i<32 ; i=i+1) begin regfile [i] <= 0; end
          end
          else begin
               iaddr <= iaddrd;
               if (regload == 1) begin
                    if (rd != 5'b00000) begin
                         regfile [rd] <= dreg3;
                    end
               end
          end
     end

//ALWAYS STAR
     always @(*) begin
          if (reset) begin
               rs1 = 0;
               rs2 = 0;
               rd = 0;
               iaddrd = 0;
          end
          else begin
               opcode = idata[6:0];
               //From load
               rs1 = idata[19:15];
               rd = idata[11:7];
               //imm = $signed({idata[31:20]});  Lets use imm_s here

               //For store
               rs2 = idata[24:20];
               imm_store = $signed({idata[31:25],idata[11:7]});

               //ALU with Immediate
               imm_s = $signed({idata[31:20]});
               imm_us = $unsigned({idata[31:20]});
               shamt = idata[24:20];

               //ALU without Immediate

               //Branch
               imm_branch = $signed({idata[31], idata[7], idata[30:25], idata[11:8], {1'b0}});

               //LUI
               imm_12 = $signed(idata[31:12]); //For LUI and AUIPC

               //AUIPC

               //JAL
               imm_jal = $signed({idata[31], idata[19:12], idata[20], idata[30:21], {1'b0}});

               //JALR
               //imm = $signed(idata[31:20]); Lets use imm_s here

               iden3 = idata[14:12];
               iden7 = idata[31:25];

               //For Store
               daddr_store = $signed(dreg1) + $signed(imm_store);

               //For Load
               daddr_load = $signed(dreg1) + $signed(imm_s);

               regload = 0;
               dwe = 0;
               
               case (opcode)

                    7'b0000011 : begin //Load
                         daddr = daddr_load;
                         case (iden3)
                              3'b000 : begin //LB
                                   dreg3 = $signed(drdata[7:0]);
                                   regload = 1;
                                   $display("LB is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b001 : begin //LH
                                   dreg3 = $signed(drdata[15:0]);
                                   regload = 1;
                                   $display("LH is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b010 : begin //LW
                                   dreg3 = drdata;
                                   regload = 1;
                                   $display("LW is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b100 : begin //LBU
                                   dreg3 = $unsigned(drdata[7:0]);
                                   regload = 1;
                                   $display("LBU is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b101 : begin //LHU
                                   dreg3 = $unsigned(drdata[15:0]);
                                   regload = 1;
                                   $display("LBU is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                         endcase
                    end

                    7'b0100011 : begin //Store
                         daddr = daddr_store;
                         case (iden3)
                              3'b000 : begin //SB
                                   case (daddr_store[1:0])
                                        2'b00 : begin
                                             dwe = 4'b0001;
                                        end
                                        2'b01 : begin
                                             dwe = 4'b0010;
                                        end
                                        2'b10 : begin
                                             dwe = 4'b0100;
                                        end
                                        2'b11 : begin
                                             dwe = 4'b1000;
                                        end
                                   endcase
                                   dwdata = {4{dreg2[7:0]}};
                                   $display("SB is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b001 : begin //SH
                                   case (daddr_store[1:0])
                                        2'b00 : begin
                                             dwe = 4'b0011;
                                        end
                                        2'b01 : begin
                                             dwe = 4'b0011;
                                        end
                                        2'b10 : begin
                                             dwe = 4'b1100;
                                        end
                                        2'b11 : begin
                                             dwe = 4'b1100;
                                        end
                                   endcase
                                   dwdata = {2{dreg2[15:0]}};
                                   $display("SH is gettting done"); 
                                   iaddrd =  iaddr + 4;
                              end
                              3'b010 : begin //SW
                                   dwe = 4'b1111;
                                   dwdata = dreg2;
                                   $display("SW is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                         endcase
                    end

                    7'b0010011 : begin //ALU with Immediate
                         case (iden3)
                              3'b000 : begin //ADDI
                                   dreg3 = $signed(dreg1) + imm_s;
                                   regload = 1;
                                   $display("ADDI is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b010 : begin //SLTI
                                   dreg3 = ($signed(dreg1) < imm_s) ? 1 : 0;
                                   regload = 1;
                                   $display("SLTI is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b011 : begin //SLTIU
                                   dreg3 = ($unsigned(dreg1) < imm_us) ? 1 : 0;
                                   regload = 1;
                                   $display("SLTIU is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b100 : begin //XORI
                                   dreg3 = $signed(dreg1) ^ imm_s;
                                   regload = 1;
                                   $display("XORI is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b110 : begin //ORI
                                   dreg3 = $signed(dreg1) | imm_s;
                                   regload = 1;
                                   $display("ORI is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b111 : begin //ANDI
                                   dreg3 = $signed(dreg1) & imm_s;
                                   regload = 1;
                                   $display("ANDI is gettting done");
                                   iaddrd =  iaddr + 4;
                              end
                              3'b001 : begin
                                   case (iden7)
                                        7'b0000000 : begin //SLLI
                                             dreg3 = dreg1 << (shamt);
                                             regload = 1;
                                             $display("SLLI is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                   endcase
                              end
                              3'b101 : begin
                                   case (iden7)
                                        7'b0000000 : begin //SRLI
                                             dreg3 = dreg1 >> (shamt);
                                             regload = 1;
                                             $display("SRLI is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        7'b0100000 : begin //SRAI
                                             dreg3 = dreg1 >>> (shamt);
                                             regload = 1;
                                             $display("SRAI is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                   endcase
                              end
                         endcase
                    end

                    7'b0110011 : begin //ALU without Immediate
                         case (iden7)
                              7'b0000000 : begin
                                   case (iden3)
                                        3'b000 : begin //ADD
                                             dreg3 = dreg1 + dreg2;
                                             regload = 1;
                                             $display("ADD is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b001 : begin //SLL
                                             dreg3 = dreg1 << (dreg2[4:0]);
                                             regload = 1;
                                             $display("SLL is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b010 : begin //SLT
                                             dreg3 = ($signed(dreg1) < $signed(dreg2)) ? 1 : 0;
                                             regload = 1;
                                             $display("SLT is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b011 : begin //SLTU
                                             dreg3 = ($unsigned(dreg1) < $unsigned(dreg2)) ? 1 : 0;
                                             regload = 1;
                                             $display("SLT is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b100 : begin //XOR
                                             dreg3 = (dreg1) ^ (dreg2);
                                             regload = 1;
                                             $display("ADD is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b101 : begin //SRL
                                             dreg3 = dreg1 >> (dreg2[4:0]);
                                             regload = 1;
                                             $display("SRL is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b110 : begin //OR
                                             dreg3 = (dreg1) | (dreg2);
                                             regload = 1;
                                             $display("SRL is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                        3'b111 : begin //AND
                                             dreg3 = (dreg1) & (dreg2);
                                             regload = 1;
                                             $display("SRL is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                   endcase                         
                              end
                              7'b0100000 : begin
                                   case (iden3)
                                        3'b000 : begin //SUB
                                             dreg3 = dreg1 - dreg2;
                                             regload = 1;
                                             $display("ADD is gettting done");
                                             iaddrd =  iaddr + 4;                                   
                                        end
                                        3'b101 : begin //SRA
                                             dreg3 = dreg1 >>> (dreg2[4:0]);
                                             regload = 1;
                                             $display("SRL is gettting done");
                                             iaddrd =  iaddr + 4;
                                        end
                                   endcase
                              end                         
                         endcase
                    end
                         
                    7'b1100011 : begin //Branch
                         case (iden3)
                              3'b000 : begin //BEQ
                                   if (dreg1 == dreg2) begin
                                        iaddrd = $signed(iaddr) + $signed(imm_branch);
                                   end
                                   else begin
                                        iaddrd =  iaddr + 4;
                                   end
                                   $display("BEQ is gettting done");   
                              end
                              3'b001 : begin //BNE
                                   if (dreg1 != dreg2) begin
                                        iaddrd = $signed(iaddr) + $signed(imm_branch);
                                   end
                                   else begin
                                        iaddrd =  iaddr + 4;
                                   end
                                   $display("BNE is gettting done");
                              end
                              3'b100 : begin //BLT
                                   if ($signed(dreg1) < $signed(dreg2)) begin
                                        iaddrd = $signed(iaddr) + $signed(imm_branch);
                                   end
                                   else begin
                                        iaddrd =  iaddr + 4;
                                   end
                                   $display("BLT is gettting done");
                              end
                              3'b101 : begin //BGE
                                   if ($signed(dreg1) >= $signed(dreg2)) begin
                                        iaddrd = $signed(iaddr) + $signed(imm_branch);
                                   end
                                   else begin
                                        iaddrd =  iaddr + 4;
                                   end
                                   $display("BGE is gettting done");
                              end
                              3'b110 : begin //BLTU
                                   if ($unsigned(dreg1) < $unsigned(dreg2)) begin
                                        iaddrd = $signed(iaddr) + $signed(imm_branch);
                                   end
                                   else begin
                                        iaddrd =  iaddr + 4;
                                   end
                                   $display("BLTU is gettting done");
                              end
                              3'b111 : begin //BGEU
                                   if ($unsigned(dreg1 )>= $unsigned(dreg2)) begin
                                        iaddrd = $signed(iaddr) + $signed(imm_branch);
                                   end
                                   else begin
                                        iaddrd =  iaddr + 4;
                                   end
                                   $display("BGEU is getting done");   
                              end
                         endcase
                    end

                    7'b0110111 : begin //LUI
                         dreg3 = (imm_12 << 12);
                         regload = 1;
                         $display("LUI is gettting done");
                         iaddrd = iaddr + 4;
                    end
                    
                    7'b0010111 : begin //AUIPC
                         dreg3 = iaddr + (imm_12 << 12);
                         regload = 1;
                         $display("AUIPC is gettting done");
                         iaddrd = iaddr + 4;
                    end
                    
                    7'b1101111 : begin //JAL
                         dreg3 = iaddr + 4;
                         regload = 1;
                         $display("JAL is gettting done");
                         iaddrd = iaddr + $signed(imm_jal);
                    end
                    
                    7'b1100111 : begin //JALR
                         dreg3 = iaddr + 4;
                         regload = 1;
                         $display("JALR is gettting done");
                         iaddrd = ($signed(dreg1) + imm_s) & 32'hfffffffe;
                    end
                    
                    7'b0000000 : begin  //For all Zero Instruction (goes to dafault)
                         iaddrd = iaddr + 4;
                    end 
               endcase 
          end   
     end 
endmodule