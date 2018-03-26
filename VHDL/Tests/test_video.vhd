----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:52:45 02/14/2018 
-- Design Name: 
-- Module Name:    test_video - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_video is
      port (
-- Regular signals
       clk50 : in  std_logic; -- 50 MHz board clock
       reset : in  std_logic;
-- VGA signals
      hsync : out std_logic;
      vsync : out std_logic;
      
      vga_r : out std_logic;
      vga_g : out std_logic;
      vga_b : out std_logic);
end test_video;

architecture Behavioral of test_video is
   -- 2.0,10,10,FALSE = 65 MHz
   -- 2.0,2,2,TRUE    = 25 MHz
	component clock_ctrl is
      generic(
      CLKDV_DIVIDE      : real    := 2.0;    -- Can be  1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 9, 10, 11, 12, 13, 14, 15, 16
      CLKFX_DIVIDE      : integer := 10;     -- Can be any integer from 1 to 32
      CLKFX_MULTIPLY    : integer := 13;     -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2 : boolean := FALSE); -- TRUE/FALSE to enable CLKIN divide by two feature
      port (
          clk_in : in  std_logic;
         clk_out : out std_logic);
	end component;
   
   component memory is
         port (
            clk : in    std_logic;
           -- data : inout std_logic_vector(7 downto 0);
         dataIN : in  std_logic_vector(7 downto 0);
        dataOUT : out std_logic_vector(7 downto 0);
        address : in    std_logic_vector(15 downto 0);
   -- Control Bus
         MEMR_L : in    std_logic; -- '0' signals memory device to write to data bus
         MEMW_L : in    std_logic; -- '0' signals memory device to read from data bus
   -- Control Signals
         READY  : out   std_logic; -- '0' signals CPU that memory device needs more time
   -- Video read
   addressVideo : in    std_logic_vector(15 downto 0);
      dataVideo : out   std_logic_vector(7 downto 0));
   end component;
   
   component Video is
         port (
            clk : in std_logic;
   -- Video memory
   addressVideo : out std_logic_vector(15 downto 0);
      dataVideo : in std_logic_vector(7 downto 0);
   -- VGA timer (subset)
        blank   : in  std_logic;
        hstart  : in std_logic;
        vga_row : in integer range 0 to 805;  -- 525 vertical lines (480 + 10 + 2 + 33 = 525)
   -- VGA output
          vga_r : out std_logic;
          vga_g : out std_logic;
          vga_b : out std_logic);
   end component;
   
   component VGA_Timer is
      port ( clk, reset : in  std_logic; -- Expects clock frequency of 25 MHz (ideal would be 25.175 MHz)
             hsync, vsync, blank : out  std_logic;
             hstart  : out std_logic;
             vga_row : out integer range 0 to 805); -- 525 vertical lines (480 + 10 + 2 + 33 = 525)
   end component;
   
   signal clk : std_logic;
   signal addressVideo : std_logic_vector(15 downto 0);
   signal dataVideo : std_logic_vector(7 downto 0);
   
   -- VGA signals (out)
   -- signal hsync : std_logic; -- connected directly to output
   -- signal vsync : std_logic; -- connected directly to output
   signal blank : std_logic;
   signal hstart : std_logic;
   signal vga_row : integer range 0 to 805;
begin

   CCTL : clock_ctrl port map (
        Clk_in => clk50,
       Clk_out => clk
   );

   INST_MEM : memory port map (
           clk => clk,     -- external
          -- data => open,    -- Not reading data
        dataIN => X"00",
       dataOUT => open,
       address => X"0000", -- Not using normal address
        MEMR_L => '1',     -- Not reading anything
        MEMW_L => '1',     -- Not writing anything
        READY  => open,    -- Don't care if it's ready or not
  addressVideo => addressVideo,
     dataVideo => dataVideo
   );
   
   INST_VIDEO : Video port map (
      clk => clk,
      addressVideo => addressVideo,
      dataVideo => dataVideo,
      blank => blank,
      hstart => hstart,
      vga_row => vga_row,
      vga_r => vga_r,
      vga_g => vga_g,
      vga_b => vga_b
   );
   
   INST_VGA : VGA_Timer port map (
      clk => clk,
      reset => reset,
      hsync => hsync, -- Connected directly to output
      vsync => vsync, -- Connected directly to output
      blank => blank,
      hstart => hstart,
      vga_row => vga_row
   );
   
end Behavioral;

