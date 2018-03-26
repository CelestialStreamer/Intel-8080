----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:    20:37:50 11/22/2013
-- Design Name:
-- Module Name:    Memory - Behavioral
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions:
-- Description:    64K memory for Space Invaders system (16K implemented)
--
--                 Memory is read by CPU when MEMW_L=0.
--                 Value of MEMORY at ADDRESS is written to DATA bus.
--
--                 Memory is written by CPU when MEMR_L=0.
--                 Value of DATA bus is written to MEMORY at ADDRESS.
--
--                 All memory accesses are done in one clock cycle so READY is always 1.
--                 The video unit only reads memory so it is given a second
--                 address/data line. Both can happen simultaneously.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity memory is
         port (
         clk : in  std_logic;
      dataIN : in  std_logic_vector(7 downto 0);
     dataOUT : out std_logic_vector(7 downto 0);
     address : in  std_logic_vector(15 downto 0);
-- Control Bus    
      MEMR_L : in  std_logic; -- '0' signals memory device to write to data bus
      MEMW_L : in  std_logic; -- '0' signals memory device to read from data bus
-- Control Signals
       READY : out std_logic; -- '0' signals CPU that memory device needs more time
-- Video read
addressVideo : in  std_logic_vector(15 downto 0);
   dataVideo : out std_logic_vector(7 downto 0));
end memory;

architecture Behavioral of memory is
   type MEMORY is array (0 to 2**14 - 1) of std_logic_vector(7 downto 0); -- 16K memory
   
   -- This function and the technique is taken from https://forums.xilinx.com/t5/Spartan-Family-FPGAs/Initializing-Block-RAM-with-External-Data-File/td-p/229193
   impure function InitRomFromFile (RomFileName : in string) return MEMORY is
      FILE romfile : text is in RomFileName;
      variable RomFileLine : line;
      variable mem : MEMORY;
   begin
      for i in MEMORY'range loop
         exit when endfile(romfile);
         readline(romfile, RomFileLine);
         read(RomFileLine, mem(i));
      end loop;
      return mem;
   end function;
   
   signal MEM : MEMORY := InitRomFromFile("MEM.txt");
   
   -- signal dataBus : std_logic_vector(7 downto 0);
begin
   READY <= '1'; -- Memory is always ready
   
   -- dataOUT <= dataBus;
   
   CPU_MEM:
   process(clk)
   begin
      if rising_edge(clk) then
         dataVideo <= MEM(to_integer(unsigned( addressVideo(13 downto 0) )));
         -- dataBus <= MEM(to_integer(unsigned( address(13 downto 0) )));
         dataOUT <= MEM(to_integer(unsigned( address(13 downto 0) )));
         
         if MEMW_L = '0' and address(15 downto 13) = "001" then -- Write to memory for addresses [2000-3FFF] inclusive
            MEM(to_integer(unsigned( address(13 downto 0) ))) <= dataIN;
         end if;
      end if;
   end process;
end Behavioral;