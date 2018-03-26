----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:    20:37:50 11/22/2013
-- Design Name:
-- Module Name:    VideoInterrupt - Behavioral
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions:
-- Description:    Generate an interrupt at middle and bottom of screen
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VideoInterrupt is
         port (
         clk : in  std_logic;
       reset : in  std_logic;
     vga_row : in  integer range 0 to 805; -- 805 for 65MHz and 524 for 25MHz
      hstart : in  std_logic; -- single pulse that preceeds row drawing
     dataOUT : out std_logic_vector(7 downto 0);
         INT : out std_logic; -- interrupt request sent to CPU
      INTA_L : in  std_logic); -- '0' signals this device to put instruction on data bus
end VideoInterrupt;

architecture Behavioral of VideoInterrupt is
   type STATE is (Idle, Ask, Give);
   signal cur, nxt : STATE;
   
   -- signal buttonReg : std_logic;
   
   -- signal humanWantsInterrupt : boolean;
   
   constant RST8 : std_logic_vector := X"CF";  -- @ line 96  (I'm going with exactly halfway)
   constant RST10 : std_logic_vector := X"D7"; -- @ line 224 (Just the bottom)
   
   type INTERRUPT is (Line96, Line224);
   signal IntCur, IntNxt : INTERRUPT;
   
   signal genInterrupt : boolean;
   signal dataBus : std_logic_vector(7 downto 0);
begin

   -- Interrupt State register
   process(clk, reset)
   begin
      if reset='1' then
         IntCur <= Line96;
      elsif rising_edge(clk) then
         IntCur <= IntNxt;
      end if;
   end process;
   
   -- Interrupt State next state decoder
   process(hstart, IntCur, vga_row)
   begin
      genInterrupt <= false;
      IntNxt <= IntCur;
      
      if hstart = '1' then
         case IntCur is
            when Line96 =>
               if vga_row = 768 then IntNxt <= Line224; genInterrupt <= true;
               else                  IntNxt <= Line96;
               end if;
            when Line224 =>
               if vga_row = 768/2 then IntNxt <= Line96; genInterrupt <= true;
               else                    IntNxt <= Line224;
               end if;
         end case;
      end if;
   end process;
   
   process(clk)
   begin
      if rising_edge(clk) then
         case IntCur is
            when Line96 =>
               dataBus <= RST8;
            when Line224 =>
               dataBus <= RST10;
         end case;
      end if;
   end process;
   
   -- dataOUT <= dataBus when INTA_L = '0' else (dataOUT'range=>'Z');
   dataOUT <= dataBus;
   
   -- State register
   process(clk, reset)
   begin
      if reset = '1' then
         cur <= Idle;
      elsif rising_edge(clk) then
         cur <= nxt;
      end if;
   end process;
   
   -- Next state decoder
   process(INTA_L, cur, genInterrupt)
   begin
      INT <= '0';
      
      case cur is
         when Idle =>
            if genInterrupt then nxt <= Ask;
            else                 nxt <= Idle;
            end if;
         when Ask =>
            INT <= '1';
            if INTA_L = '0' then nxt <= Give;
            else                 nxt <= Ask;
            end if;
         when Give =>
            nxt <= Idle;
      end case;
   end process;

end Behavioral;