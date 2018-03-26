----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:53:06 02/14/2018 
-- Design Name: 
-- Module Name:    SpaceInvaders - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity SpaceInvaders is
      port (
-- Regular signals
       clk50 : in  std_logic; -- 50 MHz board clock
       reset : in  std_logic;
-- Player Input!
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
-- debug
        addr : out std_logic_vector(15 downto 0);
        data : out std_logic_vector(7 downto 0);
     newData : out std_logic);
end SpaceInvaders;

architecture Behavioral of SpaceInvaders is
   -- 2.0,10,13,FALSE = 65 MHz
   -- 2.0,2,2,TRUE    = 25 MHz
	component clock_ctrl is
      generic(
      CLKDV_DIVIDE      : real    := 2.0;    -- Can be  1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 9, 10, 11, 12, 13, 14, 15, 16
      CLKFX_DIVIDE      : integer := 10;     -- Can be any integer from 1 to 32
      CLKFX_MULTIPLY    : integer := 13;     -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2 : boolean := FALSE); -- TRUE/FALSE to enable CLKIN divide by two feature
      port (
         clk_in : in    std_logic;
        clk_out : out   std_logic);
	end component;
   
   component core is
         port (
   -- Regular signals
            clk : in  std_logic;
             CE : in  std_logic;
          reset : in  std_logic;
        address : out std_logic_vector(15 downto 0);
         dataIN : in  std_logic_vector(7 downto 0);
        dataOUT : out std_logic_vector(7 downto 0);
-- Status information signals (Originally broadcast on data line before actual data)
           INTA : out std_logic;
             WO : out std_logic;
          STACK : out std_logic;
           HLTA : out std_logic;
         OUTPUT : out std_logic;
            M_1 : out std_logic;
          INPUT : out std_logic;
           MEMR : out std_logic;
-- External Control signals (These come from outside the CPU)
             WR : out std_logic;
           DBIN : out std_logic;
           INTE : out std_logic;
            INT : in  std_logic;
           HLDA : out std_logic;
           HOLD : in  std_logic;
       WAIT_ACK : out std_logic;
          READY : in  std_logic;
           SYNC : out std_logic);
