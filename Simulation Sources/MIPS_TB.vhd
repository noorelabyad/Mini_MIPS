-- MIPS

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MIPS_TB is

end MIPS_TB;

architecture Behavioral of MIPS_TB is
    
    component MIPS is
    Port ( clk,reset : in STD_LOGIC;
           initialPC : in STD_LOGIC_Vector (31 downto 0));
    end component;
    
    signal clk, reset: STD_LOGIC; 
    signal initialPC : STD_LOGIC_Vector (31 downto 0);  

begin
    -- instantiate device under test
    -- initialPC <= x"00000000";
    dut: MIPS port map(clk,reset, initialPC);

    -- generate clock
    process begin
    
        clk <= '1'; wait for 1 ns;
        clk <= '0'; wait for 1 ns;
    end process;
    
    process begin
    
        initialPC <= x"00000000"; wait;
    end process;
    process begin
    wait for 2 ns;
        reset<='1'; wait for 2 ns;
        reset<='0';wait;
    end process;
    

end Behavioral;
