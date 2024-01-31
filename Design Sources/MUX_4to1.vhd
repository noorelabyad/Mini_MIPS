----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2023 11:50:42 AM
-- Design Name: 
-- Module Name: MUX_4to1 - Behavioral
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

entity MUX_4to1 is
    generic(size: integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           I2 : in STD_LOGIC_vector(size-1 downto 0);
           I3 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC_vector(1 downto 0);
           Output : out STD_LOGIC_vector(size-1 downto 0));
end MUX_4to1;

architecture Behavioral of MUX_4to1 is

begin
process(sel,I0,I1,I2,I3)
begin
    case(sel) is
        when "00" => Output<=I0;
        when "01" => Output<=I1;
        when "10" => Output<=I2;
        when "11" => Output<=I3;
        when others =>
    end case;
end process;


end Behavioral;
