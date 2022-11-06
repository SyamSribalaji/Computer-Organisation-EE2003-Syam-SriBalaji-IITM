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
);

    reg [31:0] iaddr;
    reg [31:0] daddr;
    reg [31:0] dwdata;
    reg [3:0]  dwe;

    //Address DQ
    reg [31:0] iaddrd;

    //Important variables
    reg [4:0] rs1, rs2, rd;
    reg [31:0] dreg1, dreg2;
    reg [31:0] dreg3;

    //Primary Important variables
    reg unsigned [5:0] instrno;

    //Flags for Load
    reg regload;

    //Flag for no. of lines of Instructions
    //reg [5:0] ln;

    reg [31:0] imm, imm_s, imm_us;
    reg [4:0] shamt;

    //Variable for Case in Always*
    reg [2:0] caseflag;

     reg [31:0] regfile [31:0]; //Register file
     
     reg [5:0] i;
     
     initial begin
          for(i=0 ; i <= 31 ; i=i+1) begin
               regfile [i] = 0;
          end
     end

     always @(*) begin
          dreg1 = regfile [rs1];
          dreg2 = regfile [rs2];
     end

    //Whole Instruction
    always @(posedge clk) begin
          
        if (reset) begin
            iaddr <= 0;
            iaddrd <= 0;
            rs1 = 0;
            rs2 = 0;
            rd = 0;
            dwe = 0;
            dreg3 = 0;
            regload = 0;
            daddr = 0;
            dwdata = 0;
            iaddrd = 0;
            instrno = 0;
            caseflag = 0;
            imm = 0;
            imm_s = 0;
            imm_us = 0;
            for(i=0 ; i<32 ; i=i+1) begin regfile [i] = 0; end 

        end 
        else begin
          
          case (caseflag)
               0 : begin
                    //Instruction finder
                    if (idata[6:0] == 7'b0000011) begin //Load
                         rs1 = idata[19:15];
                         rd = idata[11:7];
                         imm = $signed({idata[31:20]});
                         caseflag = caseflag + 1;

                         if (idata[14:12] == 3'b000)  begin instrno = 11; end //LB
                         if (idata[14:12] == 3'b001)  begin instrno = 12; end //LH
                         if (idata[14:12] == 3'b010)  begin instrno = 13; end //LW
                         if (idata[14:12] == 3'b100)  begin instrno = 14; end //LBU
                         if (idata[14:12] == 3'b101)  begin instrno = 15; end //LHU
                    end

                    if (idata[6:0] == 7'b0100011) begin //Store
                         rs1 = idata[19:15];
                         rs2 = idata[24:20];
                         imm = $signed({idata[31:25],idata[11:7]});
                         caseflag = caseflag + 1;

                         if (idata[14:12] == 3'b000) begin instrno = 16; end //SB
                         if (idata[14:12] == 3'b001) begin instrno = 17; end //SB
                         if (idata[14:12] == 3'b010) begin instrno = 18; end //SW
                    end

                    if (idata[6:0] == 7'b0010011) begin //ALU with Immediate
                         rs1 = idata[19:15];
                         rd = idata[11:7];
                         imm_s = $signed({idata[31:20]});
                         imm_us = $unsigned({idata[31:20]});
                         shamt = idata[24:20];
                         caseflag = caseflag + 1;

                         if (idata[14:12] == 3'b000) begin instrno = 19; end //ADDI
                         if (idata[14:12] == 3'b010) begin instrno = 20; end //SLTI
                         if (idata[14:12] == 3'b011) begin instrno = 21; end //SLTII
                         if (idata[14:12] == 3'b100) begin instrno = 22; end //XORI
                         if (idata[14:12] == 3'b110) begin instrno = 23; end //ORI
                         if (idata[14:12] == 3'b111) begin instrno = 24; end //ANDI
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b001) begin instrno = 25; end //SLLI
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b101) begin instrno = 26; end //SRLI
                         if (idata[31:25] == 7'b0100000 && idata[14:12] == 3'b101) begin instrno = 27; end //SRAI
                    end

                    if (idata[6:0] == 7'b0110011) begin //ALU without Immediate
                         rs1 = idata[19:15];
                         rs2 = idata[24:20];
                         rd = idata[11:7];
                         caseflag = caseflag + 1;

                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b000) begin instrno = 28; end //ADD
                         if (idata[31:25] == 7'b0100000 && idata[14:12] == 3'b000) begin instrno = 29; end //SUB
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b001) begin instrno = 30; end //SLL
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b010) begin instrno = 31; end //SLT
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b011) begin instrno = 32; end //SLTU
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b100) begin instrno = 33; end //XOR
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b101) begin instrno = 34; end //SRL
                         if (idata[31:25] == 7'b0100000 && idata[14:12] == 3'b101) begin instrno = 35; end //SRA
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b110) begin instrno = 36; end //OR
                         if (idata[31:25] == 7'b0000000 && idata[14:12] == 3'b111) begin instrno = 37; end //AND
                    end
                    
                    if (idata[6:0] == 7'b1100011) begin //Branch
                         rs1 = idata[19:15];
                         rs2 = idata[24:20];
                         imm = $signed({idata[31], idata[7], idata[30:25], idata[11:8], {1'b0}});
                         caseflag = caseflag + 1;

                         if (idata[14:12] == 3'b000)  begin instrno = 5;  end //BEQ
                         if (idata[14:12] == 3'b001)  begin instrno = 6;  end //BNE
                         if (idata[14:12] == 3'b100)  begin instrno = 7;  end //BLT
                         if (idata[14:12] == 3'b101)  begin instrno = 8;  end //BGE
                         if (idata[14:12] == 3'b110)  begin instrno = 9;  end //BLTU
                         if (idata[14:12] == 3'b111)  begin instrno = 10; end //BGEU
                    end

                    if (idata[6:0] == 7'b0110111) begin //LUI
                        rd = idata[11:7];
                        imm = $signed(idata[31:12]);
                        instrno = 1;
                        caseflag = caseflag + 1;
                    end
                    if (idata[6:0] == 7'b0010111) begin //AUIPC
                        rd = idata[11:7];
                        imm = $signed(idata[31:12]);
                        instrno = 2;
                        caseflag = caseflag + 1;
                    end
                    if (idata[6:0] == 7'b1101111) begin //JAL
                        rd = idata[11:7];
                        imm = $signed({idata[31], idata[19:12], idata[20], idata[30:21], {1'b0}});
                        instrno = 3;
                        caseflag = caseflag + 1;
                    end
                    if (idata[6:0] == 7'b1100111) begin //JALR
                        rs1 = idata[19:15];
                        rd = idata[11:7];            
                        imm = $signed(idata[31:20]);	
                        instrno = 4;
                        caseflag = caseflag +1;
                    end

                    if (idata[31:0] == {32{1'b0}}) begin instrno <= 0; caseflag = 5; iaddrd =  iaddr + 4;  end  //For all Zero Instruction (goes to dafault)
               end


               1 : begin
                    //Just to give basic Instruction variables input

                         if (instrno == 11) begin //LB
                              daddr = dreg1 + imm;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 12) begin //LH
                              daddr = dreg1 + imm;  
                              caseflag = caseflag + 1;                            
                         end

                         else if (instrno == 13) begin //LW
                              daddr = dreg1 + imm;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 14) begin //LBU
                              daddr = dreg1 + imm; 
                              caseflag = caseflag + 1;                            
                         end

                         else if (instrno == 15) begin //LHU
                              daddr = dreg1 + imm;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 16) begin //SB
                              daddr = dreg1 + imm;  
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 17) begin //SH
                              daddr = dreg1 + imm;              
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 18)  begin //SW
                              daddr = dreg1 + imm;
                              caseflag = caseflag + 1;                       
                         end

                         else begin //For other than Store or Load Instructions
                              caseflag = caseflag + 1;                          
                         end
               end

               2 : begin
                    //One special case(2)
                         if (instrno == 1) begin //LUI
                            imm = imm << 12;
                            caseflag = caseflag + 1;                        
                         end
                         else if (instrno == 2) begin //AUIPC
                            imm = imm << 12;
                            caseflag = caseflag + 1; 
                         end

                    //Mainly for Store
                         else if (instrno == 16) begin //SB
                              if (daddr[1:0] == 2'b00) begin
                                   dwe = 4'b0001;
                              end
                              else if (daddr[1:0] == 2'b01)begin
                                   dwe = 4'b0010;
                              end
                              else if (daddr[1:0] == 2'b10)begin
                                   dwe = 4'b0100;
                              end
                              else begin
                                   dwe = 4'b1000;
                              end

                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 17) begin //SH
                              if (daddr[1:0] == 2'b00 || daddr[1:0] == 2'b01) begin
                                   dwe = 4'b0011;
                              end
                              else begin
                                   dwe = 4'b1100;
                              end

                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 18)  begin //SW
                              dwe = 4'b1111;
                              caseflag = caseflag + 1;                              
                         end

                         else begin //For other than Store, LUI, AUIPC
                              caseflag = caseflag + 1;                          
                         end
               end


               3 : begin
                    //Every Instruction Calculator

                         if (instrno == 1) begin //LUI
                            if (rd != 5'b00000) begin
                                    dreg3 = imm;
                                    regload = 1;
                            end

                            $display("LUI is gettting done");
                            iaddrd = iaddrd + 4;
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 2) begin //AUIPC
                            if (rd != 5'b00000) begin
                                    dreg3 = iaddr + imm;
                                    regload = 1;
                            end

                            $display("AUIPC is gettting done");
                            iaddrd = iaddrd + 4;
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 3) begin //JAL
                            if (rd != 5'b00000) begin
                                    dreg3 = iaddr + 4;
                                    regload = 1;
                            end

                            iaddrd = iaddrd + imm;
                            $display("JAL is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 4) begin //JALR
                            if (rd != 5'b00000) begin
                                    dreg3 = iaddr + 4;
                                    regload = 1;
                            end
                            
                            iaddrd = (dreg1 + imm) & ~1;
                            $display("JALR is gettting done");
                            caseflag = caseflag + 1;
                         end
                         
                         if (instrno == 5) begin //BEQ
                            if (dreg1 == dreg2) begin
                                    iaddrd = iaddrd + imm;
                            end
                            else begin
                                    iaddrd =  iaddr + 4;
                            end

                            $display("BEQ is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 6) begin //BNE
                            if (dreg1 != dreg2) begin
                                    iaddrd = iaddrd + imm;
                            end
                            else begin
                                    iaddrd =  iaddr + 4;
                            end

                            $display("BNE is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 7) begin //BLT
                            if ($signed(dreg1) < $signed(dreg2)) begin
                                    iaddrd = iaddrd + imm;
                            end
                            else begin
                                    iaddrd =  iaddr + 4;
                            end

                            $display("BLT is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 8) begin //BGE
                            if ($signed(dreg1) >= $signed(dreg2)) begin
                                    iaddrd = iaddrd + imm;
                            end
                            else begin
                                    iaddrd =  iaddr + 4;
                            end

                            $display("BGE is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 9) begin //BLTU
                            if (dreg1 < dreg2) begin
                                    iaddrd = iaddrd + imm;
                            end
                            else begin
                                    iaddrd =  iaddr + 4;
                            end

                            $display("BLTU is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 10) begin //BGEU
                            if (dreg1 >= dreg2) begin
                                    iaddrd = iaddrd + imm;
                            end
                            else begin
                                    iaddrd =  iaddr + 4;
                            end

                            $display("BGEU is gettting done");
                            caseflag = caseflag + 1;
                         end

                         if (instrno == 11) begin //LB
                              if (rd != 5'b00000) begin
                                   if (daddr[1:0] == 2'b00) begin
                                        dreg3 = $signed(drdata[7:0]);
                                   end
                                   else if (daddr[1:0] == 2'b01)begin
                                        dreg3 = $signed(drdata[15:8]);
                                   end
                                   else if (daddr[1:0] == 2'b10)begin
                                        dreg3 = $signed(drdata[23:16]);
                                   end
                                   else begin
                                        dreg3 = $signed(drdata[31:24]);
                                   end
                                   regload = 1;
                              end

                              $display("LB is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 12) begin //LH
                             if (rd != 5'b00000) begin
                                   if (daddr[1:0] == 2'b00 || daddr[1:0] == 2'b01) begin
                                        dreg3 = $signed(drdata[15:0]);
                                   end
                                   else begin
                                        dreg3 = $signed(drdata[31:16]);
                                   end
                                   
                                   regload = 1;
                              end
                              
                              $display("LH is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 13) begin //LW
                              if (rd != 5'b00000) begin
                                   dreg3 = drdata;
                                   regload = 1;
                              end

                              $display("LW is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 14) begin //LBU
                              if (rd != 5'b00000) begin
                                   if (daddr[1:0] == 2'b00) begin
                                        dreg3 = $unsigned(drdata[7:0]);
                                   end
                                   else if (daddr[1:0] == 2'b01)begin
                                        dreg3 = $unsigned(drdata[15:8]);
                                   end
                                   else if (daddr[1:0] == 2'b10)begin
                                        dreg3 = $unsigned(drdata[23:16]);
                                   end
                                   else begin
                                        dreg3 = $unsigned(drdata[31:24]);
                                   end
                                   
                                   regload = 1;
                              end 
                              
                              $display("LBU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                            
                         end

                         else if (instrno == 15) begin //LHU
                              if (rd != 5'b00000) begin
                                   if (daddr[1:0] == 2'b00 || daddr[1:0] == 2'b01) begin
                                        dreg3 = $unsigned(drdata[15:0]);
                                   end
                                   else begin
                                        dreg3 = $unsigned(drdata[31:16]);
                                   end

                                   regload = 1;
                              end

                              $display("LBU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 16) begin //SB
                              dwdata = {4{dreg2[7:0]}};
                              $display("SB is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 17) begin //SH
                              dwdata = {2{dreg2[15:0]}};
                              $display("SH is gettting done"); 
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 18)  begin //SW
                              dwdata = dreg2;
                              $display("SW is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 19) begin //ADDI
                             if (rd != 5'b00000) begin
                                   dreg3 = dreg1 + imm_s;
                                   regload = 1;
                              end

                              $display("ADDI is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 20) begin //SLTI
                              if (rd != 5'b00000) begin
                                   dreg3 = (dreg1 < imm_s) ? 1 : 0;
                                   regload = 1;
                              end

                              $display("SLTI is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 21) begin //SLTIU
                              if (rd != 5'b00000) begin
                                   dreg3 = (dreg1 < imm_us) ? 1 : 0;
                                   regload = 1;
                              end

                              $display("SLTIU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;
                              
                         end

                         else if (instrno == 22) begin //XORI
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 ^ imm_s;
                                   regload = 1;
                              end

                              $display("SLTIU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 23) begin //ORI
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 | imm_s;
                                   regload = 1;
                              end

                              $display("SLTIU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 24) begin //ANDI
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 & imm_s;
                                   regload = 1;
                              end

                              $display("SLTIU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;
                         end

                         else if (instrno == 25) begin //SLLI
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 << shamt;
                                   regload = 1;
                              end
                              
                              $display("SLTIU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 26) begin //SRLI
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 >> shamt;
                                   regload = 1;
                              end

                              $display("SLTIU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 27) begin //SRAI
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 >>> shamt;
                                   regload = 1;
                              end

                              $display("SRAI is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 28) begin //ADD
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 + dreg2;
                                   regload = 1;
                              end

                              $display("ADD is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 29) begin //SUB
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 - dreg2;
                                   regload = 1;
                              end

                              $display("SUB is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 30) begin //SLL
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 << dreg2;
                                   regload = 1;
                              end

                              $display("SLL is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 31) begin //SLT
                              if (rd != 5'b00000) begin
                                   dreg3 = (dreg1 < dreg2) ? 1 : 0;
                                   regload = 1;
                              end

                              $display("SLT is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 32) begin //SLTU
                              if (rd != 5'b00000) begin
                                   dreg3 = (dreg1 < dreg2) ? 1 : 0;
                                   regload = 1;
                              end

                              $display("SLTU is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 33) begin //XOR
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 ^ dreg2;
                                   regload = 1;
                              end

                              $display("XOR is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 34) begin //SRL
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 >> dreg2[4:0];
                                   regload = 1;
                              end

                              $display("SRL is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 35) begin //SRA
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 >>> dreg2[4:0];
                                   regload = 1;
                              end

                              $display("SRA is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 36) begin //OR
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 | dreg2[4:0];
                                   regload = 1;
                              end

                              $display("OR is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end

                         else if (instrno == 37) begin //AND
                              if (rd != 5'b00000) begin
                                   dreg3 = dreg1 & dreg2[4:0];
                                   regload = 1;
                              end

                              $display("AND is gettting done");
                              iaddrd =  iaddr + 4;
                              caseflag = caseflag + 1;                              
                         end


               end

               4 : begin
                    if(regload) begin
                         regfile [rd] <= dreg3;
                    end
                    caseflag = caseflag + 1;
                    
               end

               5 : begin
                    caseflag = caseflag + 1;
                    rs1 = 0;
                    rs2 = 0;
                    rd = 0;
                    dreg3 = 0;
                    dreg1 = 0;
                    dreg2 = 0;
                    dwe = 0;
                    regload = 0;
                    imm = 0;
                    imm_s = 0;
                    imm_us = 0;
                    daddr = 0;
               end

               default begin
                    caseflag = 0;
                    iaddr <= iaddrd;
               end

               endcase
         end
    end

endmodule