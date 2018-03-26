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
use ieee.numeric_std.all;
use work.alu_package.all;

entity core is
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
        SYNC : out std_logic
-- -- Debug signals (Feel free to leave connected to open)
-- WZ, PSW, BC, DE, HL, SP, PC : out std_logic_vector(15 downto 0)
);
end core;

architecture Behavioral of core is

   -- Internal data bus and data bus buffer/latch
   signal DBLatch : std_logic_vector(7 downto 0) := (others=>'0'); -- Data Bus Buffer/Latch
   signal dataBus : std_logic_vector(7 downto 0); -- 8 bit internal data bus

   -- Registers that are not part of the register array but are part of the ISA
   signal Accumulator : std_logic_vector(7 downto 0) := (others=>'0');
   signal Flags       : std_logic_vector(4 downto 0) := (others=>'0');

   -- Remaining registers
   signal AccumulatorLatch : std_logic_vector(7 downto 0) := (others=>'0');
   signal TempReg          : std_logic_vector(7 downto 0) := (others=>'0');
   signal InstReg          : std_logic_vector(7 downto 0) := (others=>'0');

   -- Name for each bit in Flag register
   alias Sign   : std_logic is flags(4); -- Bit 7
   alias Zero   : std_logic is flags(3); -- Bit 6
   alias ACarry : std_logic is flags(2); -- Bit 4
   alias Parity : std_logic is flags(1); -- Bit 2
   alias Carry  : std_logic is flags(0); -- Bit 0

   component ALU is
      port ( A, B : in  std_logic_vector (7 downto 0);
        operation : in  ALU_Function;
           enable : in  std_logic;
         flags_in : in  std_logic_vector (4 downto 0);
        flags_out : out std_logic_vector (4 downto 0);
                C : out std_logic_vector (7 downto 0));
   end component;

   component register_array is
      port ( clk : in  std_logic;
              CE : in  std_logic;
           reset : in  std_logic;
          dataIN : in  std_logic_vector(7 downto 0);
         dataOUT : out std_logic_vector(7 downto 0);
         address : out std_logic_vector(15 downto 0); -- contents of register pair.

            -- Register select signals
 register_select : in  std_logic_vector(2  downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
     byte_select : in  std_logic; -- '1' means high byte
         WZ_both : in  std_logic; -- write both bytes of W and Z
          WZ_RST : in  std_logic; -- Used to set 0->W and RST->Z
         RST_NNN : in  std_logic_vector(2 downto 0); -- Used only during RST. This is connected directly to the Instruction Register; the top module does this, this is not the job of the control unit.
            -- Read/write signals
       take_data : in  std_logic; -- asserted when register reads data from bus
       give_data : in  std_logic; -- asserted when register writes data to bus
            -- Control signals
-- Increment/decrement register pair
         inc_dec : in  std_logic; -- '1' means increment, '0' means decrement. Implemented for all register pairs. Note that decrement is never used for WZ and PC.
         operate : in  std_logic; -- '1' means perform increment/decrement operation
   update_select : in  std_logic_vector(2 downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
-- Out status          
   status_select : in  std_logic_vector(2 downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
   status_update : in  std_logic; -- '1' means update address to current value of register pair
   status_active : in  std_logic; -- '1' means address line has high impedence.
-- A few exceptions    
           HL_DE : in  std_logic; -- Only asserted for XCHG. (HL)<->(DE)
           PC_HL : in  std_logic; -- Only asserted for PCHL.  PC <- (HL)
           SP_HL : in  std_logic; -- Only asserted for SPHL.  SP <- (HL)
           HL_WZ : in  std_logic; -- Only asserted for XTHL.  HL <- (WZ)
         pc_jump : in  std_logic -- For jump, call, return.  PC <- (WZ)+1
            -- -- Debug signals (Feel free to leave connected to open)
  -- WZ, BC, DE, HL : out std_logic_vector(15 downto 0); -- Register pairs
  -- SP_out, PC_out : out std_logic_vector(15 downto 0)  -- Stack pointer and program counter
            );
   end component;

   component control_unit is
      port (
-- Regular signals
                  clk : in  std_logic;
                   CE : in  std_logic;
                   IR : in  std_logic_vector(7 downto 0);
                reset : in  std_logic;
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
                 SYNC : out std_logic;

-- Internal Control signals (These control the ALU, Register Array and everything else)
      -- Accumulator
      AccumulatorRead : out std_logic;
     AccumulatorWrite : out std_logic;
    AccumulatorBypass : out std_logic; -- Let BUS bypass into ACT. Facilitates BUS->ACT
AccumulatorComplement : out std_logic; -- ~A->A
      -- Accumulator Latch
AccumulatorLatchEnable : out std_logic; -- A->ACT
      -- Temp
          TempRegRead : out std_logic; -- BUS->TMP
         TempRegWrite : out std_logic; -- TMP->BUS
      -- Flags
            FlagsRead : out std_logic; -- BUS->FLAGS
           FlagsWrite : out std_logic; -- FLAGS->BUS
              FlagsCY : out std_logic; -- Only CY flag is changed if this is set
             FlagsCMC : out std_logic; -- ~CY->CY
             FlagsSTC : out std_logic; -- 1->CY
                Flags : in  std_logic_vector(4 downto 0); -- Used for testing conditions to jump or stuff

      -- Data Bus Buffer/Latch
         DataBusERead : out std_logic; -- Put external data bus on internal data bus
        DataBusEWrite : out std_logic; -- Put internal data bus on external data bus
         DataBusIRead : out std_logic;
        DataBusIWrite : out std_logic;
      -- Instruction Register
             IREnable : out std_logic;
      -- Register Array
      register_select : out std_logic_vector(2 downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
          byte_select : out std_logic; -- '1' means high byte
              WZ_both : out std_logic; -- '1' means write both bytes of W and Z
               WZ_RST : out std_logic; -- Used to set 0->W and RST->Z
              --RST_NNN : out std_logic_vector(2 downto 0); -- Used only during RST
                 -- Read/write signals
            take_data : out std_logic; -- asserted when register reads data from bus
            give_data : out std_logic; -- asserted when register writes data to bus
                 -- Control signals
            -- Increment/decrement register pair
              inc_dec : out std_logic; -- '1' means increment, '0' means decrement. Implemented for all register pairs. Note that decrement is never used for WZ and PC.
              operate : out std_logic; -- '1' means perform increment/decrement operation
        update_select : out std_logic_vector(2 downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
            -- Out status
        status_select : out std_logic_vector(2 downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
        status_update : out std_logic; -- '1' means update address to current value of register pair
        status_active : out std_logic; -- '1' means address line has high impedence.
            -- A few exceptions
                HL_DE : out std_logic; -- Only asserted for XCHG. (HL)<->(DE)
                PC_HL : out std_logic; -- Only asserted for PCHL.  PC <- (HL)
                SP_HL : out std_logic; -- Only asserted for SPHL.  SP <- (HL)
                HL_WZ : out std_logic; -- Only asserted for XTHL.  HL <- (WZ)
              pc_jump : out std_logic; -- For jump, call, return.  PC <- (WZ)+1
      -- ALU
            operation : out ALU_Function;
           ALU_enable : out std_logic
      );
   end component;

   -- ALU signals
   signal Flags_ALU : std_logic_vector(4 downto 0);
   signal Flags_byte : std_logic_vector(7 downto 0);

   -- Control Unit  signals
   signal AccumulatorRead : std_logic;
   signal AccumulatorWrite : std_logic;
   signal AccumulatorBypass : std_logic;
   signal AccumulatorComplement : std_logic;
   signal AccumulatorLatchEnable : std_logic;
   signal TempRegRead : std_logic;
   signal TempRegWrite : std_logic;
   signal FlagsRead : std_logic;
   signal FlagsWrite : std_logic;
   signal FlagsCY : std_logic;
   signal FlagsCMC : std_logic;
   signal FlagsSTC : std_logic;
   signal DataBusERead : std_logic;
   signal DataBusEWrite : std_logic;
   signal DataBusIRead : std_logic;
   signal DataBusIWrite : std_logic;
   signal IREnable : std_logic;
   signal register_select : std_logic_vector(2 downto 0);
   signal byte_select : std_logic;
   signal WZ_both : std_logic;
   signal WZ_RST : std_logic;
   signal take_data : std_logic;
   signal give_data : std_logic;
   signal inc_dec : std_logic;
   signal operate : std_logic;
   signal update_select : std_logic_vector(2 downto 0);
   signal status_select : std_logic_vector(2 downto 0);
   signal status_update : std_logic;
   signal status_active : std_logic;
   signal HL_DE : std_logic;
   signal PC_HL : std_logic;
   signal SP_HL : std_logic;
   signal HL_WZ : std_logic;
   signal pc_jump : std_logic;
   signal operation : ALU_Function;
   signal ALU_enable : std_logic;

   -- signal ra_data_bus : std_logic_vector(7 downto 0);
   -- signal alu_data_bus : std_logic_vector(7 downto 0);
   signal RAdataOUT : std_logic_vector(7 downto 0);
   signal ALUdataOUT : std_logic_vector(7 downto 0);
begin

   Inst_CU : control_unit port map (
                     clk => clk,
                      CE => CE,
                      IR => InstReg,
                   reset => reset,
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
                    SYNC => SYNC,
         AccumulatorRead => AccumulatorRead,
        AccumulatorWrite => AccumulatorWrite,
       AccumulatorBypass => AccumulatorBypass,
   AccumulatorComplement => AccumulatorComplement,
  AccumulatorLatchEnable => AccumulatorLatchEnable,
             TempRegRead => TempRegRead,
            TempRegWrite => TempRegWrite,
               FlagsRead => FlagsRead,
              FlagsWrite => FlagsWrite,
                 FlagsCY => FlagsCY,
                FlagsCMC => FlagsCMC,
                FlagsSTC => FlagsSTC,
                   Flags => Flags,
            DataBusERead => DataBusERead,
           DataBusEWrite => DataBusEWrite,
            DataBusIRead => DataBusIRead,
           DataBusIWrite => DataBusIWrite,
                IREnable => IREnable,
         register_select => register_select,
             byte_select => byte_select,
                 WZ_both => WZ_both,
                  WZ_RST => WZ_RST,
               take_data => take_data,
               give_data => give_data,
                 inc_dec => inc_dec,
                 operate => operate,
           update_select => update_select,
           status_select => status_select,
           status_update => status_update,
           status_active => status_active,
                   HL_DE => HL_DE,
                   PC_HL => PC_HL,
                   SP_HL => SP_HL,
                   HL_WZ => HL_WZ,
                 pc_jump => pc_jump,
               operation => operation,
              ALU_enable => ALU_enable
   );

   Inst_ALU : ALU port map (
                       A => AccumulatorLatch,
                       B => TempReg,
               operation => operation,
                  enable => ALU_enable,
                flags_in => Flags,
               flags_out => Flags_ALU,
                       C => ALUdataOUT
   );

   Inst_RA : register_array port map (
                     clk => clk,
                      CE => CE,
                   reset => reset,
                  dataIN => dataBus,
                 dataOUT => RAdataOUT,
                 address => address,
         register_select => register_select,
             byte_select => byte_select,
                 WZ_both => WZ_both,
                  WZ_RST => WZ_RST,
                 RST_NNN => InstReg(5 downto 3),
               take_data => take_data,
               give_data => give_data,
                 inc_dec => inc_dec,
                 operate => operate,
           update_select => update_select,
           status_select => status_select,
           status_update => status_update,
           status_active => status_active,
                   HL_DE => HL_DE,
                   PC_HL => PC_HL,
                   SP_HL => SP_HL,
                   HL_WZ => HL_WZ,
                 pc_jump => pc_jump
                      -- WZ => WZ,      -- Debug signals
                      -- BC => BC,      -- Debug signals
                      -- DE => DE,      -- Debug signals
                      -- HL => HL,      -- Debug signals
                  -- SP_out => SP,      -- Debug signals
                  -- PC_out => PC       -- Debug signals
   );

   Flags_byte <= Sign & Zero & '0' & ACarry & '0' & Parity & '1' & Carry;
   -- PSW <= Accumulator & Flags_byte; -- Debug A and FLAG registers

   dataBus <= Accumulator when AccumulatorWrite = '1' else
              TempReg     when TempRegWrite     = '1' else
              Flags_byte  when FlagsWrite       = '1' else
              DBLatch     when DataBusIWrite    = '1' else
              RAdataOUT   when give_data        = '1' else
              ALUdataOUT  when ALU_enable       = '1' else
             (others=>'Z');

   -- data <= DBLatch when (DataBusEWrite='1') and (reset='0') else (others=>'Z');
   dataOUT <= DBLatch;

   process(clk)
   begin
      if rising_edge(clk) and CE = '1' then
         -- Accumulator
         if    AccumulatorRead='1' then
            Accumulator <= dataBus;
         elsif AccumulatorComplement='1' then
            Accumulator <= not Accumulator;
         end if;

         -- AccumulatorLatch
         if AccumulatorLatchEnable='1' then
            if AccumulatorBypass='1' then
               AccumulatorLatch <= dataBus;
            else
               AccumulatorLatch <= Accumulator;
            end if;
         end if;

         -- Temp
         if TempRegRead='1' then TempReg <= dataBus; end if;

         -- Flags
         if    FlagsRead='1' then
            Sign   <= dataBus(7);
            Zero   <= dataBus(6);
            -- ignore dataBus(5)
            ACarry <= dataBus(4);
            -- ignore dataBus(3)
            Parity <= dataBus(2);
            -- ignore dataBus(1)
            Carry  <= dataBus(0);
         elsif FlagsCY='1'  then Carry <= Flags_ALU(0);
         elsif FlagsCMC='1' then Carry <= not Carry;
         elsif FlagsSTC='1' then Carry <= '1';
         else                    Flags <= Flags_ALU;
         end if;

         -- Data Bus Buffer/Latch
         if    DataBusERead='1' then DBLatch <= dataIN;
         elsif DataBusIRead='1' then DBLatch <= dataBus;
         end if;

         -- InstructionRegister
         if IREnable='1' then InstReg <= dataBus; end if;
      end if;
   end process;

end Behavioral;