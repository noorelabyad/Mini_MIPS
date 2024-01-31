
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity DecodeStage is
    generic (sizeD: integer :=32; --reg data size
             sizeA: integer:= 5; --reg address size
             sizeMA: integer:=32); --pc size
    Port ( clk : in STD_LOGIC;
           reset: in std_logic;
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
end DecodeStage;

architecture Behavioral of DecodeStage is

component D_FF is
    generic (size: integer :=32);
    Port ( clk,reset : in STD_LOGIC;
           clear : in STD_LOGIC;
           En: in std_logic;
           D : in STD_LOGIC_vector (size-1 downto 0);
           Q : out STD_LOGIC_vector (size-1 downto 0));
end component;

component DFF1Bit is
    
    Port ( clk,reset : in STD_LOGIC;
           clear : in STD_LOGIC;
           En: in std_logic;
           D : in STD_LOGIC;
           Q : out STD_LOGIC);
end component;

component Control_Unit is
    generic (sizeD: integer :=32; --data saize
             sizeA: integer:= 5); --address size
    Port ( InstrD : in STD_LOGIC_VECTOR (sizeD-1 downto 0);
           RegWriteD : out STD_LOGIC; 
           MemtoRegD : out STD_LOGIC;
           MemWriteD : out STD_LOGIC;
           ALUControlD : out STD_LOGIC_VECTOR(1 downto 0);
           ALUSrcD : out STD_LOGIC;
           BranchD : out STD_LOGIC;
           JumpD : out STD_LOGIC);
end component;

component MUX_2to1 is
    generic(size:integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC;
           Output : out STD_LOGIC_vector(size-1 downto 0));
end component;

component Register_File is
    generic (sizeD: integer :=32; --data saize
             sizeA: integer:= 5); --address size
    Port ( clk : in STD_LOGIC;
           reset : in std_logic;
           RegWriteW : in STD_LOGIC; --reg write enable
           R1D : in STD_LOGIC_VECTOR(sizeA-1 downto 0); --address of reg to read from
           R2D : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R3D : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R1W : in STD_LOGIC_VECTOR(sizeA-1 downto 0); -- address of reg to be written in
           ResultW : in STD_LOGIC_VECTOR(sizeD-1 downto 0); --data to be written in reg
           dataR1D : out STD_LOGIC_VECTOR(sizeD-1 downto 0); --data read from reg
           dataR2D : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           dataR3D : out STD_LOGIC_VECTOR(sizeD-1 downto 0));
end component;

signal RegWriteD,MemtoRegD,MemWriteD,ALUSrcD,JumpD,flagR1: std_logic;
signal ALUControlD : std_logic_vector (1 downto 0);
signal dataR1D,dataR1D_f,dataR2D,dataR2D_f,dataR3D,SignImmD,PCSignImm,Jump_SignImmD,tmpflagR1: std_logic_vector (sizeD-1 downto 0);
signal addresstmp: std_logic_vector (sizeD-1 downto 0);
signal zero : std_logic_vector(sizeD-1 downto 0):= (others => '0');
signal R2D,R3D,R1D : STD_LOGIC_vector (sizeA-1 downto 0):= (others=>'0');
signal iBranchD:std_logic; 
begin
R1D<=InstrD(14 downto 10); R2D<=InstrD(9 downto 5);R3D<=InstrD(4 downto 0);
RF: Register_File generic map(32,5) 
                 port map(clk,reset,RegWriteW,R1D,R2D,R3D,R1W,ResultW,dataR1D,dataR2D,dataR3D);
CU: Control_Unit generic map(32,5) 
                 port map(InstrD, RegWriteD,MemtoRegD,MemWriteD,ALUControlD,
                 ALUSrcD,iBranchD,JumpD);
                 
StageFF1: DFF1Bit port map(clk,reset,FlushE,'0',RegWriteD,RegWriteE);
StageFF2: DFF1Bit port map(clk,reset,FlushE,'0',MemtoRegD,MemtoRegE);
StageFF3: DFF1Bit port map(clk,reset,FlushE,'0',MemWriteD,MemWriteE);
StageFF4: D_FF generic map (2)port map(clk,reset,FlushE,'0',ALUControlD,ALUControlE);
StageFF5: DFF1Bit port map(clk,reset,FlushE,'0',ALUSrcD,ALUSrcE);

StageFF6: D_FF generic map (sizeD)port map(clk,reset,FlushE,'0',SignImmD,SignImmE);
StageFF7: D_FF generic map (sizeD)port map(clk,reset,FlushE,'0',dataR1D,dataR1E);
StageFF8: D_FF generic map (sizeD)port map(clk,reset,FlushE,'0',dataR2D,dataR2E);
StageFF9: D_FF generic map (sizeD)port map(clk,reset,FlushE,'0',dataR3D,dataR3E);

StageFF10: D_FF generic map (sizeA)port map(clk,reset,FlushE,'0',InstrD(14 downto 10),R1E);
StageFF11: D_FF generic map (sizeA)port map(clk,reset,FlushE,'0',InstrD(9 downto 5),R2E);
StageFF12: D_FF generic map (sizeA)port map(clk,reset,FlushE,'0',InstrD(4 downto 0),R3E);

MUX_DBits1: MUX_2to1 generic map(32) port map (dataR1D,ALUOutM,ForwardD1,tmpflagR1);
flagR1 <= '1' when ((tmpflagR1 or zero) = zero) else '0';


PCSrcD <= (iBranchD and flagR1 ) or JumpD;

MUX_DBits2: MUX_2to1 generic map(32) 
port map (dataR2D,ALUOutM,ForwardD2,dataR2D_f);

MUX_DBits3: MUX_2to1 generic map(32) 
port map (dataR1D,ALUOutM,ForwardD1,dataR1D_f);

MUX_DBits4: MUX_2to1 generic map(32) 
port map (dataR2D_f,dataR1D_f,JumpD,addresstmp);

SignImmD <= ("111111111111111111111111111"& InstrD(4 downto 0)) when (InstrD(4)='1')
else ("000000000000000000000000000"& InstrD(4 downto 0));
Jump_SignImmD <= ("111111111111111111111111111"& InstrD(9 downto 5)) when (InstrD(9)='1')
else ("000000000000000000000000000"& InstrD(9 downto 5));

MUX_DBits5: MUX_2to1 generic map(32) 
port map (SignImmD,Jump_SignImmD,JumpD,PCSignImm);

PCBranchD<= PCSignImm + addresstmp;
BranchD<=iBranchD;


end Behavioral;
