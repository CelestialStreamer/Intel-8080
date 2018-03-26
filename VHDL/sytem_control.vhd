----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:
-- Design Name:    Space Invaders system
-- Module Name:    System_Control - Behavioral
-- Project Name:   Space Invaders
-- Target Devices: 
-- Description:    This generates the control bus signals that control INPUTut and
--                 output of memory, I/O, and interrupt devices. The control signals
--                 are derived from CPU status information and CPU control signals.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity System_Control is
      port (
      WR     : in  std_logic;
      DBIN   : in  std_logic;
      HLDA   : in  std_logic; -- Unused
      -- Status Information
      INTA   : in  std_logic;
      WO     : in  std_logic; -- Unused
      STACK  : in  std_logic; -- Unused
      HLTA   : in  std_logic; -- Unused
      OUTPUT : in  std_logic;
      M_1    : in  std_logic; -- Unused
      INPUT  : in  std_logic;
      MEMR   : in  std_logic;
-- Control Bus
      -- Interrupt
      INTA_L : out std_logic; -- '0' signals interrupt device to put instruction on data bus
      -- Read
      MEMR_L : out std_logic; -- '0' signals memory device to write to data bus
      IOR_L  : out std_logic; -- '0' signals I/O    device to write to data bus
      -- Write
      MEMW_L : out std_logic; -- '0' signals memory device to read from data bus
      IOW_L  : out std_logic);-- '0' signals I/O    device to read from data bus
end System_Control;

architecture Behavioral of System_Control is

begin
   -- Interrupt
   INTA_L <= not ( INTA and DBIN);
   -- Read
   IOR_L  <= not (INPUT and DBIN);
   MEMR_L <= not ( MEMR and DBIN);
   -- Write
   IOW_L  <= not (    OUTPUT and not WR); -- '0' only if OUTPUT='1' and WR='0'
   MEMW_L <= not (not OUTPUT and not WR); -- '0' only if OUTPUT='0' and WR='0'
end Behavioral;