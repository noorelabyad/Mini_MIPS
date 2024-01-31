----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 12:04:46 PM
-- Design Name: 
-- Module Name: D_FF - Behavioral
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

entity D_FF is
    generic (size: integer :=32);
    Port ( clk : in STD_LOGIC;
           reset: in std_logic;
           clear : in STD_LOGIC;
           En: in std_logic;
           D : in STD_LOGIC_vector (size-1 downto 0);
           Q : out STD_LOGIC_vector (size-1 downto 0));
end D_FF;

architecture Behavioral of D_FF is

begin
process (clk,reset, clear,En)
begin
    if (reset = '1') then Q <= (others=>'0');
    elsif(rising_edge(clk)) then
        
        if (En = '0') then
            if (clear = '1') then 
                Q <= (others =>'0');
            else
                Q <= D;
            end if;
        end if;
    end if;
end process;
end Behavioral;
