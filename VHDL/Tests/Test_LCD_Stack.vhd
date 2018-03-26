--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:43:01 01/22/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/Test_LCD_Stack.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LCD_IO_Stack
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
use ieee.numeric_std.all;
 
entity Test_LCD_Stack is
end Test_LCD_Stack;
 
architecture behavior of Test_LCD_Stack is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component LCD_IO_Stack
    port(
         clk : in  std_logic;
         reset : in  std_logic;
         data : in  std_logic_vector(7 downto 0);
         address : in  std_logic_vector(15 downto 0);
         IOW_L : in  std_logic;
         sf_ce0 : out  std_logic;
         lcd_e : out  std_logic;
         lcd_rs : out  std_logic;
         lcd_rw : out  std_logic;
         lcd_dat : out  std_logic_vector(3 downto 0)
        );
    end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal address : std_logic_vector(15 downto 0) := (others => '0');
   signal IOW_L : std_logic := '1';

 	--Outputs
   signal sf_ce0 : std_logic;
   signal lcd_e : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_dat : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 160 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LCD_IO_Stack port map (
          clk => clk,
          reset => reset,
          data => data,
          address => address,
          IOW_L => IOW_L,
          sf_ce0 => sf_ce0,
          lcd_e => lcd_e,
          lcd_rs => lcd_rs,
          lcd_rw => lcd_rw,
          lcd_dat => lcd_dat
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';
      wait for clk_period*10;
      
      for i in 0 to 7 loop
         data <= std_logic_vector(to_unsigned(i + 65, data'length));
         IOW_L <= '0';
         wait for clk_period;
         data <= (data'range=>'Z');
         IOW_L <= '1';
         wait for clk_period;
      end loop;

      -- insert stimulus here 

      wait;
   end process;

end;
