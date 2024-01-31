----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 08:49:33 PM
-- Design Name: 
-- Module Name: MIPS - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MIPS is
   generic (sizeD: integer :=32; --data word size
             sizeA: integer:=5; --reg adressing size
             sizeM: integer:= 64; --memory size in words
             sizeMA: integer:= 32); --memory word addressing size
    Port ( clk : in STD_LOGIC;
           reset: in std_logic;
           initialPC : in STD_LOGIC_Vector (sizeMA-1 downto 0));
end MIPS;

architecture Behavioral of MIPS is

--type RAM is array(0 TO 63) of STD_LOGIC_VECTOR(31 DOWNTO 0);
--signal InstructionMemory,DataMemory : RAM;

component FetchStage is
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
end component;

signal PCSrcD : STD_LOGIC:='0';
signal StallF : STD_LOGIC:='0'; 
signal StallD : STD_LOGIC:='0'; 
signal PCBranchD: std_logic_vector (sizeMA-1 downto 0):= (others=>'0'); 
signal InstrD: std_logic_vector (sizeD-1 downto 0):= (others=>'0');  
signal PC_Instr : STD_LOGIC_vector (sizeMA-1 downto 0):= x"00000000";
signal Instr : STD_LOGIC_vector (sizeD-1 downto 0):="00000000010000001000010001000101";

component DecodeStage is
   generic (sizeD: integer :=32; --data size
             sizeA: integer:= 5; 
             sizeMA: integer:=32);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           InstrD : in STD_LOGIC_VECTOR(sizeD-1 downto 0); --instr fetched from IM
           R1W : in STD_LOGIC_VECTOR(sizeA-1 downto 0); -- address of R1 for writing in R1
           ResultW : in STD_LOGIC_VECTOR(sizeD-1 downto 0); --Result to be written in R1
           RegWriteW : in STD_LOGIC; --Enable writing in R1
           ALUOutM : in STD_LOGIC_VECTOR(sizeD-1 downto 0); --forwarded R1 post execute
           ForwardD1,ForwardD2 : in STD_LOGIC; --forwarding flag for R1 post execute
           FlushE : in STD_LOGIC;
           BranchD: out std_logic;
           PCBranchD : out STD_LOGIC_VECTOR(sizeMA-1 downto 0); --PC address if jump or branch
           PCSrcD : out STD_LOGIC; --jump or branch
           RegWriteE : out STD_LOGIC; --not lw,sw,jump,branch
           MemtoRegE : out STD_LOGIC; --load
           MemWriteE : out STD_LOGIC; --store
           ALUControlE : out STD_LOGIC_vector (1 downto 0); --alu operation code
           ALUSrcE : out STD_LOGIC; --immediate or register: 1-->R 0-->I
           dataR1E : out STD_LOGIC_VECTOR(sizeD-1 downto 0);--data in R1
           dataR2E : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           dataR3E : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           SignImmE : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           R1E : out STD_LOGIC_VECTOR(sizeA-1 downto 0); --address of R1
           R2E : out STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R3E : out STD_LOGIC_VECTOR(sizeA-1 downto 0));
end component;

signal iR1W,oR1W :STD_LOGIC_VECTOR(sizeA-1 downto 0):= (others=>'0'); 
signal ResultW : STD_LOGIC_VECTOR(sizeD-1 downto 0):= (others=>'0'); 
signal oRegWriteW,iRegWriteW : STD_LOGIC:='0'; 
signal ALUOutM : STD_LOGIC_VECTOR(sizeD-1 downto 0):= (others=>'0'); 
signal ForwardD1,ForwardD2,BranchD : STD_LOGIC:='0'; 
signal FlushE : STD_LOGIC:='0';
signal RegWriteE :STD_LOGIC:='0';
signal MemtoRegE : STD_LOGIC:='0'; 
signal MemWriteE :  STD_LOGIC:='0';
signal ALUControlE :  STD_LOGIC_vector (1 downto 0):= (others=>'0');  
signal ALUSrcE : STD_LOGIC:='0'; 
signal dataR1E : STD_LOGIC_VECTOR(sizeD-1 downto 0):= (others=>'0'); 
signal dataR2E : STD_LOGIC_VECTOR(sizeD-1 downto 0):= (others=>'0'); 
signal dataR3E : STD_LOGIC_VECTOR(sizeD-1 downto 0):= (others=>'0'); 
signal SignImmE :  STD_LOGIC_VECTOR(sizeD-1 downto 0):= (others=>'0'); 
signal R1E :  STD_LOGIC_VECTOR(sizeA-1 downto 0):= (others=>'0');  
signal R2E : STD_LOGIC_VECTOR(sizeA-1 downto 0):= (others=>'0'); 
signal R3E :  STD_LOGIC_VECTOR(sizeA-1 downto 0):= (others=>'0'); 


