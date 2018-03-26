----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:
-- Design Name:    LCD I/O
-- Module Name:    LCD_IO - Behavioral
-- Project Name:   8080
-- Target Devices:
-- Description:    This I/O device writes a character to screen when accessed by
--                 CPU. CPU puts character on data bus to be written to screen.
--                 Character can be any ascii or control character as used by LCD.
--                 Specifically, the ascii or control character is sent to the LCD
--                 on the board when address=00h and IOW_L='0'.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity LCD_IO is
      port (
         clk : in  std_logic;
       reset : in  std_logic;
       ascii : in  std_logic_vector(7 downto 0);
     address : in  std_logic_vector(15 downto 0);
-- Control Bus
       IOW_L : in  std_logic; -- '0' signals I/O device to read from data bus
-- Wait
        hold : out std_logic; -- Hold the CPU while communicating with LCD unit
-- LCD signals
     sf_ce0  : out std_logic; -- Use pin D16
     lcd_e   : out std_logic; -- Use pin M18
     lcd_rs  : out std_logic; -- Use pin L18
     lcd_rw  : out std_logic; -- Use pin L17
     lcd_dat : out std_logic_vector(3 downto 0)); -- Use pin (M15,P17,R16,R15) => (3,2,1,0)
end LCD_IO;

architecture Behavioral of LCD_IO is
   -- My additions
   constant CLK_F : real := 3.125; -- Clock frequency is 3.125 MHz
   constant HOME_ADDRESS : std_logic_vector(7 downto 0) := "00000000";
   
   -- Orignal (some modifications)
   type state_type is (init1, init2, init3, idle, txmt_hi, txmt_lo, holding);
   signal state : state_type;

   type cmd_type is (FunctionSet, EntryModeSet, DisplayOnOff, ClearDisplay, CmdIdle);
   signal cmd_state : cmd_type;

   signal data9, cmd_data : std_logic_vector(8 downto 0);

   constant ms_15  : integer := integer(CLK_F*15000.0); --  15.0 ms
   constant ms_4_1 : integer := integer(CLK_F* 4100.0); --   4.1 ms
   constant ms_1_6 : integer := integer(CLK_F* 1600.0); --   1.6 ms
   constant us_100 : integer := integer(CLK_F*  100.0); -- 100.0 us
   constant us_40  : integer := integer(CLK_F*   40.0); --  40.0 us
   signal timer : integer range 0 to ms_15; -- 15 ms timer

   signal busy : boolean;
   signal trigger : boolean;

   signal row : integer range 0 to 1;

   signal strobe : std_logic; -- A 1 clock cycle signal to print character
   
   signal IOWL_prev : std_logic;
   
