
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExecuteStage is
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
end ExecuteStage;

architecture Behavioral of ExecuteStage is

component MUX_2to1 is
    generic(size:integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC;
           Output : out STD_LOGIC_vector(size-1 downto 0));
end component;

component MUX_4to1 is
    generic(size: integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           I2 : in STD_LOGIC_vector(size-1 downto 0);
           I3 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC_vector(1 downto 0);
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

component DFF1Bit is
    
    Port ( clk,reset : in STD_LOGIC;
           clear : in STD_LOGIC;
           En: in std_logic;
           D : in STD_LOGIC;
           Q : out STD_LOGIC);
end component;


signal outmuxIR,operand1,operand2,ALUOutE,dataR1tmp : std_logic_vector(sizeD-1 downto 0);

begin

MUXIR : MUX_2to1 generic map(32) port map (SignImmE,dataR3E,ALUSrcE,outmuxIR);
MUXop1 : MUX_4to1 generic map(32) 
port map (dataR2E,ResultW,iALUOutM,x"00000000",ForwardAE,operand1);
MUXop2 : MUX_4to1 generic map(32) 
port map (outmuxIR,ResultW,iALUOutM,x"00000000",ForwardBE,operand2);

MUXsw : MUX_4to1 generic map(32) 
port map (dataR1E,ResultW,iALUOutM,x"00000000",ForwardSW,dataR1tmp);


process(ALUControlE,operand1,operand2)
begin
    case (ALUControlE) is
        when "00" => ALUOutE<= operand1+operand2;
        when "01" => ALUOutE<= operand1-operand2;
        when "10" => ALUOutE<= operand1 and operand2;
        when "11" => ALUOutE<= operand1 or operand2;
        when others =>
    end case; 
end process;

DFFStage1: DFF1Bit port map (clk,reset,'0','0',RegWriteE,RegWriteM);
DFFStage2: DFF1Bit port map (clk,reset,'0','0',MemtoRegE,MemtoRegM);
DFFStage3: DFF1Bit port map (clk,reset,'0','0',MemWriteE,MemWriteM);

DFFStage4 : D_FF generic map (5) port map (clk,reset,'0','0',R1E,R1M);
DFFStage5 : D_FF generic map (5) port map (clk,reset,'0','0',R2E,R2M);
DFFStage6 : D_FF generic map (5) port map (clk,reset,'0','0',R3E,R3M);

DFFStage7 : D_FF generic map (32) port map (clk,reset,'0','0',dataR1tmp,dataR1M);

DFFStage8 : D_FF generic map (32) port map (clk,reset,'0','0',ALUOutE,oALUOutM);

end Behavioral;
