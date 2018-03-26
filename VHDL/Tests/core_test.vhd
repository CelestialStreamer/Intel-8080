--------------------------------------------------------------------------------
-- Project Name:  core_test
-- Written By: Trescott D. Jensen
-- Create Date:    14:43:34 11/17/2011
-- Notes:
--   Written for the benefit of Fon Brown's EE 3610 Class.
--   You can play with this module to learn more about working with files.
--   If you want to use it for a project of yours, let ISE generate the basic
--   testbench for your project and then follow these steps to modify it.
--      * Step 1: copy and paste the three sections indicated section 3
--                replaces the default test process.
--      * Step 2: in section 2, modify test_data_holder to include all the
--                inputs and outputs as well as all expected results for the
--                outputs. Include any other values to be read/writen to file
--      * Step 3: adjust wrong_indicator to hold as many or few separate
--                indicators as is needed.
--      * Step 4: in section 3, update the header literal string to match
--                the data that you will be writing.
--      * Step 5: replace the read/hread blocks with one for each field of
--                data that will be in your input file, make sure they're
--                in the right order and that you use the right read function
--                for that type of data. Keep the comments copying code.
--                make sure to update the field name in the report text.
--      * Step 6: update the "apply test signals" and the "save results" blocks
--                to work with your signals. **CAREFULL**
--                Mistakes here will be hard to find later!
--      * Step 7: update the "compare results" block using the examples use
--                what works best for your project.
--      * Step 8: update the "Write results" and "flag errors" blocks to match
--                the changes you made. Keep in mind more info is better.
--                Note that the number at the end of the write functions is
--                the fixed size of the field, adjust this to fit your data
--                and include space to separate them.
--                i.e. 2 characters of data gets 3 or 4 not just 2.
--      * Step 9: Write test data for your project, include a header in your file
--      * Step 10: RUN YOUR TEST. And begain the troubleshooting process!
-- Revised by Michael Woodruff. Spelling, tabs and other issues.
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

entity core_test is
end core_test;

architecture behavior of core_test is

   -- Component Declaration for the Unit Under Test (UUT)
   component core
   port (
   -- Regular signals
                     clk : in    std_logic;
                     CE  : in    std_logic;
                   reset : in    std_logic;
                 address : out   std_logic_vector(15 downto 0);
                    data : inout std_logic_vector(7 downto 0);
   -- Status information signals
                    INTA : out   std_logic;
                      WO : out   std_logic;
                   STACK : out   std_logic;
                    HLTA : out   std_logic;
                  OUTPUT : out   std_logic;
                     M_1 : out   std_logic;
                   INPUT : out   std_logic;
                    MEMR : out   std_logic;
   -- External Control signals
                      WR : out   std_logic;
                    DBIN : out   std_logic;
                    INTE : out   std_logic;
                     INT : in    std_logic;
                    HLDA : out   std_logic;
                    HOLD : in    std_logic;
                WAIT_ACK : out   std_logic;
                   READY : in    std_logic;
                    SYNC : out   std_logic;
   -- Register pairs and state (Debug only)
            WZ, PSW, BC, DE, HL, SP, PC : out std_logic_vector(15 downto 0)
         );
   end component;

   -- Inputs
   signal clk      : std_logic := '0';
   signal CE       : std_logic := '1';
   signal reset    : std_logic := '0';

   signal INT      : std_logic := '0';
   signal HOLD     : std_logic := '0';
   signal READY    : std_logic := '0';
   
   -- In/outputs
   signal data     : std_logic_vector(7 downto 0);

   -- Outputs
   signal address  : std_logic_vector(15 downto 0);

   signal INTA     : std_logic;
   signal WO       : std_logic;
   signal STACK    : std_logic;
   signal HLTA     : std_logic;
   signal OUTPUT   : std_logic;
   signal M_1      : std_logic;
   signal INPUT    : std_logic;
   signal MEMR     : std_logic;

   signal WR       : std_logic;
   signal DBIN     : std_logic;
   signal INTE     : std_logic;
   signal HLDA     : std_logic;
   signal WAIT_ACK : std_logic;
   signal SYNC     : std_logic;

   -- Register pairs (debug)
   signal WZ, PSW, BC, DE, HL, SP, PC : std_logic_vector(15 downto 0);
   
   -- Clock period definitions
   constant clk_period : time := 1 ns;

   ------------------- Section 2 Cut Here -----------------------------------------\
   -- testbench types
   type test_data_holder is
      record
      -- Expected
         -- In/out
         data_is_in   : std_logic; -- Used to tell this test program if data should be treated as an input, or output for this test
         data   : std_logic_vector(7 downto 0);
         -- Inputs
         reset     : std_logic;
         INT       : std_logic;
         HOLD      : std_logic;
         READY     : std_logic;
         -- Outputs
         address  : std_logic_vector(15 downto 0);
         INTA     : std_logic;
         WO       : std_logic;
         STACK    : std_logic;
         HLTA     : std_logic;
         OUTPUT   : std_logic;
         M_1      : std_logic;
         INPUT    : std_logic;
         MEMR     : std_logic;
         WR       : std_logic;
         DBIN     : std_logic;
         INTE     : std_logic;
         HLDA     : std_logic;
         WAIT_ACK : std_logic;
         SYNC     : std_logic;
         WZ       : std_logic_vector(15 downto 0);
         PSW      : std_logic_vector(15 downto 0);
         BC       : std_logic_vector(15 downto 0);
         DE       : std_logic_vector(15 downto 0);
         HL       : std_logic_vector(15 downto 0);
         SP       : std_logic_vector(15 downto 0);
         PC       : std_logic_vector(15 downto 0);

         count       : integer range 0 to 2000; -- counts tests performed
         wrong_count : integer range 0 to 2000; -- counts total error
         wrong_indicator : string(1 to 23);  -- indicates a test error (current)
      end record;

   type comments is
      record
         content : string (200 downto 1); -- holds comments from input file
         len : integer range 0 to 200;    -- indicates length of valid data
      end record;

   type files is
      record
         out_line : line;   -- handle for current line in file
         in_line  : line;   -- handle for current line in file
         line_number : integer range 1 to 2000; -- current line No.
         alignment : side;  -- field alignment
         bad : boolean;     -- read failure feedback holder
      end record;

    -- testbench variables
    --   these are global in case more then one process is needed to perform the tests
    shared variable test : test_data_holder; -- actual variable for the record above
    shared variable comment : comments;      -- actual variable for the record above
    shared variable f : files;               -- actual variable for the record above
    file f_out : text; -- handle for file
    file f_in  : text; -- handle for file

    shared variable Done: boolean := false;
   ------------------- Section 2 Cut Here -----------------------------------------/