begin
   IOWL:
   process(clk)
   begin
      if rising_edge(clk) then
         IOWL_prev <= IOW_L;
      end if;
   end process;

   strobe <= '1' when (address = HOME_ADDRESS&HOME_ADDRESS) and (IOWL_prev = '1') and (IOW_L = '0') else '0';
   hold   <= '1' when not ((not busy) and (not trigger) and (cmd_state=CmdIdle) and (state=idle))   else '0';

   -- these outputs never change
   lcd_rw <= '0'; -- write only
   sf_ce0 <= '1'; -- disable intel strataflash
   --
   -- This section is the workhorse of the module, it initializes the LCD
   -- then it manages the delivery of bytes to the LCD. A timer counts down
   -- delays, and during the last 16 counts causes a bus cycle to the LCD
   -- (except during a holding state, which is used to insert a delay after
   -- a transaction).
   --
   --
   lcd_e  <= '1' when timer < 16 and timer > 3 and state /= holding else '0';
   lcd_dat <=  data9(7 downto 4) when state = txmt_hi else
               data9(3 downto 0) when state = txmt_lo else
               "0010" when state = idle else "0011";
   lcd_rs <= data9(8) when state = txmt_hi or state = txmt_lo else '0';

   --
   -- This state machine configures the LCD for 4-bit mode, then sits around and
   -- waits for commands (in cmd_data, qualified by trigger = 1). busy is set
   -- true as soon as cmd_data is consumed (latched into data9) and remains so
   -- until the command is complete. Clients of this service should wait until
   -- busy is false then load cmd_data and assert trigger for one (or just a few)
   -- cycles.
   --
   -- after LCD is initialized, trigger causes a 40us wait.  Thereafter, the 9-bit
   -- data (including register select) in data9 is transferred one nybble at a time
   -- (with a 1us gap). Register select is valid for both nybbles.
   --
   process (clk, reset)
   begin
      if reset = '1' then
         state <= init1;          -- one-time initiialization state chain
         timer <= ms_15;  -- wait 15ms before sending a 3
         busy <= false;           -- report readiness for command to this subsection
      elsif rising_edge(clk) then
         if not busy and trigger then
            busy <= true;      -- set until command complete
            data9 <= cmd_data; -- R/S and data part
         end if;
         if timer /= 0 then    -- only advance state machine if timer expired
            timer <= timer - 1;
         else
            case state is
               when init1 =>             -- initial 15ms expired, wait 4.1ms and
                  timer <= ms_4_1;       -- send another 3
                  state <= init2;
               when init2 =>             -- 4.1ms timeout expired, wait 100us and
                  timer <= us_100;       -- send another 3
                  state <= init3;
               when init3 =>             -- 100us timeout expired, wait 40us and
                  timer <= us_40;        -- send a 2 (because we will be in idle)
                  state <= idle;
               when idle =>
                  if busy then           -- if busy, then new data have arrived
                     state <= txmt_hi;
                     timer <= us_40;     -- wait 40us
                  else
                     timer <= 0;         -- not busy, so reset the timer for next time
                  end if;
               when txmt_hi =>
                  timer <= 81;           -- high nybble transferred, wait 1us and send low
                  state <= txmt_lo;
               when txmt_lo =>           -- low nybble transferred, check if clearing
                  if data9 = "000000001" then -- clearing display?
                     timer <= ms_1_6;    -- pad additional 1.6ms if clearing
                  else
                     timer <= 0;
                  end if;
                  state <= holding;      -- holding state, writing to LCD prohibited
               when holding =>
                  timer <= 0;
                  busy <= false;         -- transfer complete, clear busy flag
                  state <= idle;         -- return to idle & wait for next trigger
            end case;
         end if;
      end if;
   end process;

   --
   -- this process works at a higher level, first sending out function set
   -- command, an entry set command, a display on/off command and finally a
   -- display clear command
   --
   process (clk, reset)
   begin
      if reset = '1' then
         cmd_state <= FunctionSet;
         trigger <= false;
         row <= 0;
      elsif rising_edge(clk) then
         -- this SM advances only if busy is false (trigger has to be false too)
         -- the advance ususally sets trigger true and the cycle repeats. The one
         -- exception is CmdIdle, which may leave trigger false (meaning the
         -- strobe and ascii inputs will be checked again in one cycle).
         if busy then
            trigger <= false;
         elsif not trigger then
            trigger <= true; -- this will be true except perhaps in ComIdle
            case cmd_state is
               when FunctionSet =>
                  cmd_data <= "000101000"; -- function set: 2 lines, 5x7 font
                  cmd_state <= EntryModeSet;
               when EntryModeSet =>
                  cmd_data <= "000000110"; -- entry mode set: inc, no shift
                  cmd_state <= DisplayOnOff;
               when DisplayOnOff =>
                  cmd_data <= "000001101"; -- display control: on, blinking
                  cmd_state <= ClearDisplay;
               when ClearDisplay =>
                  cmd_data <= "000000001"; -- clear display
                  cmd_state <= CmdIdle;
               when CmdIdle =>
                  if strobe /= '1' then
                     trigger <= false;        --nothing new, no trigger here
                  elsif ascii = "00001100" then
                     cmd_data <= "000000001"; -- ascii char is FF, clear
                  elsif ascii /= "00001101" then
                     cmd_data <= '1' & ascii; -- ascii not CR, send it to LCD
                  elsif row = 1 then
                     cmd_data <= "000000001"; -- row 2 -> row 1 (clear display)
                     row <= 0;
                  else
                     cmd_data <= "011000000"; -- row 1 -> row 2 (DD addr <= C0)
                     row <= 1;
                  end if;
            end case;
         end if;
      end if;
   end process;
end Behavioral;