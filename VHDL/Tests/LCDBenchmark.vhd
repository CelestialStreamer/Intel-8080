----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:20:44 01/28/2018 
-- Design Name: 
-- Module Name:    LCDBenchmark - Behavioral 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

entity LCDBenchmark is
      port (
-- Regular signals
       clk50 : in  std_logic; -- 50 MHz board clock
       reset : in  std_logic;
-- LCD signals
     sf_ce0  : out std_logic; -- Use pin D16
     lcd_e   : out std_logic; -- Use pin M18
     lcd_rs  : out std_logic; -- Use pin L18
     lcd_rw  : out std_logic;-- Use pin L17
     lcd_dat : out std_logic_vector(3 downto 0)); -- Use pin (M15,P17,R16,R15) => (3,2,1,0)
end LCDBenchmark;

architecture Behavioral of LCDBenchmark is
	component clock_ctrl is
      port (
          clk_in : in  std_logic;
         clk_out : out std_logic);
	end component;
   
   component LCD_IO is
         port (
            clk : in  std_logic;
          reset : in  std_logic;
          ascii : in  std_logic_vector(7 downto 0);
        address : in  std_logic_vector(15 downto 0);
   -- Control Bus
        IOW_L   : in  std_logic; -- '0' signals I/O device to read from data bus
   -- Wait
           hold : out std_logic; -- Hold the CPU while communicating with LCD unit
   -- LCD signals
        sf_ce0  : out std_logic; -- Use pin D16
        lcd_e   : out std_logic; -- Use pin M18
        lcd_rs  : out std_logic; -- Use pin L18
        lcd_rw  : out std_logic; -- Use pin L17
        lcd_dat : out std_logic_vector(3 downto 0)); -- Use pin (M15,P17,R16,R15) => (3,2,1,0)
   end component;
   
   signal nxt, cur : integer range 1 to 20;
   signal clk : std_logic; -- 2 MHz clock
   
   -- CPU busses
   signal address : std_logic_vector(15 downto 0);
   signal data : std_logic_vector(7 downto 0);
   
   -- Control Bus
   signal IOW_L : std_logic;
   signal HOLD : std_logic;
   constant Message1 : String(1 to 12) := "Hello World!";
begin

   CCTL : clock_ctrl port map (
        Clk_in => clk50,
       Clk_out => clk
   );
   
   INST_LCD : LCD_IO port map (
            clk => clk,    -- external
          reset => reset,  -- external
          ascii => data,
        address => address,
          IOW_L => IOW_L,
           hold => HOLD,
         sf_ce0 => sf_ce0, -- external
          lcd_e => lcd_e,  -- external
         lcd_rs => lcd_rs, -- external
         lcd_rw => lcd_rw, -- external
        lcd_dat => lcd_dat -- external
   );
   
   STATE_REGISTER:
   process(clk, reset)
   begin
      if reset='1' then
         cur <= 1;
      elsif rising_edge(clk) then
         cur <= nxt;
      end if;
   end process;
   
   NEXT_STATE_DECODER:
   process(HOLD, cur)
   begin
      address <= (address'range=>'Z');
      data <= (data'range=>'Z');
      IOW_L <= '1';
      
      if HOLD = '1' then
         nxt <= cur;
      elsif cur /= 13 then
         nxt <= cur + 1;
            
         address <= (address'range=>'0');
         data <= std_logic_vector(
                  to_unsigned(
                   character'pos( Message1(cur) ),
                   data'length
                  )
                 );
         IOW_L <= '0';
      else
         nxt <= cur;
      end if;
   end process;

end Behavioral;

