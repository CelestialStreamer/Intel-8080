--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:04:23 01/28/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/LCDBenchTest.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LCDBenchmark
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
 
ENTITY LCDBenchTest IS
END LCDBenchTest;
 
ARCHITECTURE behavior OF LCDBenchTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LCDBenchmark
    PORT(
         clk50 : IN  std_logic;
         reset : IN  std_logic;
         sf_ce0 : OUT  std_logic;
         lcd_e : OUT  std_logic;
         lcd_rs : OUT  std_logic;
         lcd_rw : OUT  std_logic;
         lcd_dat : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk50 : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal sf_ce0 : std_logic;
   signal lcd_e : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_dat : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk50_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LCDBenchmark PORT MAP (
          clk50 => clk50,
          reset => reset,
          sf_ce0 => sf_ce0,
          lcd_e => lcd_e,
          lcd_rs => lcd_rs,
          lcd_rw => lcd_rw,
          lcd_dat => lcd_dat
        );

   -- Clock process definitions
   clk50_process :process
   begin
		clk50 <= '0';
		wait for clk50_period/2;
		clk50 <= '1';
		wait for clk50_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk50_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
