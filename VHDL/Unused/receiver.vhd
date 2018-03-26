library ieee;
use ieee.std_logic_1164.all;

entity receiver is
   port ( clk : in std_logic;                     -- clk input
        reset : in std_logic;                     -- reset, active high
        sdata : in std_logic;                     -- serial data in
        pdata : out std_logic_vector(7 downto 0); -- parallel data out
        ready : out std_logic);                   -- ready strobe, active high
end receiver;

architecture Behavioral of Receiver is
   constant CLK_F : real := 3.125; -- Clock frequency is 3.125 MHz
   constant TIMER_MAX : integer := integer((CLK_F * 10.0**6) / 9600.0 / 2.0); -- (3.125 MHz)*(1/9600s)*(1/2)=162 cycles
   
   signal Q : STD_LOGIC_VECTOR (7 downto 0);
   
   signal Count : integer range 0 to 8;
   signal timer : integer range 0 to TIMER_MAX;
   
   signal half, timeout, shift, eight, S, clear : STD_LOGIC;
   
   type State_Type is (S0, S1, S2, S3, S4, S5);
   signal nxt, cur : State_Type;
begin
   -- SIPO
   process(clk)
   begin
      if rising_edge(clk) then
         if shift = '1' then
            Q <= sdata & Q(7 downto 1);
         end if;
      end if;
   end process;
   pdata <= Q;

   -- Counter
   process(clk)
   begin
      if rising_edge(clk) then
         if clear = '1' then
            count <= 0;
         elsif shift = '1' then
            count <= count + 1;
         end if;
      end if;
   end process;
   eight <= '1' when count = 8 else '0';

   -- Timer
   process(clk)
   begin
      if rising_edge(clk) then
         if half = '1' then
            timer <= 0;
         elsif timer /= TIMER_MAX then
            timer <= timer + 1;
         end if;
      end if;
   end process;
   timeout <= '1' when timer = TIMER_MAX else '0';
   process(clk)
   begin
      if rising_edge(clk) then
         S <= sdata;
      end if;
   end process;

   -- Controller
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
   process(timeout, S, eight, cur)
   begin
      half  <= '0';
      clear <= '0';
      ready <= '0';
      shift <= '0';
      
      case cur is
         when S0 =>
            if S = '1'        then nxt <= S0;
            else                   nxt <= S1;
                                   half <= '1';
            end if;
         when S1 =>
            if timeout = '0'  then nxt <= S1;
            elsif S = '1'     then nxt <= S0;
            else                   nxt <= S2;
                                   clear <= '1';
                                   half <= '1';
            end if;
         when S2 =>
            if timeout = '0'  then nxt <= S2;
            else                   nxt <= S3;
                                   half <= '1';
            end if;
         when S3 =>
            if timeout = '0'  then nxt <= S3;
            elsif eight = '0' then nxt <= S2;
                                   half <= '1';
                                   shift <= '1';
            else                   nxt <= S4;
                                   half <= '1';
            end if;
         when S4 =>
            if timeout = '0'  then nxt <= S4;
            else                   nxt <= S5;
                                   half <= '1';
            end if;
         when S5 =>
            if timeout = '0'  then nxt <= S5;
            else                   nxt <= S0;
                                   ready <= '1';
            end if;
      end case;
   end process;
   
end Behavioral;