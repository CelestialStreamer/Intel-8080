--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:21:26 01/14/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/LCDtest.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LCD_IO
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
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity LCDtest is
end LCDtest;
 
architecture behavior of LCDtest is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component LCD_IO
    port(
         clk : in  std_logic;
         reset : in  std_logic;
         ascii : in  std_logic_vector(7 downto 0);
         address : in  std_logic_vector(15 downto 0);
         IOW_L : in  std_logic;
         hold : out std_logic;
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
   signal ascii : std_logic_vector(7 downto 0) := (others => '0');
   signal address : std_logic_vector(15 downto 0) := (others => '0');
   signal IOW_L : std_logic := '0';

 	--Outputs
   signal hold : std_logic;
   signal sf_ce0 : std_logic;
   signal lcd_e : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_dat : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1000.0 ns / 3.125;
 
--   type RAM_TYPE is array (0 to 2**4-1) of std_logic_vector(7 downto 0);
--   
--   impure function InitRomFromFile (RomFileName : in string) return RAM_TYPE is
--      FILE romfile : text is in RomFileName;
--      variable RomFileLine : line;
--      variable ram : RAM_TYPE;
--   begin
--      for i in RAM_TYPE'range loop
--         exit when endfile(romfile);
--         readline(romfile, RomFileLine);
--         read(RomFileLine, ram(i));
--      end loop;
--      return ram;
--   end function;
--   
--   signal DataMEM : RAM_TYPE := InitRomFromFile("ROM_4bit.txt");
   
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LCD_IO PORT map (
          clk => clk,
          reset => reset,
          ascii => ascii,
          address => address,
          IOW_L => IOW_L,
          hold => hold,
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
      ascii <= (ascii'range=>'0');
      address <= (address'range=>'0');
      IOW_L <= '1';
      
      wait for clk_period;
      
      reset <= '0';
      
      wait for 16 ms;
      wait until clk='0'; 

      IOW_L <= '0';
      
      wait for clk_period;
      
      IOW_L <= '1';

      -- insert stimulus here 

      wait;
   end process;

END;
