--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:02:15 01/12/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/SystemTest.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SystemTest IS
END SystemTest;
 
ARCHITECTURE behavior OF SystemTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT system
    PORT(
         clk50 : IN  std_logic;
         intBtn : IN std_logic;
         reset : IN  std_logic;
         sf_ce0 : OUT  std_logic;
         lcd_e : OUT  std_logic;
         lcd_rs : OUT  std_logic;
         lcd_rw : OUT  std_logic;
         lcd_dat : OUT  std_logic_vector(3 downto 0);
         dataLED : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal intBtn : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal sf_ce0 : std_logic;
   signal lcd_e : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_dat : std_logic_vector(3 downto 0);
   signal dataLED : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns; -- 50 MHz external clock
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: system PORT MAP (
          clk50 => clk,
          intBtn => intBtn,
          reset => reset,
          sf_ce0 => sf_ce0,
          lcd_e => lcd_e,
          lcd_rs => lcd_rs,
          lcd_rw => lcd_rw,
          lcd_dat => lcd_dat,
          dataLED => dataLED
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
      reset <= '1'; wait for 5 * clk_period; reset <= '0';
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
      
      wait for 25 ms;
      intBtn <= '1';

      wait;
   end process;

END;
