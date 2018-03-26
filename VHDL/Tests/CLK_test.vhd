library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLK_test is
      port (
       clk50 : in  std_logic; -- 50 MHz board clock
       reset : in  std_logic;
         led : out std_logic); -- Should blink at 50 MHz / 16 / 2^24 = 0.18 Hz
end CLK_test;

architecture Behavioral of CLK_test is
	component clock_ctrl is
      port (clk_in : in  std_logic;
           clk_out : out std_logic);
	end component;
   
   signal clk : std_logic; -- 3.125 MHz clock
   signal counter : integer range 0 to 2**24 - 1; -- Divide 3.125 MHz clock down to 0.18 Hz
   signal led_reg : std_logic;
   
begin
   -- 
   CCTL : clock_ctrl port map (
        Clk_in => clk50, Clk_out => clk
   );
   
   -- 50% duty cycle led_reg
   process(clk, counter)
   begin
      if rising_edge(clk) then
         if counter = 0 then
            led_reg <= '0';
         elsif counter = 2**23 - 1 then
            led_reg <= '1';
         end if;
      end if;
   end process;
   led <= led_reg;
   
   --
   process(clk, reset)
   begin
      if reset = '1' then
         counter <= 0;
      elsif rising_edge(clk) then
         counter <= counter + 1;
      end if;
   end process;
end Behavioral;

