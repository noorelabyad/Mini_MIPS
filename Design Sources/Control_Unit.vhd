----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 06:12:56 PM
-- Design Name: 
-- Module Name: Control_Unit - Behavioral
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

entity Control_Unit is
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
end Control_Unit;

architecture Behavioral of Control_Unit is

begin

process(InstrD)
    begin
    case(InstrD(31 downto 22)) is
        --add
        when "0000000001" => RegWriteD<='1';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="00";
                              BranchD<='0';JumpD<='0';ALUSrcD<= InstrD(15);
        --sub
        when "0000000010" => RegWriteD<='1';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="01";
                               BranchD<='0';JumpD<='0';ALUSrcD<= InstrD(15);
        --and
        when "0000001000" => RegWriteD<='1';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="10";
                               BranchD<='0';JumpD<='0';ALUSrcD<= '1';
        --or
        when "0000010000" => RegWriteD<='1';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="11";
                               BranchD<='0';JumpD<='0';ALUSrcD<= '1';
        --load
        when "0000100000" => RegWriteD<='1';MemtoRegD<='1';MemWriteD<='0'; ALUControlD<="00";
                               BranchD<='0';JumpD<='0';ALUSrcD<= '0';
        --store
        when "0001000000" => RegWriteD<='0';MemtoRegD<='0';MemWriteD<='1'; ALUControlD<="00";
                               BranchD<='0';JumpD<='0';ALUSrcD<= '0';
        --jump
        when "0010000000" => RegWriteD<='0';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="00";
                               BranchD<='0';JumpD<='1';ALUSrcD<= '0';
        --branch
        when "0100000000" => RegWriteD<='0';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="00";
                               BranchD<='1';JumpD<='0';ALUSrcD<= '0';
        when others=> RegWriteD<='0';MemtoRegD<='0';MemWriteD<='0'; ALUControlD<="00";
                               BranchD<='0';JumpD<='0';ALUSrcD<= '0';
                          
    end case;
    
end process;


end Behavioral;
