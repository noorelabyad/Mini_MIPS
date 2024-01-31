
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;



entity FetchStage is
    generic (sizeD: integer :=32;
             sizeM: integer:= 64;
             sizeMA: integer:= 32); 
    Port ( clk,reset: in std_logic;
           PCSrcD : in STD_LOGIC; -- (jump or branch) flag
           StallF : in STD_LOGIC; --stall fetch stage flag for stall flipflop En
           StallD : in STD_LOGIC; --stall decode stage flag for stage flipflop En
           PCBranchD: in std_logic_vector (sizeMA-1 downto 0); --PC value if (jump or branch) flag
           InstrD : out STD_LOGIC_vector (sizeD-1 downto 0)); --Instruction to be passed to decode
           
          -- initialPC : in std_logic_vector (sizeMA-1 downto 0);
          -- PC_Instr : in std_logic_vector (sizeMA-1 downto 0); --address of Instr to be placed in IM
          -- Instr:  in std_logic_vector (sizeD-1 downto 0)); --instr to be placed in IM
           
end FetchStage;

architecture Behavioral of FetchStage is

type RAM is array(0 TO sizeM-1) of STD_LOGIC_VECTOR(sizeD-1 DOWNTO 0);
signal InstructionMemory: RAM;

component MUX_2to1 is
    generic(size:integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC;
           Output : out STD_LOGIC_vector(size-1 downto 0));
end component;

component D_FF is
    generic (size: integer :=32);
    Port ( clk,reset : in STD_LOGIC;
           clear : in STD_LOGIC;
           En: in std_logic;
           D : in STD_LOGIC_vector (size-1 downto 0);
           Q : out STD_LOGIC_vector (size-1 downto 0));
end component;

signal InstrF : STD_LOGIC_vector (sizeD-1 downto 0);
signal PC,PCF,PCPlus1F : STD_LOGIC_vector (sizeMA-1 downto 0):=x"00000000";

begin


InstructionMemory (0)<= "00000000010000000000010001000101"; --add R1,R2,5
InstructionMemory (1)<= "00000000010000000000110010000111"; --add R3,R4,7
InstructionMemory (2)<= "00000000100000001001010001100001"; --subb R5,R3,R1
InstructionMemory (3)<= "00010000000000001001010001100001"; --sw R5,R3,1  (8)
InstructionMemory (4)<= "00001000000000001001110010100110"; --lw R7,R5,6  2 in R7
InstructionMemory (5)<= "00000010000000001001000011100011"; --and R4,R7,R3  stall then 2 and 7 = 2 in R4
InstructionMemory (6)<= "00000100000000001000100010000011"; --or R2,R4,R3 7 or 2 =7 in R2
InstructionMemory (7)<= "01000000000000001001000000100101"; --beqz r4,r1,5 (dont go to instr a)
InstructionMemory (8)<= "01000000000000001010000001001101"; --beqz r8,r2,13 -->go to instr 20 (14h)
--InstructionMemory (7)<= "00100000000000001000010111101101";--jr, r1,15 -->go to instr 20 (14h)
InstructionMemory (20)<="00000000010000000000010000100101"; --add r1,r1,5  (doesnt need forwarding)
--InstructionMemory (20)<="00000000010000000000010001000101"; --add r1,r2,5 (needs forwarding)
InstructionMemory (21 to sizeM-1) <= (others=> x"00000000");
InstructionMemory (9 to 19) <= (others=> x"00000000");

MUX_Abits: MUX_2to1 generic map(sizeMA) port map (PCPlus1F, PCBranchD,PCSrcD,PC);
StallFF : D_FF generic map (sizeMA) port map (clk,reset,'0',StallF,PC,PCF);
StageFF1 : D_FF generic map (sizeD) port map (clk,reset,PCSrcD,StallD,InstrF,InstrD);
InstrF <= InstructionMemory(to_integer(unsigned(PCF)));
PCPlus1F<= PCF+1;



end Behavioral;
