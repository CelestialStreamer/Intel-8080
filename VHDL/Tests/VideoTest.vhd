--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:50:35 02/14/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/VideoTest.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: test_video
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
 
ENTITY VideoTest IS
END VideoTest;
 
ARCHITECTURE behavior OF VideoTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT test_video
    PORT(
         clk50 : IN  std_logic;
         reset : IN  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         vga_r : OUT  std_logic;
         vga_g : OUT  std_logic;
         vga_b : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk50 : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal vga_r : std_logic;
   signal vga_g : std_logic;
   signal vga_b : std_logic;

   -- Clock period definitions
   constant clk50_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: test_video PORT MAP (
          clk50 => clk50,
          reset => reset,
          hsync => hsync,
          vsync => vsync,
          vga_r => vga_r,
          vga_g => vga_g,
          vga_b => vga_b
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
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';
      wait for clk50_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
