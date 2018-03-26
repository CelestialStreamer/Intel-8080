----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:    20:37:50 11/22/2013
-- Design Name:
-- Module Name:    Interrupt - Behavioral
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions:
-- Description:    Generate an interrupt when user presses button
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Interrupt is
         port (
         clk : in    std_logic;
       reset : in    std_logic;
      button : in    std_logic; -- External interrupt request from the outside
        data : inout std_logic_vector(7 downto 0);
         INT : out   std_logic; -- interrupt request sent to CPU
      INTA_L : in    std_logic); -- '0' signals this device to put instruction on data bus
end Interrupt;

architecture Behavioral of Interrupt is
   type STATE is (Idle, Ask, Give);
   signal cur, nxt : STATE;
   
   signal buttonReg : std_logic;
   
   signal humanWantsInterrupt : boolean;
begin

   process(clk)
   begin
      if rising_edge(clk) then
         buttonReg <= button;
      end if;
   end process;
   humanWantsInterrupt <= (buttonReg = '0') and (button = '1'); -- like rising edge

   process(clk, reset)
   begin
      if reset = '1' then
         cur <= Idle;
      elsif rising_edge(clk) then
         cur <= nxt;
      end if;
   end process;
   
   data <= "11" & "110" & "111" when INTA_L = '0' else (data'range=>'Z');
   
   process(INTA_L, cur, humanWantsInterrupt)
   begin
      INT <= '0';
      
      case cur is
         when Idle =>
            if humanWantsInterrupt then nxt <= Ask;
            else                        nxt <= Idle;
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