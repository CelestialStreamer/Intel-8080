library ieee;
use ieee.std_logic_1164.all;

entity transmitter is
      port (
         clk : in  std_logic;                     -- clk input
       reset : in  std_logic;                     -- reset, active high
       pdata : in  std_logic_vector (7 downto 0); -- parallel data in
     address : in  std_logic_vector(15 downto 0);
       IOW_L : in  std_logic;                     -- '0' signals I/O device to read from data bus
       sdata : out std_logic);                    -- serial data out
end transmitter;

architecture Behavioral of transmitter is
   constant CLK_F : real := 3.125; -- Clock frequency is 3.125 MHz
   constant TIMER_MAX : integer := integer((CLK_F * 10.0**6) / 9600.0); -- (3.125 MHz)*(1/9600s)=325 cycles
   constant HOME_ADDRESS : std_logic_vector(7 downto 0) := "00000000";
   
   signal ready : std_logic;
   
   signal Count : integer range 0 to 10;
   signal timer : integer range 0 to TIMER_MAX;
   
   signal timeout, shift, ten, load, start : STD_LOGIC;
   signal TBR : std_logic_vector(7 downto 0); -- Transmit buffer register
   signal TSR : std_logic_vector(8 downto 0); -- Transmit shift register
   signal TBR_Full : std_logic; -- Data is ready to be read
   type State_Type is (S0, S1);
   signal cur, nxt : State_Type := S0;
begin
   ready <= '1' when (address = HOME_ADDRESS&HOME_ADDRESS) and (IOW_L = '0') else '0';

   -- SR Latch
   process(clk, reset)
   begin
      if reset = '1' then
         TBR_Full <= '0';
      elsif rising_edge(clk) then
         if load = '1' then
            TBR_Full <= '0';
         elsif ready = '1' then
            TBR_Full <= '1';
         end if;
      end if;
   end process;

   -- Timer
   process(clk)
   begin
      if rising_edge(clk) then
         if start = '1' then
            timer <= 0;
         elsif timer /= TIMER_MAX then
            timer <= timer + 1;
         end if;
      end if;
   end process;
   timeout <= '1' when timer = TIMER_MAX else '0';

   -- Counter
   process(load, shift, clk)
   begin
      if rising_edge(clk) then
         if load = '1' then
            count <= 0;
         elsif shift = '1' then
            count <= count + 1;
         end if;
      end if;
   end process;
   ten <= '1' when count = 10 else '0';

   -- TBR
   process(clk)
   begin
      if rising_edge(clk) then
         if ready = '1' then
            TBR <= pdata;
         end if;
      end if;
   end process;

   -- TSR
   process(clk)
   begin
      if rising_edge(clk) then
         if load = '1' then -- parallel load
            TSR <= TBR & '0';
         elsif shift = '1' then -- shift
            TSR <= '1' & TSR(8 downto 1);
         end if;
      end if;
   end process;
   sdata <= TSR(0);

   STATE_REGISTER:
   process(clk, reset)
   begin
      if reset = '1' then
         cur <= S0;
      elsif rising_edge(clk) then
         cur <= nxt;
      end if;
   end process;
   
   NEXT_STATE_DECODER:
   process(TBR_Full, timeout, ten, cur)
   begin
      start <= '0';
      load  <= '0';
      shift <= '0';
      
      case cur is
         when S0 =>
            if TBR_Full = '0' then nxt <= S0;
            else                   nxt <= S1;
                                   load  <= '1';
                                   start <= '1';
            end if;
         when S1 =>
            if timeout = '0'  then nxt <= S1;
            elsif ten = '0'   then nxt <= S1;
                                   shift <= '1';
                                   start <= '1';
            else                   nxt <= S0;
            end if;
      end case;
   end process;

end Behavioral;