component ExecuteStage is
    generic (sizeD: integer :=32; --data size
             sizeA: integer:= 5);
    Port ( clk,reset : in STD_LOGIC;
           RegWriteE : in STD_LOGIC;
           MemtoRegE : in STD_LOGIC;
           MemWriteE : in STD_LOGIC;
           ALUControlE : in STD_LOGIC_vector (1 downto 0);
           ALUSrcE : in STD_LOGIC;
           SignImmE : in STD_LOGIC_vector (sizeD-1 downto 0);
           dataR1E : in STD_LOGIC_vector (sizeD-1 downto 0);
           dataR2E : in STD_LOGIC_vector (sizeD-1 downto 0);
           dataR3E : in STD_LOGIC_vector (sizeD-1 downto 0);
           R1E : in STD_LOGIC_vector (sizeA-1 downto 0);
           R2E : in STD_LOGIC_vector (sizeA-1 downto 0);
           R3E : in STD_LOGIC_vector (sizeA-1 downto 0);
           ForwardAE : in STD_LOGIC_vector(1 downto 0);
           ForwardBE : in STD_LOGIC_vector(1 downto 0);
           ForwardSW : in STD_LOGIC_vector(1 downto 0);
           ResultW: in STD_LOGIC_vector (sizeD-1 downto 0);
           iALUOutM: in STD_LOGIC_vector (sizeD-1 downto 0);
           oALUOutM: out STD_LOGIC_vector (sizeD-1 downto 0);
           R1M : out STD_LOGIC_vector (sizeA-1 downto 0);
           R2M : out STD_LOGIC_vector (sizeA-1 downto 0);
           R3M : out STD_LOGIC_vector (sizeA-1 downto 0);
           dataR1M: out STD_LOGIC_vector (sizeD-1 downto 0);
           RegWriteM : out STD_LOGIC;
           MemtoRegM : out STD_LOGIC;
           MemWriteM : out STD_LOGIC);
end component;

signal ForwardAE : STD_LOGIC_vector(1 downto 0):="00";
signal ForwardBE :  STD_LOGIC_vector(1 downto 0):="00";
signal ForwardSW : STD_LOGIC_vector(1 downto 0):="00";
signal R1M,R1D : STD_LOGIC_vector (sizeA-1 downto 0):= (others=>'0'); 
signal R2M,R2D :  STD_LOGIC_vector (sizeA-1 downto 0):= (others=>'0'); 
signal R3M,R3D :  STD_LOGIC_vector (sizeA-1 downto 0):= (others=>'0'); 
signal dataR1M:  STD_LOGIC_vector (sizeD-1 downto 0); 
signal RegWriteM :  STD_LOGIC:='0';
signal MemtoRegM :  STD_LOGIC:='0';
signal MemWriteM : STD_LOGIC:='0';

component MemoryStage is
    generic (sizeD: integer :=32;
             sizeM: integer:= 64;
             sizeA: integer:= 5); 
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           RegWriteM : in STD_LOGIC;
           MemtoRegM : in STD_LOGIC;
           MemWriteM : in STD_LOGIC;
           R1M : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R2M : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R3M : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           dataR1M : in STD_LOGIC_VECTOR(sizeD-1 downto 0);
           ALUOutM: in STD_LOGIC_VECTOR(sizeD-1 downto 0);
           RegWriteW: out std_logic;
           MemtoRegW: out std_logic;
           ALUOutW : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           readDataW : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           R1W : out STD_LOGIC_VECTOR(sizeA-1 downto 0));