-- WZ, PSW, BC, DE, HL, SP, PC : out std_logic_vector(15 downto 0));
   end component;
   
   component System_Control is
         port (
             WR : in  std_logic;
           DBIN : in  std_logic;
           HLDA : in  std_logic; -- Unused
          -- Status Information
           INTA : in  std_logic;
             WO : in  std_logic; -- Unused
          STACK : in  std_logic; -- Unused
           HLTA : in  std_logic; -- Unused
         OUTPUT : in  std_logic;
            M_1 : in  std_logic; -- Unused
          INPUT : in  std_logic;
           MEMR : in  std_logic;
-- Control Bus
         -- Interrupt
         INTA_L : out std_logic; -- '0' signals interrupt device to put instruction on data bus
         -- Read  
         MEMR_L : out std_logic; -- '0' signals memory device to write to data bus
          IOR_L : out std_logic; -- '0' signals I/O    device to write to data bus
         -- Write     
         MEMW_L : out std_logic; -- '0' signals memory device to write to data bus
          IOW_L : out std_logic);-- '0' signals I/O    device to write to data bus
   end component;
   
   component memory is
         port (
            clk : in  std_logic;
         dataIN : in  std_logic_vector(7 downto 0);
        dataOUT : out std_logic_vector(7 downto 0);
        address : in  std_logic_vector(15 downto 0);
   -- Control Bus
         MEMR_L : in  std_logic; -- '0' signals memory device to write to data bus
         MEMW_L : in  std_logic; -- '0' signals memory device to read from data bus
   -- Control Signals
         READY  : out std_logic; -- '0' signals CPU that memory device needs more time
   -- Video read
   addressVideo : in  std_logic_vector(15 downto 0);
      dataVideo : out std_logic_vector(7 downto 0));
   end component;
   
   component IO is
            port (
            clk : in  std_logic;
          reset : in  std_logic;
         dataIN : in  std_logic_vector(7 downto 0);
        dataOUT : out std_logic_vector(7 downto 0);
        address : in  std_logic_vector(7 downto 0);
   -- Control Bus
        IOR_L   : in  std_logic; -- '0' signals I/O device to write to data bus
        IOW_L   : in  std_logic; -- '0' signals I/O device to read from data bus
   -- Signals         
      -- INP1         
      credit    : in  std_logic; -- '1' if deposit
      P2_start  : in  std_logic; -- '1' if pressed
      P1_start  : in  std_logic; -- '1' if pressed
      P1_shot   : in  std_logic; -- '1' if pressed
      P1_left   : in  std_logic; -- '1' if pressed
      P1_right  : in  std_logic; -- '1' if pressed
      -- INP2         
      Ships     : in  std_logic_vector(1 downto 0); -- (0,1,2,3) -> (3,4,5,6) ships
      Tilt      : in  std_logic;
      ExtraShip : in  std_logic; -- '0' = extra ship at 1500, '1' = extra ship at 1000
      P2_shot   : in  std_logic; -- '1' if pressed
      P2_left   : in  std_logic; -- '1' if pressed
      P2_right  : in  std_logic; -- '1' if pressed
      CoinInfo  : in  std_logic;-- '0' = ON
      -- INP3 writes shift register data
      INP1      : out std_logic_vector(7 downto 0));
   end component;
   
   component Video is
         port (
            clk : in  std_logic;
   -- Video memory
   addressVideo : out std_logic_vector(15 downto 0);
      dataVideo : in  std_logic_vector(7 downto 0);
   -- VGA timer (subset)
        blank   : in  std_logic;
        hstart  : in  std_logic;
        vga_row : in  integer range 0 to 805; -- 805 @ 65MHz, 524 @ 25MHz
   -- VGA output
          vga_r : out std_logic;
          vga_g : out std_logic;
          vga_b : out std_logic);
   end component;
   
   component VGA_Timer is
      port (
            clk : in  std_logic; -- Expects clock frequency of 65 MHz or 25 MHz
          reset : in  std_logic;
          hsync : out std_logic;
          vsync : out std_logic;
          blank : out std_logic;
         hstart : out std_logic;
        vga_row : out integer range 0 to 805); -- 805 for 65MHz and 524 for 25MHz
   end component;
   
   component VideoInterrupt is
            port (
            clk : in  std_logic;
          reset : in  std_logic;
        vga_row : in  integer range 0 to 805; -- 805 for 65MHz and 524 for 25MHz
         hstart : in  std_logic; -- single pulse that preceeds row drawing
        dataOUT : out std_logic_vector(7 downto 0);
            INT : out std_logic; -- interrupt request sent to CPU
         INTA_L : in  std_logic); -- '0' signals this device to put instruction on data bus
   end component;
   
   signal      clk : std_logic; -- 65MHz clock
   
   signal  address : std_logic_vector(15 downto 0);
   signal  addrVid : std_logic_vector(15 downto 0);
   -- signal     data : std_logic_vector(7 downto 0);
   signal  vidData : std_logic_vector(7 downto 0);
   -- Status information
   signal     INTA : std_logic;
   signal       WO : std_logic;
   signal    STACK : std_logic;
   signal     HLTA : std_logic;
   signal   OUTPUT : std_logic;
   signal      M_1 : std_logic;
   signal    INPUT : std_logic;
   signal     MEMR : std_logic;
   -- External Control signals
   signal       WR : std_logic;
   signal     DBIN : std_logic;
   signal     INTE : std_logic;
   signal      INT : std_logic;
   signal     HLDA : std_logic;
   signal     HOLD : std_logic := '0';
   signal WAIT_ACK : std_logic;
   signal    READY : std_logic;
   signal     SYNC : std_logic;
   -- Control Bus
   signal   INTA_L : std_logic;
   signal   MEMR_L : std_logic;
   signal    IOR_L : std_logic;
   signal   MEMW_L : std_logic;
   signal    IOW_L : std_logic;
   
   -- VGA signals (out)
   signal blank : std_logic;
   signal hstart : std_logic;
   signal vga_row : integer range 0 to 805;
   
   signal CPUclk_counter : integer range 0 to 31;
   
   signal dataBus : std_logic_vector(7 downto 0);
   
   signal cpuDataOUT : std_logic_vector(7 downto 0);
   signal memDataOUT : std_logic_vector(7 downto 0);
   signal intDataOUT : std_logic_vector(7 downto 0);
   signal IO_DataOUT : std_logic_vector(7 downto 0);
   
   signal CE : std_logic; -- Clock enable for CPU
