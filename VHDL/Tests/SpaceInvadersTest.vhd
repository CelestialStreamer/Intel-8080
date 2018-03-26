--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:30:06 02/15/2018
-- Design Name:   
-- Module Name:   D:/XilinxISE/8080/Intel8080/SpaceInvadersTest.vhd
-- Project Name:  Intel8080
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SpaceInvaders
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
library std;
use std.env.all; -- This can only be used in simulation

---------------------- Section 1 Cut Here -----------------------------------------\
use ieee.numeric_std.all;      -- this is commented out by default but we need it.
use ieee.std_logic_textio.all; -- for some file reading functions
use std.textio.all;            -- for other file reading functions
---------------------- Section 1 Cut Here -----------------------------------------/
 
entity SpaceInvadersTest is
end SpaceInvadersTest;
 
architecture behavior of SpaceInvadersTest is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component Spaceinvaders
    port(
--- Regular signals
         clk50 : in  std_logic;
         reset : in  std_logic;
-- Player input
        credit : in  std_logic;
      P1_start : in  std_logic;
       P1_left : in  std_logic;
      P1_right : in  std_logic;
       P1_shot : in  std_logic;
-- VGA signals
         hsync : out std_logic;
         vsync : out std_logic;

         vga_r : out std_logic;
         vga_g : out std_logic;
         vga_b : out std_logic;
-- LED signals
       dataLED : out std_logic_vector(7 downto 0);
-- Debug
          addr : out std_logic_vector(15 downto 0);
          data : out std_logic_vector(7 downto 0);
       newData : out std_logic
        );
    end component;
    

   --inputs
   signal clk50 : std_logic := '0';
   signal reset : std_logic := '0';
   
   signal credit   : std_logic := '0';
   signal P1_start : std_logic := '0';
   signal P1_left  : std_logic := '0';
   signal P1_right : std_logic := '0';
   signal P1_shot  : std_logic := '0';

 	--outputs
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal vga_r : std_logic;
   signal vga_g : std_logic;
   signal vga_b : std_logic;
   signal dataLED : std_logic_vector(7 downto 0);
   
   signal addr : std_logic_vector(15 downto 0);
   signal data : std_logic_vector(7 downto 0);
   signal newData : std_logic;

   -- Clock period definitions
   constant clk50_period : time := 20 ns;
   
   type test_data_holder is
      record
         addr : std_logic_vector(15 downto 0);
         data : std_logic_vector(7 downto 0);
         
         count : integer range 0 to 50000; -- counts tests performed
         wrong_cout : integer range 0 to 50000; -- counts total errors
         wrong_indicator : string(1 to 2); -- indicates a test error (current)
      end record;
   
   type comments is
      record
         content : string (200 downto 1);
         len : integer range 0 to 200;
      end record;
   
   type files is
      record
         out_line : line; -- handle for current line in file
         in_line  : line; -- handle for current line in file
         line_number : integer range 1 to 50000; -- current line No.
         alignment : side; -- field alignment
         bad : boolean;    -- read failure feedback holder
      end record;
   
   shared variable test : test_data_holder; -- actual variable for the record above
   shared variable comment : comments;
   shared variable f : files;
   file f_out : text;
   file f_in  : text;
   
   shared variable Done: boolean := false;
   
   signal startOfNewInst : boolean := false;
   
   shared variable lastState : std_logic := '0';
begin
 
	-- instantiate the Unit Under Test (UUT)
   uut: Spaceinvaders port map (
          clk50 => clk50,
          reset => reset,
          
         credit => credit,
       P1_start => P1_start,
        P1_shot => P1_shot,
        P1_left => P1_left,
       P1_right => P1_right,
          
          hsync => hsync,
          vsync => vsync,
          
          vga_r => vga_r,
          vga_g => vga_g,
          vga_b => vga_b,
          
          dataLED => dataLED,
          addr => addr,
          data => data,
          newData => newData
        );

   -- Clock process definitions
   clk50_process :process
   begin
		clk50 <= '0'; wait for clk50_period/2;
		clk50 <= '1'; wait for clk50_period/2;
   end process;
 

   process(clk50)
   begin
      if rising_edge(clk50) then
         if lastState = '0' and newData = '1' then
            startOfNewInst <= true;
         else
            startOfNewInst <= false;
         end if;
         lastState := newData;
      end if;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin
      -- Reset PC
      reset <= '1';
      wait for 500 ns;
      reset <= '0';
      
      -- initialize variables
      test.count := 0;
      f.line_number := 1;
      f.alignment  := left;
      
      -- open input and output files
      file_open(f_in, "space_invade_uptoEI.txt", read_mode);
      file_open(f_out, "test_results.txt", write_mode);
      
      --                "0000 00  0000 00"
      write(f.out_line, "Expected Actual");
      writeline(f_out, f.out_line);
      
      -- loop through each test
      while not endfile(f_in) loop
         f.line_number := f.line_number + 1;
         readline (f_in, f.in_line);
         if (f.in_line'length = 0) then   -- when line is blank
            writeline(f_out, f.out_line); -- copy the blank line to the output file
            next;                         -- then skip the current line/loop/test
         end if;
         test.count := test.count + 1;
         
         -- Outputs
         hread (f.in_line, test.addr, f.bad); assert f.bad report "Text addr read error on line " & integer'image(f.line_number) & " of input file." severity ERROR;
         hread (f.in_line, test.data, f.bad); assert f.bad report "Text data read error on line " & integer'image(f.line_number) & " of input file." severity ERROR;
         
         Comment.len := f.in_line'length;
         read (f.in_line, Comment.content(Comment.len downto 1), f.bad); assert f.bad report "Text I/O read error of Comments field on line " &integer'image(f.line_number)&" of input file." severity ERROR;
         
         wait until startOfNewInst;
         
         if std_match(test.addr, addr) then test.wrong_indicator(1) := '-'; else test.wrong_indicator(1) := '!'; end if;
         if std_match(test.data, data) then test.wrong_indicator(2) := '-'; else test.wrong_indicator(2) := '!'; end if;
         
         
         
         hwrite(f.out_line, test.addr, f.alignment, 4 + 1); -- Expected
         hwrite(f.out_line, test.data, f.alignment, 2 + 1);
         hwrite(f.out_line,      addr, f.alignment, 4 + 1); -- Actual
         hwrite(f.out_line,      data, f.alignment, 2 + 1);
         write(f.out_line, test.wrong_indicator, f.alignment, test.wrong_indicator'length);
         write(f.out_line, Comment.content(Comment.len downto 1), f.alignment, Comment.len);
         writeline(f_out, f.out_line);
         
         report "Test # " & integer'image(test.count) & " done." severity NOTE;
         
      end loop;
      
      file_close(f_in);
      file_close(f_out);
      
      finish(0);
      
      wait;
   end process;

end;
