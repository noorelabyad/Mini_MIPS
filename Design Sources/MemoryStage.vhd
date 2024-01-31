
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemoryStage is
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
end MemoryStage;

architecture Behavioral of MemoryStage is

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

type RAM is array(0 TO sizeM-1) of STD_LOGIC_VECTOR(sizeD-1 DOWNTO 0);
signal DataMemory: RAM;
signal readDataM: std_logic_vector(sizeD-1 downto 0);

begin

readDataM<=DataMemory(to_integer(unsigned(ALUOutM)));

process(clk,reset,MemWriteM)
begin
    if (reset = '1') then 
        DataMemory <= (others=> x"00000000");
    elsif(rising_edge(clk)) then
        if (MemWriteM ='1') then
            DataMemory(to_integer(unsigned(ALUOutM)))<= dataR1M;  
        end if;
        DataMemory(20)<=x"cccccccc";
    end if;
end process;

StageFF1: DFF1Bit  port map(clk,reset,'0','0',RegWriteM,RegWriteW);
StageFF2: DFF1Bit  port map(clk,reset,'0','0',MemtoRegM,MemtoRegW);
StageFF3: D_FF generic map(5) port map(clk,reset,'0','0',R1M,R1W);
StageFF4: D_FF generic map(32) port map(clk,reset,'0','0',ALUOutM,ALUOutW);
StageFF5: D_FF generic map(32) port map(clk,reset,'0','0',readDataM,readDataW);


end Behavioral;