end component;


signal MemtoRegW: std_logic;
signal ALUOutW : STD_LOGIC_VECTOR(sizeD-1 downto 0);
signal readDataW :STD_LOGIC_VECTOR(sizeD-1 downto 0);

component WriteBackStage is
    generic (sizeD: integer:=32; sizeA:integer:=5 );
    Port ( clk,reset : in STD_LOGIC;
           ALUOutW : in STD_LOGIC_VECTOR(sizeD-1 downto 0);
           readDataW : in STD_LOGIC_VECTOR(sizeD-1 downto 0);
           iR1W : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           iRegWriteW : in STD_LOGIC;
           MemtoRegW : in STD_LOGIC;
           ResultW : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           oR1W : out STD_LOGIC_VECTOR(sizeA-1 downto 0);
           oRegWriteW : out STD_LOGIC);
end component;

component HazardUnit is
  generic (sizeA: integer:=5);
  Port ( clk,reset:in std_logic;         
         RegWriteE : in STD_LOGIC;
         RegWriteM : in STD_LOGIC;
         RegWriteW : in STD_LOGIC;
         MemtoRegE : in STD_LOGIC;
         MemtoRegM : in STD_LOGIC;
         MemWriteE : in STD_LOGIC;
         BranchD : in STD_LOGIC;
         R1E : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R2E : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R3E : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R1D : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R2D : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R3D : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R1M : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R1W : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         StallF : out STD_LOGIC;
         StallD : out STD_LOGIC;
         FlushE : out STD_LOGIC;
         ForwardAE: out STD_LOGIC_VECTOR (1 DOWNTO 0);
         ForwardBE : out STD_LOGIC_VECTOR (1 DOWNTO 0);
         ForwardD1,ForwardD2 : out STD_LOGIC;
         ForwardSW : out STD_LOGIC_VECTOR (1 DOWNTO 0));
end component;
begin
R1D<=InstrD(14 downto 10); R2D<=InstrD(9 downto 5);R3D<=InstrD(4 downto 0);

Fetch: FetchStage generic map(32,64,32) port map (clk,reset,PCSrcD,StallF,StallD,PCBranchD,InstrD);--,initialPC,PC_Instr,Instr);
Decode: DecodeStage generic map(32,5,32) port map(clk,reset,InstrD,oR1W,ResultW,oRegWriteW,ALUOutM,
ForwardD1,ForwardD2, FlushE, BranchD, PCBranchD,PCSrcD,RegWriteE,MemtoRegE,MemWriteE,ALUControlE,ALUSrcE,
dataR1E,dataR2E,dataR3E,SignImmE,R1E,R2E,R3E);
Execute : ExecuteStage generic map(32,5) port map (clk,reset,RegWriteE,MemtoRegE,MemWriteE,ALUControlE,
ALUSrcE,SignImmE,dataR1E,dataR2E,dataR3E,R1E,R2E,R3E,ForwardAE,ForwardBE,ForwardSW,ResultW,ALUOutM,ALUOutM,
R1M,R2M,R3M,dataR1M,RegWriteM, MemtoRegM, MemWriteM);
Memory: MemoryStage generic map(32,64,5) port map (clk,reset,RegWriteM,MemtoRegM,MemWriteM,R1M,R2M,R3M,
dataR1M,ALUOutM,iRegWriteW,MemtoRegW,ALUOutW,readDataW,iR1W);
WriteBack : WriteBackStage generic map(32,5) port map (clk,reset,ALUOutW,readDataW,iR1W,iRegWriteW,MemtoRegW,ResultW,oR1W,oRegWriteW);
HU : HazardUnit generic map(5) port map(clk,reset,RegWriteE,RegWriteM,iRegWriteW,MemtoRegE,MemtoRegM,
MemWriteE,BranchD,R1E,R2E,R3E,R1D,R2D,R3D,R1M,iR1W,StallF,StallD,FlushE,ForwardAE,
ForwardBE,ForwardD1,ForwardD2,ForwardSW);
end Behavioral;
