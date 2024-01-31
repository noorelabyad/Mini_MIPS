library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity HazardUnit is
  generic (sizeA: integer:=5);
  Port ( clk,reset:in std_logic;         
         RegWriteE : in STD_LOGIC;
         RegWriteM : in STD_LOGIC;
         RegWriteW : in STD_LOGIC;
         MemtoRegE : in STD_LOGIC;
         MemtoRegM : in STD_LOGIC;
         MemWriteE : in STD_LOGIC;
         BranchD : in STD_LOGIC;
         R1E : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R2E : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R3E : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R1D : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R2D : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R3D : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R1M : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         R1W : in STD_LOGIC_VECTOR (sizeA-1 DOWNTO 0);
         StallF : out STD_LOGIC;
         StallD : out STD_LOGIC;
         FlushE : out STD_LOGIC;
         ForwardAE: out STD_LOGIC_VECTOR (1 DOWNTO 0);
         ForwardBE : out STD_LOGIC_VECTOR (1 DOWNTO 0);
         ForwardD1,ForwardD2 : out STD_LOGIC;
         ForwardSW : out STD_LOGIC_VECTOR (1 DOWNTO 0));
end HazardUnit;

architecture Behavioral of HazardUnit is

signal loadStall : STD_LOGIC;
signal branchStall : STD_LOGIC;

begin

    process (reset, R1E, R2D, R3D, MemtoRegE, BranchD, RegWriteE, R1D, R1M,MemtoRegM)
    begin
        if (reset = '1') then
            loadStall <= '0';
            branchStall <= '0';
        else
            if (((R1E = R2D) OR (R1E = R3D)) AND (MemtoRegE = '1')) then
                loadStall <= '1';
            else
                loadStall <= '0';
            end if;
            
            if (BranchD = '1') then
                if (RegWriteE = '1') AND (R1E = R1D) then
                    branchStall <= '1';
                elsif (MemtoRegM = '1') AND (R1M = R1D) then 
                    branchStall <= '1';
                --if the register i use in branch (R2) was written in in prev instr
                elsif (RegWriteE ='1') and (R1E =R2D) then
                    branchStall <= '1';
                --if the register i use in branch (R2) was written in in instr before the last
                elsif (MemtoRegM ='1') and (R1M =R2D) then
                    branchStall <= '1';
                else
                    branchStall <= '0';
                end if;
            else
                branchStall <= '0';
            end if;
        end if;
        
    end process;
                        
    StallF <= loadStall OR branchStall;
    StallD <= loadStall OR branchStall;
    FlushE <= loadStall OR branchStall;
    
    process (reset, R2E, R1M, RegWriteM, RegWriteW, R1W, R3E, R1D, R1E, MemWriteE, loadStall, branchStall)
    begin
        if (reset = '1') then
            ForwardAE <= "00"; 
            ForwardBE <= "00"; 
            ForwardD1 <= '0';
            ForwardD2 <= '0';
            ForwardSW <= "00";
            
        else
                --R1E (the register i want to store the value it contains) 
                -- = R1M is the destination register of the last instruction
                -- = R1W is the destination register of the instruction before the last
            if ((R1E /= "00000") AND (R1E = R1M) AND (MemWriteE = '1') AND (RegWriteM = '1')) then
                ForwardSW <= "10"; --aluOut
            elsif ((R1E /= "00000") AND (R1E = R1W) AND (MemWriteE = '1') AND (RegWriteW = '1')) then 
                ForwardSW <= "01"; --writeback result
            else
                ForwardSW <= "00"; --dataR1
            end if;
            
            if ((R2E /= "00000") AND (R2E = R1M) AND (RegWriteM = '1')) then
                ForwardAE <= "10";
            elsif ((R2E /= "00000") AND (R2E = R1W) AND (RegWriteW = '1')) then
                ForwardAE <= "01";
            else 
                ForwardAE <= "00";
            end if;
            
            if ((R3E /= "00000") AND (R3E = R1M) AND (RegWriteM = '1')) then
                ForwardBE <= "10";
            elsif ((R3E /= "00000") AND (R3E = R1W) AND (RegWriteW = '1')) then
                ForwardBE <= "01";
            else 
                ForwardBE <= "00";
            end if;
            
            if ((R1D /= "00000") AND (R1D = R1M) AND (RegWriteM = '1')) then
                ForwardD1 <= '1';
            else
                ForwardD1 <= '0';
            end if;
            if ((R2D /= "00000") AND (R2D = R1M) AND (RegWriteM = '1')) then
                ForwardD2 <= '1';
            else
                ForwardD2 <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
