----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:    20:37:50 11/22/2013
-- Design Name:
-- Module Name:    core - Behavioral
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions:
-- Description:
--
-- Dependencies:   None
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity system is
      port (
-- Regular signals
       clk50 : in  std_logic; -- 50 MHz board clock3
      intBtn : in  std_logic; -- Button used as interrupt source
       reset : in  std_logic;
-- LCD signals
     sf_ce0  : out std_logic; -- Use pin D16
     lcd_e   : out std_logic; -- Use pin M18
     lcd_rs  : out std_logic; -- Use pin L18
     lcd_rw  : out std_logic; -- Use pin L17
     lcd_dat : out std_logic_vector(3 downto 0); -- Use pin (M15,P17,R16,R15) => (3,2,1,0)
-- LED signals
     dataLED : out std_logic_vector(7 downto 0));
end system;

architecture Behavioral of system is
	component clock_ctrl is -- Just about the slowest clock speed possible
      generic(
      CLKDV_DIVIDE      : real    := 2.0;
      CLKFX_DIVIDE      : integer := 32;
      CLKFX_MULTIPLY    : integer := 2;
      CLKIN_DIVIDE_BY_2 : boolean := FALSE);
      port (
          clk_in : in  std_logic;
         clk_out : out std_logic);
	end component;

   component debounce is
      generic (counter_size : integer := 15);
      port(clk, button : in std_logic; result : out std_logic);
   end component;
   
   component core is
         port (
   -- Regular signals
            clk : in    std_logic;
          reset : in    std_logic;
        address : out   std_logic_vector(15 downto 0);
           data : inout std_logic_vector(7 downto 0);
-- Status information signals (Originally broadcast on data line before actual data)
           INTA : out   std_logic;
             WO : out   std_logic;
          STACK : out   std_logic;
           HLTA : out   std_logic;
         OUTPUT : out   std_logic;
            M_1 : out   std_logic;
          INPUT : out   std_logic;
           MEMR : out   std_logic;
-- External Control signals (These come from outside the CPU)
             WR : out   std_logic;
           DBIN : out   std_logic;
           INTE : out   std_logic;
            INT : in    std_logic;
           HLDA : out   std_logic;
           HOLD : in    std_logic;
       WAIT_ACK : out   std_logic;
          READY : in    std_logic;
           SYNC : out   std_logic;
-- Debug signals (Feel free to leave connected to open)
   WZ, PSW, BC, DE, HL, SP, PC : out std_logic_vector(15 downto 0));
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
            clk : in    std_logic;
           data : inout std_logic_vector(7 downto 0);
        address : in    std_logic_vector(15 downto 0);
   -- Control Bus
         MEMR_L : in    std_logic; -- '0' signals memory device to write to data bus
         MEMW_L : in    std_logic; -- '0' signals memory device to read from data bus
   -- Control Signals
         READY  : out   std_logic; -- '0' signals CPU that memory device needs more time
   -- Video read
   addressVideo : in    std_logic_vector(15 downto 0);
      dataVideo : out   std_logic_vector(7 downto 0));
   end component;
   
   component LCD_IO is
         port (
            clk : in  std_logic;
          reset : in  std_logic;
          ascii : in  std_logic_vector(7 downto 0);
        address : in  std_logic_vector(15 downto 0);
   -- Control Bus
      --IOR_L   : in  std_logic; -- '0' signals I/O device to write to data bus
        IOW_L   : in  std_logic; -- '0' signals I/O device to read from data bus
   -- Wait
           hold : out std_logic; -- Hold the CPU while communicating with LCD unit
   -- LCD signals
        sf_ce0  : out std_logic; -- Use pin D16
        lcd_e   : out std_logic; -- Use pin M18
        lcd_rs  : out std_logic; -- Use pin L18
        lcd_rw  : out std_logic; -- Use pin L17
        lcd_dat : out std_logic_vector(3 downto 0)); -- Use pin (M15,P17,R16,R15) => (3,2,1,0)
   end component;
   
   component Interrupt is
         port (
            clk : in    std_logic;
          reset : in    std_logic;
         button : in    std_logic;
           data : inout std_logic_vector(7 downto 0);
            INT : out   std_logic;
         INTA_L : in    std_logic);
   end component;
   
   signal      clk : std_logic; -- 3.125 MHz clock
   
   signal  clk_cpu : std_logic; -- User generated CPU clock
   
   signal  address : std_logic_vector(15 downto 0);
   signal     data : std_logic_vector(7 downto 0);
   -- Status information
   signal     INTA : std_logic;
   signal       WO : std_logic;
   signal    STACK : std_logic;
   signal     HLTA : std_logic;
   signal   OUTPUT : std_logic;
   signal      M_1 : std_logic;
   signal    INPUT : std_logic;
   signal     MEMR : std_logic;
   -- Control signals
   signal       WR : std_logic;
   signal     DBIN : std_logic;
   signal     INTE : std_logic;
   signal      INT : std_logic;
   signal     HLDA : std_logic;
   signal     HOLD : std_logic;
   signal WAIT_ACK : std_logic;
   signal    READY : std_logic;
   signal     SYNC : std_logic;
   
   signal   INTA_L : std_logic;
   signal   MEMR_L : std_logic;
   signal    IOR_L : std_logic;
   signal   MEMW_L : std_logic;
   signal    IOW_L : std_logic;
   
   signal status : std_logic_vector(7 downto 0);
   
   signal button : std_logic; -- Interrupt button
begin
   status <= INTA & WO & STACK & HLTA & OUTPUT & M_1 & INPUT & MEMR;
   -- status <= "101010" & clkBtn & clk_cpu;
   
   dataLED <= status;
   
   CCTL : clock_ctrl port map (
        Clk_in => clk50,
       Clk_out => clk
   );

   DBNC : debounce
   generic map (
      counter_size => 15
   ) port map (
      clk => clk,
      button => intBtn,
      result => button
   );
   
   Inst_CPU : core port map (
           clk => clk, -- external (sort of)
         reset => reset,   -- external
       address => address,
          data => data,
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
           INT => INT, -- No interrupt implemented
          HLDA => HLDA,
          HOLD => HOLD,
      WAIT_ACK => WAIT_ACK,
         READY => READY,
          SYNC => SYNC,
          WZ=>open,PSW =>open,BC=>open,DE=>open,HL=>open,SP=>open,PC=>open
   );
   
   Inst_SYS : System_Control port map (
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
          data => data,
       address => address,
        MEMR_L => MEMR_L,
        MEMW_L => MEMW_L,
        READY  => READY,
  addressVideo => (address'range=>'0'),
     dataVideo => open
   );
   
   INST_LCD : LCD_IO port map (
            clk => clk,    -- external
          reset => reset,  -- external
          ascii => data,
        address => address,
          IOW_L => IOW_L,
           hold => HOLD,
         sf_ce0 => sf_ce0, -- external
          lcd_e => lcd_e,  -- external
         lcd_rs => lcd_rs, -- external
         lcd_rw => lcd_rw, -- external
        lcd_dat => lcd_dat -- external
   );
   
   INST_INT : Interrupt port map (
      clk => clk,
      reset => reset,
      button => button,
      data => data,
      INT => INT,
      INTA_L => INTA_L
   );
   
end Behavioral;