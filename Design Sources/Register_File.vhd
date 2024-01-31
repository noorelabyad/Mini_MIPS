

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Register_File is
    generic (sizeD: integer :=32; --data saize
             sizeA: integer:= 5); --address size
    Port ( clk : in STD_LOGIC;
           reset: in std_logic;
           RegWriteW : in STD_LOGIC;
           R1D : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R2D : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R3D : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           R1W : in STD_LOGIC_VECTOR(sizeA-1 downto 0);
           ResultW : in STD_LOGIC_VECTOR(sizeD-1 downto 0);
           dataR1D : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           dataR2D : out STD_LOGIC_VECTOR(sizeD-1 downto 0);
           dataR3D : out STD_LOGIC_VECTOR(sizeD-1 downto 0));
end Register_File;

architecture Behavioral of Register_File is

type regfile is array(0 to 31) of STD_LOGIC_VECTOR(sizeD-1 DOWNTO 0);
signal rf : regfile;

begin

--dataR1D <= x"00000000" when R1D = "00000" else rf(to_integer(unsigned(R1D)));
--dataR2D <= x"00000000" when R2D = "00000" else rf(to_integer(unsigned(R2D)));
--dataR3D <= x"00000000" when R3D = "00000" else rf(to_integer(unsigned(R3D)));

process(clk,RegWriteW,reset)
begin
   if (reset ='1')then
        rf<= (others=> x"00000000");
   elsif (falling_edge(clk))then
        if (RegWriteW='1') then
            rf(to_integer(unsigned(R1W)))<= ResultW;
        end if;
    end if;
    
end process;

process(R1D,R2D,R3D)
    begin
        
        if (R1D = "00000") then
            dataR1D <= x"00000000";
        else
            dataR1D <=rf(to_integer(unsigned(R1D)));
        end if;
        if (R2D = "00000") then
            dataR2D <= x"00000000";
        else
            dataR2D <=rf(to_integer(unsigned(R2D)));
        end if;
        if (R3D = "00000") then
            dataR3D <= x"00000000";
        else
            dataR3D <=rf(to_integer(unsigned(R3D)));
        end if;
       
     
end process;
end Behavioral;
