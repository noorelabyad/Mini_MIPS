----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2023 03:30:08 PM
-- Design Name: 
-- Module Name: WriteBackStage - Behavioral
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

entity WriteBackStage is
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
end WriteBackStage;

architecture Behavioral of WriteBackStage is

component MUX_2to1 is
    generic(size:integer:=32);
    Port ( I0 : in STD_LOGIC_vector(size-1 downto 0);
           I1 : in STD_LOGIC_vector(size-1 downto 0);
           sel : in STD_LOGIC;
           Output : out STD_LOGIC_vector(size-1 downto 0));
end component;

begin

MUX_DBits : MUX_2to1 generic map(32) port map(ALUOutW,readDataW,MemtoRegW,ResultW);

oR1W<=iR1W;
oRegWriteW<=iRegWriteW;

end Behavioral;
