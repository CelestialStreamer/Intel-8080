library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Timer is
   port ( clk, reset : in  std_logic; -- Expects clock frequency of 65 MHz or 25 MHz
          hsync, vsync, blank : out  std_logic;
          hstart  : out std_logic;
          vga_row : out integer range 0 to 805); -- 805 for 65MHz and 524 for 25MHz
end VGA_Timer;

architecture Behavioral of VGA_Timer is
   -- numbers in (#) are industry standard, I'm using the other number
   -- 1024x768 (clk=65MHz)     is 1024, 24, 136,    160;    768, 3,  6, 29
   -- 640x480  (clk=25.175MHz) is 640,  16, 92(96), 46(48); 480, 10, 2, 33
   constant HBB : integer := 1024 - 1;    -- Horizontal Blanking Interval Begin
   constant FPL : integer := 24   + HBB; -- Front Porch line
   constant BPL : integer := 136  + FPL; -- Back Porch line                  (Standard is 96)
   constant HBE : integer := 160  + BPL; -- Horizontal Blanking Interval End (Standard is 48)
   
   constant VBB : integer := 768 - 0;   -- Vertical Blanking Interval Begin
   constant FPF : integer := 3   + VBB; -- Front Porch frame
   constant BPF : integer := 6   + FPF; -- Back Porch frame
   constant VBE : integer := 29  + BPF - 1; -- Vertical Blanking Interval End

   signal hcount : integer range 0 to HBE; -- column
   signal vcount : integer range 0 to VBE; -- row
   signal hblank, vblank : std_logic;
   
   signal hcount_vec : std_logic_vector(10 downto 0);
   signal vcount_vec : std_logic_vector(10 downto 0);
begin
   hcount_vec <= std_logic_vector(to_unsigned(hcount, hcount_vec'length));
   vcount_vec <= std_logic_vector(to_unsigned(vcount, vcount_vec'length));

   blank <= hblank and vblank;
   vga_row <= vcount;
   hstart <= '1' when hcount = HBE else '0';

   -- Hsync SR latch
   process(clk, reset) begin
      if reset = '1' then         hsync <= '1';
      elsif rising_edge(clk) then
         if    hcount = FPL then hsync <= '0';
         elsif hcount = BPL then hsync <= '1';
         end if;
      end if;
   end process;
   -- Hblank SR Latch
   process(clk, reset) begin
      if reset = '1' then         hblank <= '1';
      elsif rising_edge(clk) then
         if    hcount = HBB then hblank <= '0';
         elsif hcount = HBE then hblank <= '1';
         end if;
      end if;
   end process;

   -- Vsync SR Latch
   process(clk, reset) begin
      if reset = '1' then        vsync <= '1';
      elsif rising_edge(clk) then
         if    vcount = FPF then vsync <= '0';
         elsif vcount = BPF then vsync <= '1';
         end if;
      end if;
   end process;
   -- Vblank SR Latch
   process(clk, reset) begin
      if reset = '1' then        vblank <= '1';
      elsif rising_edge(clk) then
         if    vcount = VBB then vblank <= '0';
         elsif vcount = 0   then vblank <= '1';
         end if;
      end if;
   end process;
   
   -- Counters
   process(clk, reset) begin
      if reset = '1' then      hcount <= 0;
      elsif rising_edge(clk) then
         if hcount = HBE then hcount <= 0;
         else                 hcount <= hcount + 1;
         end if;
      end if;
   end process;
   
   process(clk, reset) begin
      if reset = '1' then     vcount <= 0;
      elsif rising_edge(clk) and hcount = (FPL + BPL) / 2 then
         if vcount = VBE then vcount <= 0;
         else                 vcount <= vcount + 1;
         end if;
      end if;
   end process;
end Behavioral;