begin
   newData <= '1' when (DBIN = '1' or WR = '0') else '0';
   data <= dataBus;
   -- dataLED <= INTA & WO & STACK & HLTA & OUTPUT & M_1 & INPUT & MEMR;
   
   dataBus <= cpuDataOUT when WR = '0'     else -- CPU              is writing to dataBus
              memDataOUT when MEMR_L = '0' else -- Memory           is writing to dataBus
              intDataOUT when INTA_L = '0' else -- Interrupt device is writing to dataBus
              IO_DataOUT when IOR_L = '0'  else -- I/O       device is writing to dataBus
             (others=>'Z');
   addr <= address;
   ClockDivider: -- Assert CE every 32nd clock cycle. Causes CPU to run at 65/32 = 2.03125 MHz. Close enough to the original 2 MHz
   process(clk, reset)
   begin
      if reset = '1' then
         CPUclk_counter <= 0;
      elsif rising_edge(clk) then
         if CPUclk_counter = 31 then
            CPUclk_counter <= 0;
         else
            CPUclk_counter <= CPUclk_counter + 1;
         end if;
      end if;
   end process;
   CE <= '1' when CPUclk_counter = 0 else '0';
   
   INST_CCTRL : clock_ctrl port map (
        Clk_in => clk50, -- 50 MHz external clock
       Clk_out => clk    -- 65 MHz generated clock
   );
   
   Inst_CPU : core port map (
           clk => clk,
            CE => CE,
         reset => reset,
       address => address,
        dataIN => dataBus,
       dataOUT => cpuDataOUT,
          INTA => INTA,
            WO => WO,
         STACK => STACK,
          HLTA => HLTA,
        OUTPUT => OUTPUT,
           M_1 => M_1,
         INPUT => INPUT,
          MEMR => MEMR,
            WR => WR,
          DBIN => DBIN,
          INTE => INTE,
           INT => INT,
          HLDA => HLDA,
          HOLD => HOLD,
      WAIT_ACK => WAIT_ACK,
         READY => READY,
          SYNC => SYNC
   );
   
   Inst_SCTRL : System_Control port map (
            WR => WR,
          DBIN => DBIN,
          HLDA => HLDA,
          INTA => INTA,
            WO => WO,
         STACK => STACK,
          HLTA => HLTA,
        OUTPUT => OUTPUT,
           M_1 => M_1,
         INPUT => INPUT,
          MEMR => MEMR,
        INTA_L => INTA_L,
        MEMR_L => MEMR_L,
         IOR_L => IOR_L,
        MEMW_L => MEMW_L,
         IOW_L => IOW_L
   );
   
   INST_MEM : memory port map (
           clk => clk,     -- external
        dataIN => dataBus,
       dataOUT => memDataOUT,
       address => address,
        MEMR_L => MEMR_L, 
        MEMW_L => MEMW_L, 
        READY  => READY,  
        -- dataIN => X"00",
       -- dataOUT => open,
       -- address => X"0000",
        -- MEMR_L => '1', 
        -- MEMW_L => '1', 
        -- READY  => open,  
  addressVideo => addrVid,
     dataVideo => vidData
   );
   
   INST_IO : IO port map (
           clk => clk,
         reset => reset,
        dataIN => dataBus,
       dataOUT => IO_DataOUT,
       address => address(7 downto 0), -- Using only lower half of address
         IOR_L => IOR_L,
         IOW_L => IOW_L,
        credit => credit,
      P2_start => '0', -- No second player
      P1_start => P1_start,
       P1_shot => P1_shot,
       P1_left => P1_left,
      P1_right => P1_right,
         Ships => "11", -- Give me 6 ships!
          Tilt => '0', -- No such thing as tilt
     ExtraShip => '1', -- Extra ship at 1000
       P2_shot => '0', -- No second player
       P2_left => '0', -- No second player
      P2_right => '0', -- No second player
      CoinInfo => '0', -- Coin info ON
      INP1 => dataLED -- Debug only
   );
   
   INST_VIDEO : Video port map (
           clk => clk,
  addressVideo => addrVid,
     dataVideo => vidData,
         blank => blank,
        hstart => hstart,
       vga_row => vga_row,
         vga_r => vga_r,
         vga_g => vga_g,
         vga_b => vga_b
   );
   
   INST_VGA : VGA_Timer port map (
           clk => clk,
         reset => reset,
         hsync => hsync, -- Connected directly to output
         vsync => vsync, -- Connected directly to output
         blank => blank,
        hstart => hstart,
       vga_row => vga_row
   );

   INST_INT : VideoInterrupt port map (
           clk => clk,
         reset => reset,
       vga_row => vga_row,
        hstart => hstart,
       dataOUT => intDataOUT,
           INT => INT,
        INTA_L => INTA_L
   );
   
end Behavioral;