begin
   -- Instantiate the Unit Under Test (UUT)
   uut : core port map (
      clk, CE, reset,
      address, data,
      INTA,WO,STACK,HLTA,OUTPUT,M_1,INPUT,MEMR,
      WR,DBIN,INTE,INT,HLDA,HOLD,WAIT_ACK,READY,SYNC,
      WZ,PSW,BC,DE,HL,SP,PC
   );

   -- Clock process definitions
   clk_process : process
   begin
      clk <= '0'; wait for clk_period/2;
      clk <= '1'; wait for clk_period/2;
   end process;

   ------------------- Section 3 Cut Here -----------------------------------------\
   -- testbench - loads test data from file, applies data, waits for result,
   --     compares to expected results, counts errors,
   --     writes results to file
   testbench : process -- Runs only once then waits forever

   begin
   
   
      -- Reset PC
      data <= (others=>'Z');
      reset <= '1'; READY <= '1';
      wait for 6*clk_period;
      
      -- initialized variables
      test.count := 0;      -- test count will increment at the begining of first test
      f.line_number := 1;   -- We normally call the first line 1 not 0 so start at 1
      f.alignment := left;  -- sets the alinment for the write functions

      -- open the input and output files
      --    the file names are declared here
      file_open(f_in,  "cpu_test.txt",    read_mode);
      file_open(f_out, "test_results.txt", write_mode);

      -- handle the headers
      readline (f_in,f.in_line); -- read the header line but ignore it
      write(f.out_line, "Inputs Data Addr Status   Control WZ   PSW  BC   DE   HL   SP   PC   DAStatus__Cntrl_WABDHSP COMMENTS "); -- create header on the first line of the output file.
      --                "----   --   ---- -------- ------  ---- ---- ---- ---- ---- ---- ---- !****************!***** "
      writeline(f_out, f.out_line); -- write the header line to the file.
      
      -- wait until the clock is low so we can set the input data
      --    we want to do everything while the clock is low
      --wait until clk='0';

      -- loop through each test
      --    each loop is one line of the input file each line of the input file is one test
      --    i.e. one loop = one test
      while not endfile(f_in) loop

         f.line_number := f.line_number + 1; 
         readline (f_in, f.in_line);
         if (f.in_line'length = 0) then   -- when line is blank
            writeline(f_out, f.out_line); -- copy the blank line to the output file
            next;                         -- then skip the current line/loop/test
         end if;

         test.count := test.count + 1;
         
         -- Inputs
         read (f.in_line, test.reset,     f.bad); assert f.bad report "Text I/O read error of RESET field on line "     &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.INT,       f.bad); assert f.bad report "Text I/O read error of INT field on line "       &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.HOLD,      f.bad); assert f.bad report "Text I/O read error of HOLD field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.READY,     f.bad); assert f.bad report "Text I/O read error of READY field on line "     &integer'image(f.line_number)&" of input file." severity ERROR;
         -- In/out
         read (f.in_line, test.data_is_in,f.bad); assert f.bad report "Text I/O read error of READ/WRITE field on line "&integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.data,      f.bad); assert f.bad report "Text I/O read error of DATA field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         -- Outputs
         read (f.in_line, test.address,   f.bad); assert f.bad report "Text I/O read error of ADDRESS field on line "   &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.INTA,      f.bad); assert f.bad report "Text I/O read error of INTA field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.WO,        f.bad); assert f.bad report "Text I/O read error of WO field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.STACK,     f.bad); assert f.bad report "Text I/O read error of STACK field on line "     &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.HLTA,      f.bad); assert f.bad report "Text I/O read error of HLTA field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.OUTPUT,    f.bad); assert f.bad report "Text I/O read error of OUTPUT field on line "    &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.M_1,       f.bad); assert f.bad report "Text I/O read error of M1 field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.INPUT,     f.bad); assert f.bad report "Text I/O read error of INPUT field on line "     &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.MEMR,      f.bad); assert f.bad report "Text I/O read error of MEMR field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.WR,        f.bad); assert f.bad report "Text I/O read error of WR field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.DBIN,      f.bad); assert f.bad report "Text I/O read error of DBIN field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.INTE,      f.bad); assert f.bad report "Text I/O read error of INTE field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.HLDA,      f.bad); assert f.bad report "Text I/O read error of HLDA field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.WAIT_ACK,  f.bad); assert f.bad report "Text I/O read error of WAIT ACK field on line "  &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.SYNC,      f.bad); assert f.bad report "Text I/O read error of SYNC field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.WZ,        f.bad); assert f.bad report "Text I/O read error of WZ field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.PSW,       f.bad); assert f.bad report "Text I/O read error of PSW field on line "       &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.BC,        f.bad); assert f.bad report "Text I/O read error of BC field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.DE,        f.bad); assert f.bad report "Text I/O read error of DE field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.HL,        f.bad); assert f.bad report "Text I/O read error of HL field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.SP,        f.bad); assert f.bad report "Text I/O read error of SP field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.PC,        f.bad); assert f.bad report "Text I/O read error of PC field on line "        &integer'image(f.line_number)&" of input file." severity ERROR;

         Comment.len := f.in_line'length;
         read (f.in_line, Comment.content(Comment.len downto 1), f.bad); assert f.bad report "Text I/O read error of Comments field on line " &integer'image(f.line_number)&" of input file." severity ERROR;
         
         -- Apply test signals
         if test.data_is_in = '1' then
         data <= test.data;       else    -- CPU in read mode, give it data
         data <= (others=>'Z');   end if; -- Otherwise leave data line alone
         
         reset <= test.reset;
         INT   <= test.INT;
         HOLD  <= test.HOLD;
         READY <= test.READY;

         wait until clk='0'; wait until clk='1';

         if std_match(test.data   , data   ) then test.wrong_indicator(1)  := '*'; else test.wrong_indicator(1)  := '!'; end if;
         if std_match(test.address, address) then test.wrong_indicator(2)  := '*'; else test.wrong_indicator(2)  := '!'; end if;
         if test.INTA     = INTA             then test.wrong_indicator(3)  := '*'; else test.wrong_indicator(3)  := '!'; end if;
         if test.WO       = WO               then test.wrong_indicator(4)  := '*'; else test.wrong_indicator(4)  := '!'; end if;
         if test.STACK    = STACK            then test.wrong_indicator(5)  := '*'; else test.wrong_indicator(5)  := '!'; end if;
         if test.HLTA     = HLTA             then test.wrong_indicator(6)  := '*'; else test.wrong_indicator(6)  := '!'; end if;
         if test.OUTPUT   = OUTPUT           then test.wrong_indicator(7)  := '*'; else test.wrong_indicator(7)  := '!'; end if;
         if test.M_1      = M_1              then test.wrong_indicator(8)  := '*'; else test.wrong_indicator(8)  := '!'; end if;
         if test.INPUT    = INPUT            then test.wrong_indicator(9)  := '*'; else test.wrong_indicator(9)  := '!'; end if;
         if test.MEMR     = MEMR             then test.wrong_indicator(10) := '*'; else test.wrong_indicator(10) := '!'; end if;
         if test.WR       = WR               then test.wrong_indicator(11) := '*'; else test.wrong_indicator(11) := '!'; end if;
         if test.DBIN     = DBIN             then test.wrong_indicator(12) := '*'; else test.wrong_indicator(12) := '!'; end if;
         if test.INTE     = INTE             then test.wrong_indicator(13) := '*'; else test.wrong_indicator(13) := '!'; end if;
         if test.HLDA     = HLDA             then test.wrong_indicator(14) := '*'; else test.wrong_indicator(14) := '!'; end if;
         if test.WAIT_ACK = WAIT_ACK         then test.wrong_indicator(15) := '*'; else test.wrong_indicator(15) := '!'; end if;
         if test.SYNC     = SYNC             then test.wrong_indicator(16) := '*'; else test.wrong_indicator(16) := '!'; end if;
         if std_match(test.WZ , WZ )         then test.wrong_indicator(17) := '*'; else test.wrong_indicator(17) := '!'; end if;
         if std_match(test.PSW, PSW)         then test.wrong_indicator(18) := '*'; else test.wrong_indicator(18) := '!'; end if;
         if std_match(test.BC , BC )         then test.wrong_indicator(19) := '*'; else test.wrong_indicator(19) := '!'; end if;
         if std_match(test.DE , DE )         then test.wrong_indicator(20) := '*'; else test.wrong_indicator(20) := '!'; end if;
         if std_match(test.HL , HL )         then test.wrong_indicator(21) := '*'; else test.wrong_indicator(21) := '!'; end if;
         if std_match(test.SP , SP )         then test.wrong_indicator(22) := '*'; else test.wrong_indicator(22) := '!'; end if;
         if std_match(test.PC , PC )         then test.wrong_indicator(23) := '*'; else test.wrong_indicator(23) := '!'; end if;

         -- Write results to output line
         --    write will write the data as binary,
         --    hwrite will write the data as hexadecamal
         write(f.out_line, test.reset, f.alignment, 1);
         write(f.out_line, test.INT  , f.alignment, 1);
         write(f.out_line, test.HOLD , f.alignment, 1);
         write(f.out_line, test.READY, f.alignment, 1+3);
         
         if data    = (data'range=>'Z')    then
         write(f.out_line, "ZZ   " , f.alignment, 2+3); else    -- 1
        hwrite(f.out_line, data    , f.alignment, 2+3); end if; -- 1
         if address = (address'range=>'Z') then
         write(f.out_line, "ZZZZ " , f.alignment, 4+1); else    -- 2
        hwrite(f.out_line, address , f.alignment, 4+1); end if; -- 2
        
         write(f.out_line, INTA    , f.alignment, 1);   -- 3
         write(f.out_line, WO      , f.alignment, 1);   -- 4
         write(f.out_line, STACK   , f.alignment, 1);   -- 5
         write(f.out_line, HLTA    , f.alignment, 1);   -- 6
         write(f.out_line, OUTPUT  , f.alignment, 1);   -- 7
         write(f.out_line, M_1     , f.alignment, 1);   -- 8
         write(f.out_line, INPUT   , f.alignment, 1);   -- 9
         write(f.out_line, MEMR    , f.alignment, 1+1); -- 10
         
         write(f.out_line, WR      , f.alignment, 1);   -- 11
         write(f.out_line, DBIN    , f.alignment, 1);   -- 12
         write(f.out_line, INTE    , f.alignment, 1);   -- 13
         write(f.out_line, HLDA    , f.alignment, 1);   -- 14
         write(f.out_line, WAIT_ACK, f.alignment, 1);   -- 15
         write(f.out_line, SYNC    , f.alignment, 1+2); -- 16
         
        hwrite(f.out_line, WZ      , f.alignment, 4+1); -- 17
        hwrite(f.out_line, PSW     , f.alignment, 4+1); -- 18
        hwrite(f.out_line, BC      , f.alignment, 4+1); -- 19
        hwrite(f.out_line, DE      , f.alignment, 4+1); -- 20
        hwrite(f.out_line, HL      , f.alignment, 4+1); -- 21
        hwrite(f.out_line, SP      , f.alignment, 4+1); -- 22
        hwrite(f.out_line, PC      , f.alignment, 4+1); -- 23

         -- flag test errors (if any) on current line
         write(f.out_line, test.wrong_indicator, f.alignment, test.wrong_indicator'length ); -- quickly find the errors

         -- copy the comments from the variable to the end of the output line
         write(f.out_line, Comment.content(Comment.len downto 1), f.alignment, Comment.len);

         -- write the output line to the output file
         writeline(f_out, f.out_line);

         report "Test # " & integer'image(test.count) & " Done." severity NOTE;

      -- end of test cycle, loop back to next test or if Done move on
      end loop;

      -- We're Done, so close the files
      file_close(f_in);
      file_close(f_out);
      
      finish(0);

      -- wait forever
      --    this is needed because the process acts like a loop,
      --    when it finishes it runs again, running/looping forever.
      wait;
   end process;
   ------------------- Section 3 Cut Here -----------------------------------------/

end;