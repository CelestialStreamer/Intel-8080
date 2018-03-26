----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:    20:37:50 11/22/2013
-- Design Name:
-- Module Name:    INP1 - Behavioral
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions:
-- Description:    The input and output devices for the Space Invaders system.
--                 There are 3 input and 5 output devices that are accessed by
--                 the space invaders program.
--
--                 CPU accesses device with ADDRESS and IOR_L=0 or IOW_L=0.
--                 Each device has its own unique address.
--
--                 Input devices:
--                   INP0: address=0x00 (Unimplemented. Not used by code in Space Invaders)
--                   INP1: address=0x01
--                      bit 0 = CREDIT   (1 if deposit)
--                      bit 1 = P2 start (1 if pressed)
--                      bit 2 = P1 start (1 if pressed)
--                      bit 3 = Always 1
--                      bit 4 = P1 shot  (1 if pressed)
--                      bit 5 = P1 left  (1 if pressed)
--                      bit 6 = P1 right (1 if pressed)
--                      bit 7 = Not connected (returns 0)
--                   INP2: address=0x02
--                      bit 0 = DIP3 00 = 3 ships  10 = 5 ships
--                      bit 1 = DIP5 01 = 4 ships  11 = 6 ships
--                      bit 2 = Tilt
--                      bit 3 = DIP6 0 = extra ship at 1500, 1 = extra ship at 1000
--                      bit 4 = P2 shot (1 if pressed)
--                      bit 5 = P2 left (1 if pressed)
--                      bit 6 = P2 right (1 if pressed)
--                      bit 7 = DIP7 Coin info displayed in demo screen 0=ON
--                   SHIFT_IN: address=0x03
--                      bit 0-7 = Shift register data
--                 Output devices:
--                   SHIFTAMNT: address=0x02
--                      bit 0,1,2 = shift amount
--                   SOUND1: address=0x03 (Not implemented at this time)
--                      bit 0=UFO (repeats)        SX0 0.raw
--                      bit 1=Shot                 SX1 1.raw
--                      bit 2=Flash (player die)   SX2 2.raw
--                      bit 3=Invader die          SX3 3.raw
--                      bit 4=Extended play        SX4
--                      bit 5=AMP enable           SX5
--                      bit 6,7=NC (not wired)
--                   SHIFT_DATA: address=0x04
--                      bit 0-7 shift data (LSB on 1st write, MSB on 2nd)
--                   SOUND2: address=0x05 (Not implemented at this time)
--                      bit 0=Fleet movement 1     SX6 4.raw
--                      bit 1=Fleet movement 2     SX7 5.raw
--                      bit 2=Fleet movement 3     SX8 6.raw
--                      bit 3=Fleet movement 4     SX9 7.raw
--                      bit 4=UFO Hit              SX10 8.raw
--                      bit 5= NC (Cocktail mode control ... to flip screen)
--                      bit 6,7= NC (not wired)
--                   WATCHDOG: address=0x06
--                      Watchdog ... read or write to reset (Not implemented at this time)
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IO is
         port (
         clk : in  std_logic;
       reset : in  std_logic;
      dataIN : in  std_logic_vector(7 downto 0);
     dataOUT : out std_logic_vector(7 downto 0);
     address : in  std_logic_vector(7 downto 0); -- Using only half of the address here, which half doesn't matter
-- Control Bus
     IOR_L   : in  std_logic; -- '0' signals I/O device to write to data bus
     IOW_L   : in  std_logic; -- '0' signals I/O device to read from data bus
-- Signals
   -- INP1
   credit    : in  std_logic; -- '1' if deposit
   P2_start  : in  std_logic; -- '1' if pressed
   P1_start  : in  std_logic; -- '1' if pressed
   P1_shot   : in  std_logic; -- '1' if pressed
   P1_left   : in  std_logic; -- '1' if pressed
   P1_right  : in  std_logic; -- '1' if pressed

   -- INP2
   Ships     : in  std_logic_vector(1 downto 0); -- (0,1,2,3) -> (3,4,5,6) ships
   Tilt      : in  std_logic;
   ExtraShip : in  std_logic; -- '0' = extra ship at 1500, '1' = extra ship at 1000
   P2_shot   : in  std_logic; -- '1' if pressed
   P2_left   : in  std_logic; -- '1' if pressed
   P2_right  : in  std_logic; -- '1' if pressed
   CoinInfo  : in  std_logic;-- '0' = ON

   -- INP3 writes shift register data
-- Debug
   INP1      : out std_logic_vector(7 downto 0));
end IO;

