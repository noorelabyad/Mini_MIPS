----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 12:20:21 PM
-- Design Name: 
-- Module Name: MUX_2to1 - Behavioral
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

entity MUX_2to1 is
    generic(size:integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC;
           Output : out STD_LOGIC_vector(size-1 downto 0));
end MUX_2to1;

architecture Behavioral of MUX_2to1 is

begin

Output <=I0 when sel = '0' else I1;

end Behavioral;
