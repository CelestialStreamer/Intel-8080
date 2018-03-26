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
use std.env.all;
use work.alu_package.all;

---------------------- Section 1 Cut Here -----------------------------------------\
use ieee.numeric_std.all;      -- this is commented out by default but we need it.
use ieee.std_logic_textio.all; -- for some file reading functions
use std.textio.all;            -- for other file reading functions
---------------------- Section 1 Cut Here -----------------------------------------/

entity ALU_test is
end ALU_test;

architecture behavior of ALU_test is

   -- Component Declaration for the Unit Under Test (UUT)
   component ALU is
   port (
           --clk : in  std_logic;
          A, B : in  std_logic_vector (7 downto 0);
     operation : in  ALU_Function;
        enable : in  std_logic;
      flags_in : in  std_logic_vector (4 downto 0);
     flags_out : out std_logic_vector (4 downto 0);
             C : out std_logic_vector (7 downto 0));
   end component;

   -- Inputs
   signal A, B     : std_logic_vector (7 downto 0);
   signal operation: ALU_Function;
   signal enable   : std_logic;
   signal flags_in : std_logic_vector (4 downto 0);

   -- Outputs
   signal flags_out: std_logic_vector (4 downto 0);
   signal C        : std_logic_vector (7 downto 0);
   
   -- Clock period definitions
   signal clk      : std_logic;
   constant clk_period : time := 1 ns;

   ------------------- Section 2 Cut Here -----------------------------------------\
   -- testbench types
   type test_data_holder is
      record
      -- Expected
         -- Inputs
         A, B     : std_logic_vector (7 downto 0);
         operation: ALU_Function;
         enable   : std_logic;
         flags_in : std_logic_vector (4 downto 0);
         
         -- Outputs
         flags_out: std_logic_vector (4 downto 0);
         C        : std_logic_vector (7 downto 0);
         
         count       : integer range 0 to 2000; -- counts tests performed
         wrong_count : integer range 0 to 2000; -- counts total error
         wrong_indicator : string(1 to 1+5 + 1);  -- indicats a test error (current)
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
    shared variable test : test_data_holder; -- accual variable for the record above
    shared variable comment : comments;      -- accual variable for the record above
    shared variable f : files;               -- accual variable for the record above
    file f_out : text; -- handle for file
    file f_in  : text; -- handle for file

    shared variable Done: boolean := false;
   ------------------- Section 2 Cut Here -----------------------------------------/

begin
   -- Instantiate the Unit Under Test (UUT)
   uut : ALU port map (
      A,B,
      operation,enable,
      flags_in,flags_out,
      C
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
      variable alu_operation : string(1 to 3);
   begin
      -- initialized variables
      test.count := 0;      -- test count will increment at the begining of first test
      f.line_number := 1;   -- We normally call the first line 1 not 0 so start at 1
      f.alignment := left;  -- sets the alinment for the write functions

      -- open the input and output files
      --    the file names are declared here
      file_open(f_in,  "alu_test.txt",    read_mode);
      file_open(f_out, "test_results.txt", write_mode);

      -- handle the headers
      readline (f_in,f.in_line); -- read the header line but ignore it
      write(f.out_line, "E opp f-in  A        B        C-actual expected f-out expct C SZAPC COMMENTS"); -- create header on the first line of the output file.
      --                "- --- ----- -------- -------- -------- -------- ----- ----- * ***** "
      writeline(f_out, f.out_line); -- write the header line to the file.
      
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
         read (f.in_line, test.enable,    f.bad); assert f.bad report "Text I/O read error of ALU ENABLE field on line "    &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, alu_operation(1 to 1), f.bad); assert f.bad report "Could not skip space on line " & integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, alu_operation,  f.bad); assert f.bad report "Text I/O read error of ALU OPERATION field on line " &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.flags_in,  f.bad); assert f.bad report "Text I/O read error of FLAGS-in field on line "      &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.A,         f.bad); assert f.bad report "Text I/O read error of A field on line "             &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.B,         f.bad); assert f.bad report "Text I/O read error of B field on line "             &integer'image(f.line_number)&" of input file." severity ERROR;

         -- Outputs                       
         read (f.in_line, test.C,         f.bad); assert f.bad report "Text I/O read error of C field on line "             &integer'image(f.line_number)&" of input file." severity ERROR;
         read (f.in_line, test.flags_out, f.bad); assert f.bad report "Text I/O read error of FLAGS-out field on line "     &integer'image(f.line_number)&" of input file." severity ERROR;
         
         if    alu_operation = "ADD" then test.operation := ADD;
         elsif alu_operation = "ADC" then test.operation := ADD_WITH_CARRY;
         elsif alu_operation = "SUB" then test.operation := SUBTRACT;
         elsif alu_operation = "SBB" then test.operation := SUBTRACT_WITH_CARRY;
         elsif alu_operation = "ANA" then test.operation := LOGICAL_AND;
         elsif alu_operation = "XRA" then test.operation := LOGICAL_XOR;
         elsif alu_operation = "ORA" then test.operation := LOGICAL_OR;
         elsif alu_operation = "CMP" then test.operation := COMPARE;
         elsif alu_operation = "RLC" then test.operation := ROTATELEFT;
         elsif alu_operation = "RRC" then test.operation := ROTATERIGHT;
         elsif alu_operation = "RAL" then test.operation := ROTATELEFT_THROUGH_CARRY;
         elsif alu_operation = "RAR" then test.operation := ROTATERIGHT_THROUGH_CARRY;
         elsif alu_operation = "DAA" then test.operation := DECIMAL_ADJUST;
         else                             test.operation := NONE;
         end if;
         
         -- Apply test signals
         enable    <= test.enable;
         operation <= test.operation;
         flags_in  <= test.flags_in;
         A         <= test.A;
         B         <= test.B;

         wait until clk='0'; wait until clk='1';

         if test.C = C then test.wrong_indicator(1) := '*'; else test.wrong_indicator(1) := '!'; end if;
         test.wrong_indicator(2) := ' '; -- Space in between C and FLAGS         
         for i in 0 to 4 loop
            if test.flags_out(4-i) = flags_out(4-i) then
            test.wrong_indicator(3+i) := '*'; else
            test.wrong_indicator(3+i) := '!'; end if;
         end loop;
         
         -- Write results to output line
         --    write will write the data as binary,
         --    hwrite will write the data as hexadecamal
         write(f.out_line, enable        , f.alignment, 1+1);
         write(f.out_line, alu_operation , f.alignment, 3+1);
         write(f.out_line, flags_in      , f.alignment, 5+1);
         write(f.out_line, A             , f.alignment, 8+1);
         write(f.out_line, B             , f.alignment, 8+1);
         write(f.out_line, C             , f.alignment, 8+1); write(f.out_line, test.C        , f.alignment, 8+1);
         write(f.out_line, flags_out     , f.alignment, 5+1); write(f.out_line, test.flags_out, f.alignment, 5+1);

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