architecture Behavioral of IO is
   constant CLK_F : integer := 2; -- Clock frequency is 2MHz

   constant ADDRESS_INP1       : std_logic_vector(7 downto 0) := "00000001"; -- 1
   constant ADDRESS_INP2       : std_logic_vector(7 downto 0) := "00000010"; -- 2
   constant ADDRESS_SHIFT_IN   : std_logic_vector(7 downto 0) := "00000011"; -- 3

   constant ADDRESS_SHIFTAMNT  : std_logic_vector(7 downto 0) := "00000010"; -- 2
   constant ADDRESS_SOUND1     : std_logic_vector(7 downto 0) := "00000011"; -- 3
   constant ADDRESS_SHIFT_DATA : std_logic_vector(7 downto 0) := "00000100"; -- 4
   constant ADDRESS_SOUND2     : std_logic_vector(7 downto 0) := "00000101"; -- 5
   constant ADDRESS_WATCHDOG   : std_logic_vector(7 downto 0) := "00000101"; -- 6
   
   signal dataBus : std_logic_vector(7 downto 0);

   signal shift_amnt : std_logic_vector(2 downto 0);
   signal shift_reg : std_logic_vector(15 downto 0);
   signal shiftRes : std_logic_vector(7 downto 0);
begin
   -- data <= dataBus when IOR_L = '0' else (data'range=>'Z');
   dataOUT <= dataBus;
   INP1 <= '0' & P1_right & P1_left & P1_shot & '1' & P1_start & P2_start & credit;
   
   process(shift_amnt, shift_reg)
   begin
      case to_integer(unsigned(shift_amnt)) is
         when 0 => shiftRes <= shift_reg((15-0) downto (8-0));
         when 1 => shiftRes <= shift_reg((15-1) downto (8-1));
         when 2 => shiftRes <= shift_reg((15-2) downto (8-2));
         when 3 => shiftRes <= shift_reg((15-3) downto (8-3));
         when 4 => shiftRes <= shift_reg((15-4) downto (8-4));
         when 5 => shiftRes <= shift_reg((15-5) downto (8-5));
         when 6 => shiftRes <= shift_reg((15-6) downto (8-6));
         when others => shiftRes <= shift_reg((15-7) downto (8-7));
      end case;
   end process;
   
   INP:
   process(clk)
      -- variable shiftRes : std_logic_vector(15 downto 0);
   begin
      if rising_edge(clk) then
         case address is
            when ADDRESS_INP1 =>
               dataBus <= '0' & P1_right & P1_left & P1_shot & '1' & P1_start & P2_start & credit;
            when ADDRESS_INP2 =>
               dataBus <= CoinInfo & P2_right & P2_left & P2_shot & ExtraShip & tilt & ships;
            when ADDRESS_SHIFT_IN =>
               -- shiftRes := std_logic_vector(shift_left(unsigned(shift_reg), to_integer(unsigned(shift_amnt))));
               -- dataBus <= shiftRes(7 downto 0);
               dataBus <= shiftRes;
            when others =>
               dataBus <= (dataBus'range=>'0'); -- Doesn't really matter what this is
         end case;
      end if;
   end process;

   SHIFTAMNT:
   process(clk, reset )
   begin
      if reset = '1' then
         shift_amnt <= (shift_amnt'range=>'0');
      elsif rising_edge(clk) then
         if (address = ADDRESS_SHIFTAMNT) and (IOW_L = '0') then
            shift_amnt <= dataIN(2 downto 0);
         end if;
      end if;
   end process;
   SOUND1:
   process(clk)
   begin
      if rising_edge(clk) then
         if (address = ADDRESS_SOUND1) and (IOW_L = '0') then
            -- bit 0=UFO (repeats)        SX0 0.raw
            -- bit 1=Shot                 SX1 1.raw
            -- bit 2=Flash (player die)   SX2 2.raw
            -- bit 3=Invader die          SX3 3.raw
            -- bit 4=Extended play        SX4
            -- bit 5=AMP enable           SX5
            -- bit 6=NC (not wired)
            -- bit 7=NC (not wired)
         end if;
      end if;
   end process;
   SHIFT_DATA:
   process(clk, reset)
   begin
      if reset = '1' then
         shift_reg <= (shift_reg'range=>'0');
      elsif rising_edge(clk) then
         if (address = ADDRESS_SHIFT_DATA) and (IOW_L = '0') then
            shift_reg <= dataIN & shift_reg(15 downto 8);
         end if;
      end if;
   end process;
   SOUND2:
   process(clk)
   begin
      if rising_edge(clk) then
         if (address = ADDRESS_SOUND2) and (IOW_L = '0') then
            -- bit 0=Fleet movement 1     SX6 4.raw
            -- bit 1=Fleet movement 2     SX7 5.raw
            -- bit 2=Fleet movement 3     SX8 6.raw
            -- bit 3=Fleet movement 4     SX9 7.raw
            -- bit 4=UFO Hit              SX10 8.raw
            -- bit 5= NC (Cocktail mode control ... to flip screen)
            -- bit 6= NC (not wired)
            -- bit 7= NC (not wired)
         end if;
      end if;
   end process;
   WATCHDOG:
   process(clk)
   begin
      if rising_edge(clk) then
         if (address = ADDRESS_WATCHDOG) and ((IOR_L = '0') or (IOW_L = '0')) then
            -- reset timer. What timer?
         end if;
      end if;
   end process;

end Behavioral;