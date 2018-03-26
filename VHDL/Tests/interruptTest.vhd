--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:26:38 02/05/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/interruptTest.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Interrupt
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
--use ieee.numeric_std.all;
 
entity interruptTest is
end interruptTest;
 
architecture behavior of interruptTest is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component Interrupt
    port(
         clk : in  std_logic;
         reset : in  std_logic;
         button : in  std_logic;
         data : inout  std_logic_vector(7 downto 0);
         INT : out  std_logic;
         INTA_L : in  std_logic
        );
    end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal button : std_logic := '0';
   signal INTA_L : std_logic := '1';

	--BiDirs
   signal data : std_logic_vector(7 downto 0);

 	--Outputs
   signal INT : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Interrupt port map (
          clk => clk,
          reset => reset,
          button => button,
          data => data,
          INT => INT,
          INTA_L => INTA_L
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
      wait for clk_period*3;
      reset <= '0';
      wait for clk_period*2;

      -- insert stimulus here 
      
      button <= '1';
      
      wait for clk_period*8;
      
      INTA_L <= '0';
      wait for clk_period;
      INTA_L <= '1';

      wait;
   end process;

end;
