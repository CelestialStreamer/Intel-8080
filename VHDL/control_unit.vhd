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
-- Description:    This device decodes the instruction and sends control signals to
--                   the other components of the CPU. This unit stores the machine
--                   cycle, and the current state.
--    
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_package.all;

entity control_unit is
         port (
-- Regular signals
                     clk : in  std_logic;
                      CE : in  std_logic;
                      IR : in  std_logic_vector(7 downto 0);
                   reset : in  std_logic; -- A high on the RESET line will always reset the 8080 to state T1;
                                          -- RESET also clears the program counter.
-- Status information signals (Originally broadcast on data line before actual data)
                    INTA : out std_logic; -- Asserted during machine cycles: 8, 10
                                          -- Acknowledge signal for INTERRUPT request.
                                          -- Signal should be used to gate a restart
                                          -- instruction onto the data bus when DBIN is active.
                      WO : out std_logic; -- Asserted during machine cycles: 1, 2, 4, 6, 8, 9, 10
                                          -- Active Low
                                          -- Indicates that the operation in the current machine
                                          -- cycle will be a WRITE memory or OUTPUT function (~WO = 0).
                                          -- Otherwise, a READ memory or INPUT operation will be executed.
                   STACK : out std_logic; -- Asserted during machine cycles: 4, 5
                                          -- Indicates that the address bus holds the
                                          -- pushdown stack address from the Stack Pointer.
                    HLTA : out std_logic; -- Asserted during machine cycles: 9, 10
                                          -- Acknowledge signal for HALT instruction.
                  OUTPUT : out std_logic; -- Asserted during machine cycles: 7
                                          -- OUT in documentation
                                          -- Indicates that the address bus contains the
                                          -- address of an output device and the data
                                          -- bus will contain the output data when
                                          -- ~WR is active.
                     M_1 : out std_logic; -- Asserted during machine cycles: 1, 8, 10
                                          -- Provides a signal to indicate that the CPU
                                          -- is in the fetch cycle for the first byte of
                                          -- an instruction.
                   INPUT : out std_logic; -- Asserted during machine cycles: 6
                                          -- Indicates that the address bus contains the
                                          -- address of an input device and the input
                                          -- data should be placed on the data bus
                                          -- when DBIN is active.
                    MEMR : out std_logic; -- Asserted during machine cycles: 1, 2, 4, 9
                                          -- Designates that the data bus will be used
                                          -- for memory read data.
-- External Control signals (These come from outside the CPU)
         -- Write
                      WR : out std_logic; -- Active low write.
                                          -- Used when CPU outputs data.
                                          -- I think WR=0 means data line is valid and ready for reading by device (mem, i/o, etc.)
                                          -- (Page 47)
                                          -- WRITE; the ~WR signal is used for memory WRITE or I/O output
                                          -- control. The data on the data bus is stable while the ~WR signal is
                                          -- active low (~WR = 0).
         -- Data Bus Control
                    DBIN : out std_logic; -- During the input of data to the processor, the 8080 generates a DBIN
                                          -- signal which should be used externally to enable the transfer.
                                          -- Any Tw phases intervening between T2 and T3 will therefore extend
                                          -- DBIN by one or more clock periods.
                                          -- (Page 47)
                                          -- DATA BUS IN; the DBIN signal indicates to external circuits that
                                          -- the data bus is in the input mode. This signal should be used to
                                          -- enable the gating of data onto the 8080A data bus from memory or I/O.
         -- Interrupt Control
                    INTE : out std_logic; -- (Page 47)
                                          -- INTERRUPT ENABLE; indicates the content of the internal interrupt
                                          -- enable flip/flop. This flip/flop may be set or reset by the Enable
                                          -- and Disable Interrupt instructions and inhibits interrupts
                                          -- from being accepted by the CPU when it is reset. It is automatically
                                          -- reset (disabling further interrupts) at time T1 of the instruction
                                          -- fetch cycle (M1) when an interrupt is accepted and is
                                          -- also reset by the RESET signal.
                     INT : in  std_logic; -- (Page 47)
                                          -- INTERRUPT REQUEST; the CPU recognizes an interrupt request
                                          -- on this line at the end of the current instruction or while
                                          -- halted. If the CPU is in the HOLD state or if the Interrupt Enable
                                          -- flip/flop is reset it will not honor the request.
         -- Hold Control
                    HLDA : out std_logic; -- (Page 47)
                                          -- HOLD ACKNOWLEDGE; The HLDA signal appears in response
                                          -- to the HOLD signal and indicates that the data and address bus
                                          -- will go to the high impedance state. The HLDA signal begins at:
                                          --     * T3 for READ memory or input.
                                          --     * The Clock Period following T3 for WRITE memory or OUTPUT operation.
                                          -- In either case, the HLDA signal appears after the rising edge of phi_1
                                          -- and high impedance occurs after the rising edge of phi_2.
                    HOLD : in  std_logic; -- (Page 47)
                                          -- HOLD; The HOLD signal requests the CPU to enter the HOLD
                                          -- state. The HOLD state allows an external device to gain control
                                          -- of the 8080A address and data bus as soon as the 8080A has
                                          -- completed its use of these buses for the current machine cycle. It is
                                          -- recognized under the following conditions:
                                          --    * the CPU is in the HALT state.
                                          --    * the CPU is in the T2 or TW state and the READY signal is active.
                                          -- As a result of entering the HOLD stpte the CPU ADDRESS BUS
                                          -- (A15-A0) and DATA BUS (D7-D0) will be in their high impedance
                                          -- state. The CPU acknowledges its state with the HOLD ACKNOWLEDGE
                                          -- (HLDA) pin.
         -- Wait Control
                WAIT_ACK : out std_logic; -- Originally just called WAIT
                                          -- Entry into the TW state is indicated by a WAIT signal
                                          -- from the processor, acknowledging the memory's request.
                                          -- (Page 47)
                                          -- WAIT; the WAIT signal acknowledges that the CPU is in a WAIT state.
                   READY : in  std_logic; -- Once the processor has sent an address to memory,
                                          -- there is an opportunity for the memory to request a WAIT.
                                          -- This it does by pulling the processor's READY line low,
                                          -- prior to the "Ready set-up" interval (t_RS) which occurs
                                          -- during the phi_2 pulse within state T2 or Tw. As long as the
                                          -- READY line remains low, the processor will idle, giving the
                                          -- memory time to respond to the addressed data request.
                                          -- (Page 47)
                                          -- READY; the READY signal indicates to the 8080A that valid
                                          -- memory or input data is available on the 8080A data bus. This
                                          -- signal is used to synchronize the CPU with slower memory or I/O
                                          -- devices. If after sending an address out the 8080A does not receive
                                          -- a READY input, the 8080A will enter a WAIT state for as
                                          -- long as the READY line is low. READY can also be used to single
                                          -- step the CPU.
         -- Sync
                    SYNC : out std_logic; -- The SYNC signal identifies the first state (T1) in every machine cycle.
                                          -- (Page 47)
                                          -- SYNCHRONIZING SIGNAL; the SYNC pin provides a signal to
                                          -- indicate the beginning of each machine cycle.
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
            DataBusERead : out std_logic;
           DataBusEWrite : out std_logic;
            DataBusIRead : out std_logic;
           DataBusIWrite : out std_logic;
         -- Instruction Register
                IREnable : out std_logic;
         -- Register Array
         register_select : out std_logic_vector(2 downto 0); -- Select register pair. (0,WZ) (1,BC) (2,DE) (3,HL) (4,SP) (5,PC)
             byte_select : out std_logic; -- '1' means high byte
                 WZ_both : out std_logic; -- '1' means write both bytes of W and Z
                  WZ_RST : out std_logic; -- Used to set 0->W and RST->Z
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
              ALU_enable : out std_logic);
end control_unit;

architecture Behavioral of control_unit is
   signal MOV_r1_r2, MOV_r_M, MOV_M_r, SPHL, MVI_r_data, MVI_M_data, LXI_rp_data, LDA_addr, STA_addr, LHLD_addr, SHLD_addr, LDAX_rp, STAX_rp, XCHG, ALU_r, ALU_M, ALU_data, INR_DCR_r, INR_DCR_M, INX_DCX_rp, DAD_rp, DAA, ROTATE, CMA_CMC, STC, JMP_addr, J_cond_addr, CALL_addr, C_cond_addr, RET, R_cond_addr, RST_n, PCHL, PUSH_rp, PUSH_PSW, POP_rp, POP_PSW, XTHL, IN_port, OUT_port, EI_DI, HLT, NOP : boolean;

   -- Parts of Instruction Register decoded if needed
   alias SSS       : std_logic_vector(2 downto 0) is IR(2 downto 0); -- Source register
   alias DDD       : std_logic_vector(2 downto 0) is IR(5 downto 3); -- Destination register
   alias Condition : std_logic_vector(2 downto 0) is IR(5 downto 3); -- Condition code
   alias math_code : std_logic_vector(2 downto 0) is IR(5 downto 3); -- Math operation
   alias rot_code  : std_logic_vector(1 downto 0) is IR(4 downto 3); -- Rotation operation
   alias RP        : std_logic_vector(1 downto 0) is IR(5 downto 4); -- Register pair
   
   signal RP_Select : std_logic_vector(2 downto 0); -- Used as convertion signal for 2-bit "Register Pair" to format used here
   
   -- These are used as assignment to RP_Select
   constant W  : std_logic_vector(2 downto 0) := "000";
   constant B  : std_logic_vector(2 downto 0) := "001";
   constant D  : std_logic_vector(2 downto 0) := "010";
   constant H  : std_logic_vector(2 downto 0) := "011";
   constant SP : std_logic_vector(2 downto 0) := "100";
   constant PC : std_logic_vector(2 downto 0) := "101";

   type MachineStateType is (M1,M2,M3,M4,M5);
   type StateType is (T1,T2,TW,T3,T4,T5,TWH,HM1,HM2); -- HM1 is HOLD MODE on lower half of page 7. HM2 is on upper half.

   signal M_nxt, M_cur : MachineStateType; -- Machine Cycle
   signal T_nxt, T_cur : StateType;        -- Current State (3-5 for each Machine cycle)
         
   signal InstCompleted : boolean; -- Instruction completed
   
   signal int_ff  : std_logic; -- Internal INT  F/F   CPU processes Interrupt when this is set.
   signal inte_ff : std_logic; -- Internal INTE F/F   Set/Reset with certain instructions. Reset after interrupt request.
   signal halt_ff : std_logic; -- Internal HALT F/F   Flag to determine if CPU enters HALT MODE.
   signal hold_ff : std_logic; -- Internal HOLD F/F   CPU enters HOLD state if this is set.

   signal alu_ff       : std_logic; -- If set, the ALU performs an operation
   signal alu_request  : std_logic; -- signal to set alu_ff

   signal jump_ff      : std_logic; -- If set, then pc jump occurs. (And sometimes operations shortened)
   signal jump_request : std_logic; -- signal to set jump_ff
   
   signal DataBusEWriteSignal : std_logic; -- Set external data bus to internal data bus
   signal DataBusEReadSignal  : std_logic; -- Set internal data bus to external data bus
   signal DataBusEReadReg     : std_logic; -- Register to store external data bus value (Used in case memory is one cycle ahead)
   
   signal status     : std_logic_vector(7 downto 0); -- Status bus
   signal statusReg  : std_logic_vector(7 downto 0); -- Register to store Status Bus for current machine cycle

   constant COMPLETED : boolean := false; -- For use as argument 'expression' in following procedure
   procedure hold_or_T1(
             signal          M_nxt : out MachineStateType;
             signal          T_nxt : out StateType;
                           hold_ff : in  std_logic;
                        M_continue : in  MachineStateType; -- Next machine cycle if instruction has more
                        expression : in  boolean; -- true=instruction is not finished and needs another Machine cycle
             signal  InstCompleted : out boolean) is
   begin
      if hold_ff='1' then T_nxt <= HM1; -- Go to hold state if HOLD F/F is set
      else                T_nxt <= T1;  -- else go to T1
      end if;
      
      InstCompleted <= not expression;
      
      if expression then M_nxt <= M_continue; -- If instruction NOT completed, continue to next Machine cycle,
      else               M_nxt <= M1;         -- otherwise go to M1. (That means move onto next instruction)
      end if;
   end  hold_or_T1;

   function alu_math_op(math_code : std_logic_vector(2 downto 0)) return ALU_Function is
   begin
      if    math_code="000" then return ADD;
      elsif math_code="001" then return ADD_WITH_CARRY;
      elsif math_code="010" then return SUBTRACT;
      elsif math_code="011" then return SUBTRACT_WITH_CARRY;
      elsif math_code="100" then return LOGICAL_AND;
      elsif math_code="101" then return LOGICAL_XOR;
      elsif math_code="110" then return LOGICAL_OR;
      else                       return COMPARE;
      end if;
   end alu_math_op;

   function alu_rot_op(rot_code : std_logic_vector(1 downto 0)) return ALU_Function is
   begin
      if    rot_code="00" then return ROTATELEFT;
      elsif rot_code="01" then return ROTATERIGHT;
      elsif rot_code="10" then return ROTATELEFT_THROUGH_CARRY;
      else                     return ROTATERIGHT_THROUGH_CARRY;
      end if;
   end alu_rot_op;

   function test(test_code : std_logic_vector(2 downto 0); Flags : std_logic_vector(4 downto 0)) return boolean is
      alias Sign   : std_logic is Flags(4); -- Bit 7
      alias Zero   : std_logic is flags(3); -- Bit 6
      alias ACarry : std_logic is Flags(2); -- Bit 4  Unused
      alias Parity : std_logic is Flags(1); -- Bit 2
      alias Carry  : std_logic is Flags(0); -- Bit 0
   begin
      if    test_code="000" then return Zero   ='0'; -- Not Zero
      elsif test_code="001" then return Zero   ='1'; -- Zero
      elsif test_code="010" then return Carry  ='0'; -- No Carry
      elsif test_code="011" then return Carry  ='1'; -- Carry
      elsif test_code="100" then return Parity ='0'; -- Parity odd
      elsif test_code="101" then return Parity ='1'; -- Parity even
      elsif test_code="110" then return Sign   ='0'; -- Plus
      else                       return Sign   ='1'; -- Minus
      end if;
   end test;

begin
   status(0) <= int_ff;
   status(1) <= '1' when (M_cur=M1) or
                        ((M_cur=M2) and not (MOV_M_r    or STAX_rp   or RST_n or PUSH_rp or PUSH_PSW)) or
                        ((M_cur=M3) and not (MVI_M_data or INR_DCR_M or RST_n or PUSH_rp or PUSH_PSW or OUT_port)) or
                        ((M_cur=M4) and (LDA_addr or LHLD_addr)) or
                        ((M_cur=M5) and (LHLD_addr))
                    else '0';
   status(2) <= '1' when (((M_cur=M2) or (M_cur=M3)) and (RET or R_cond_addr or RST_n or PUSH_rp or PUSH_PSW or POP_rp or POP_PSW or XTHL)) or
                         (((M_cur=M4) or (M_cur=M5)) and (CALL_addr or C_cond_addr or XTHL))
                    else '0';
   status(3) <= halt_ff;
   status(4) <= '1' when  (M_cur=M3) and OUT_port else '0';
   status(5) <= '1' when   M_cur=M1  and (halt_ff='0') else '0';
   status(6) <= '1' when  (M_cur=M3) and IN_port else '0';
   status(7) <= '1' when ((M_cur=M1) and (int_ff/='1')) or
                         ((M_cur=M2) and not (MOV_M_r    or STAX_rp   or RST_n or PUSH_rp or PUSH_PSW)) or
                         ((M_cur=M3) and not (MVI_M_data or INR_DCR_M or RST_n or PUSH_rp or PUSH_PSW or IN_port or OUT_port)) or
                         ((M_cur=M4) and (LDA_addr or LHLD_addr)) or
                         ((M_cur=M5) and (LHLD_addr)) or
                          (halt_ff='1')
                     else '0';

   -- Status output of CPU must be the same for entire machine cycle
   -- Some operations may change the status signal, but the register
   -- is used to keep it steady for duration of machine cycle.
   STATUS_REGISTER:
   process(clk, status)
   begin
      if rising_edge(clk) and CE = '1' then
         if T_cur=T1 then
            statusReg <= status;
         end if;
      end if;
   end process;
   
   -- Status information signals
   INTA   <= status(0) when T_cur=T1 else statusReg(0);
   WO     <= status(1) when T_cur=T1 else statusReg(1);
   STACK  <= status(2) when T_cur=T1 else statusReg(2);
   HLTA   <= status(3) when T_cur=T1 else statusReg(3);
   OUTPUT <= status(4) when T_cur=T1 else statusReg(4);
   M_1    <= status(5) when T_cur=T1 else statusReg(5);
   INPUT  <= status(6) when T_cur=T1 else statusReg(6);
   MEMR   <= status(7) when T_cur=T1 else statusReg(7);
      
   -- External control signals
   WR       <= not DataBusEWriteSignal;
   DBIN     <= DataBusEReadSignal when T_cur/=TW else DataBusEReadReg; -- If it's on, it should be only during T2-T3.
   INTE     <= inte_ff;
   HLDA     <= '1' when (T_cur=HM1) or (T_cur=HM2) else '0'; -- 89% sure that this is correct. Not sure about the timing though...
   WAIT_ACK <= '1' when T_cur=TW or T_cur=TWH else '0';
   SYNC     <= '1' when (T_cur = T1) and not (DAD_rp and not (M_cur=M1)) else '0'; -- SYNC does not occur in the second and third machine cycles of a DAD instruction (Page 3)

   -- Internal control signals
   DATA_BUS_REGISTER:
   process(clk)
   begin
      if rising_edge(clk) and CE = '1' then
         if T_cur/=TW then
            DataBusEReadReg <= DataBusEReadSignal; -- Use signal from last cycle if in hold mode
         end if;
      end if;
   end process;
   DataBusERead <= DataBusEReadSignal when T_cur/=TW else DataBusEReadReg;
   DataBusEWrite <= DataBusEWriteSignal;

   -- Register Pair for some opcodes (this is just a simple conversion)
   RP_Select <= B when RP="00" else
                D when RP="01" else
                H when RP="10" else
                SP; -- RP="11"

   -- Instruction decoder
   HLT         <= std_match(IR,"01110110");
   MOV_r_M     <= std_match(IR,"01---110") and not HLT;
   MOV_M_r     <= std_match(IR,"01110---") and not HLT;
   MOV_r1_r2   <= std_match(IR,"01------") and not (MOV_r_M or MOV_M_r) and not HLT;
   SPHL        <= std_match(IR,"11111001");
   MVI_M_data  <= std_match(IR,"00110110");
   MVI_r_data  <= std_match(IR,"00---110") and not MVI_M_data;
   LXI_rp_data <= std_match(IR,"00--0001");
   LDA_addr    <= std_match(IR,"00111010");
   STA_addr    <= std_match(IR,"00110010");
   LHLD_addr   <= std_match(IR,"00101010");
   SHLD_addr   <= std_match(IR,"00100010");
   LDAX_rp     <= std_match(IR,"00--1010") and not (LHLD_addr or LDA_addr); -- Only B and D may be specified
   STAX_rp     <= std_match(IR,"00--0010") and not (SHLD_addr or STA_addr); -- Only B and D may be specified
   XCHG        <= std_match(IR,"11101011");
   ALU_M       <= std_match(IR,"10---110");
   ALU_r       <= std_match(IR,"10------") and not ALU_M;
   ALU_data    <= std_match(IR,"11---110");
   INR_DCR_M   <= std_match(IR,"0011010-");
   INR_DCR_r   <= std_match(IR,"00---10-") and not INR_DCR_M;
   INX_DCX_rp  <= std_match(IR,"00---011");
   DAD_rp      <= std_match(IR,"00--1001");
   DAA         <= std_match(IR,"00100111");
   ROTATE      <= std_match(IR,"000--111");
   CMA_CMC     <= std_match(IR,"001-1111");
   STC         <= std_match(IR,"00110111");
   JMP_addr    <= std_match(IR,"11000011"); -- Could use 1100-011 to match real cpu.
   J_cond_addr <= std_match(IR,"11---010");
   CALL_addr   <= std_match(IR,"11001101"); -- Could use 11--1101 to match real cpu.
   C_cond_addr <= std_match(IR,"11---100");
   RET         <= std_match(IR,"11001001"); -- Could use 110-1001 to match real cpu.
   R_cond_addr <= std_match(IR,"11---000");
   RST_n       <= std_match(IR,"11---111");
   PCHL        <= std_match(IR,"11101001");
   PUSH_PSW    <= std_match(IR,"11110101");
   PUSH_rp     <= std_match(IR,"11--0101") and not PUSH_PSW;
   POP_PSW     <= std_match(IR,"11110001");
   POP_rp      <= std_match(IR,"11--0001") and not POP_PSW;
   XTHL        <= std_match(IR,"11100011");
   IN_port     <= std_match(IR,"11011011");
   OUT_port    <= std_match(IR,"11010011");
   EI_DI       <= std_match(IR,"1111-011");
   NOP         <= std_match(IR,"00000000");

   STATE_REGISTER:
   process(clk, reset, M_nxt)
   begin
      if reset = '1' then
         M_cur <= M_nxt;
         T_cur <= T1;
      elsif rising_edge(clk) and CE = '1' then
         M_cur <= M_nxt;
         T_cur <= T_nxt;
      end if;
   end process;

   ALU_REGISTER:
   process(clk,reset,T_cur)
   begin
      if reset='1' then
         alu_ff <= '0';
      elsif rising_edge(clk)and CE = '1' then
         -- Synchronize ALU request with clock signal
         if alu_request='1' then
            alu_ff <= '1';
         elsif T_cur=T2 then
            alu_ff <= '0';
         end if;
      end if;
   end process;
   
   PC_JUMP_REGISTER:
   process(clk,reset,M_cur,T_cur)
   begin
      if reset='1' then
         jump_ff <= '0';
      elsif rising_edge(clk) and CE = '1' then
         -- Synchronize PC jump request with clock signal
         if jump_request='1' then
            jump_ff <= '1';
         elsif (M_cur=M1) and (T_cur=T3) then
            jump_ff <= '0';
         end if;
      end if;
   end process;
   
   INT_REGISTER:
   process(clk,reset, M_cur, T_cur)
   begin
      if reset='1' then
         inte_ff <= '0';
         int_ff <= '0';
      elsif rising_edge(clk) and CE = '1' then
         if    T_cur=T1 then if int_ff='1' then inte_ff <= '0'; end if; -- INTE F/F is reset if internal INT F/F is set. (Page 7, note 1).
         elsif T_cur=T2 then if inte_ff='0' then int_ff <= '0'; end if; -- Internal INT F/F is reset if INTE F/F is reset. (Page 7, note 2).
         elsif M_cur=M1 and T_cur=T4 and EI_DI then
            inte_ff <= IR(3);
         elsif ((InstCompleted and hold_ff='0') or T_cur=TWH) and INT='1' and inte_ff='1' then
            int_ff <= '1';
         end if;
      end if;
   end process;
   
   HOLD_REGISTER:
   process(clk,reset,T_cur)
   begin
      if reset='1' then
         hold_ff <= '0'; -- Page 47
      elsif rising_edge(clk) and CE = '1' then
         if T_cur=T2 and ((READY='1') and (halt_ff='0')) and (HOLD='1') then
            hold_ff <= '1'; -- Set internal HOLD F/F if HOLD='1'
         elsif T_cur=TWH and (HOLD='1') then
            hold_ff <= '1'; -- Set Internal HOLD F/F
         elsif (T_cur=HM1 or T_cur=HM2) and HOLD='0' then
            hold_ff <= '0'; -- Reset Internal HOLD F/F
         end if;
      end if;
   end process;
   
   HALT_REGISTER:
   process(clk,reset,T_cur)
   begin
      if reset='1' then
         halt_ff <= '0';
      elsif rising_edge(clk) and CE = '1' then
         if M_cur=M1 and T_cur=T4 and HLT then
            halt_ff <= '1';
         elsif T_cur=TWH and (INT='1') and (inte_ff='1') then -- Halt State (Page 13)
            halt_ff <= '0'; -- Reset HLTA
         end if;
      end if;
   end process;
   
   NEXT_STATE_DECODER: -- And InstCompleted too
   process(reset, INT, READY, HOLD, T_cur, M_cur,
           halt_ff, hold_ff, jump_ff, inte_ff,
           HLT,MOV_r_M,MOV_M_r,MOV_r1_r2,SPHL,MVI_M_data,MVI_r_data,LXI_rp_data,LDA_addr,STA_addr,LHLD_addr,SHLD_addr,LDAX_rp,STAX_rp,XCHG,ALU_M,ALU_r,ALU_data,INR_DCR_M,INR_DCR_r,INX_DCX_rp,DAD_rp,DAA,ROTATE,CMA_CMC,STC,JMP_addr,J_cond_addr,CALL_addr,C_cond_addr,RET,R_cond_addr,RST_n,PCHL,PUSH_PSW,PUSH_rp,POP_PSW,POP_rp,XTHL,IN_port,OUT_port,EI_DI,NOP)
   begin
      if reset='1' then
         T_nxt <= T1;
         M_nxt <= M1;
         InstCompleted <= false;
      else
         InstCompleted <= false;
         -- Next State Decoder
         case T_cur is
            when T1 =>
               M_nxt <= M_cur; T_nxt <= T2; -- T2 always follows T1 of any machine cycle
            when T2 =>
               M_nxt <= M_cur;
               if (READY='0') or (halt_ff='1') then
                  if (halt_ff='1') then T_nxt <= TWH; else T_nxt <= Tw; end if;
               else -- (READY='1')and(halt_ff='0')
                  T_nxt <= T3; -- T3 always follows T2 of any machine cycle.
               end if;
            when TW =>
               M_nxt <= M_cur;
               if READY = '1' then T_nxt <= T3; -- Resume next cycle (T3 always follows T2 of any machine cycle)
               else                T_nxt <= TW; -- Unless there is still a wait signal
               end if;
            when T3 =>
               case M_cur is
                  when M1 => M_nxt <= M1; T_nxt <= T4; -- T4 is used by all in M1
                  when M2 => hold_or_T1(M_nxt,T_nxt,hold_ff, M3, MVI_M_data or LXI_rp_data or LDA_addr or STA_addr or LHLD_addr or SHLD_addr or INR_DCR_M or DAD_rp or JMP_addr or J_cond_addr or CALL_addr or  C_cond_addr                    or RET or R_cond_addr or RST_n or PUSH_rp or PUSH_PSW or POP_rp or POP_PSW or XTHL or IN_port or OUT_port, InstCompleted);
                  when M3 => hold_or_T1(M_nxt,T_nxt,hold_ff, M4,                              LDA_addr or STA_addr or LHLD_addr or SHLD_addr                                                   or CALL_addr or (C_cond_addr and (jump_ff='1'))                                                                            or XTHL, InstCompleted);
                  when M4 => hold_or_T1(M_nxt,T_nxt,hold_ff, M5,                                                      LHLD_addr or SHLD_addr                                                   or CALL_addr or  C_cond_addr                                                                            or XTHL, InstCompleted);
                  when M5 => -- M5 T3
                     if XTHL then M_nxt <= M5; T_nxt <= T4; -- Only operation to go to T4-M5
                     else    hold_or_T1(M_nxt,T_nxt,hold_ff, M1, COMPLETED, InstCompleted); -- What few operations got here are finished
                     end if;
               end case;
            when T4 =>
               case M_cur is
                  when M1 => -- M1 T4
                     if MOV_r1_r2 or SPHL or INR_DCR_r or INX_DCX_rp or J_cond_addr or CALL_addr or C_cond_addr or R_cond_addr or RST_n or PCHL or PUSH_rp or PUSH_PSW then
                        M_nxt <= M1; T_nxt <= T5; -- Stay for T5
                     else
                        hold_or_T1(M_nxt,T_nxt,hold_ff, M2, not (XCHG or ALU_r or DAA or ROTATE or CMA_CMC or STC or EI_DI or HLT or NOP), InstCompleted); -- Added HLT to this because I feel HLT actually finishes at M1-T4.
                     end if;
                  when others => -- M5 T4 is only valid states. But I'll treat M2-4 T4 the same for brevity.
                     M_nxt <= M5; T_nxt <= T5; -- Only one code XTHL goes to M5-T5 from here.
               end case;
            when T5 =>
               if M_cur=M1 then hold_or_T1(M_nxt,T_nxt,hold_ff,M2,J_cond_addr or CALL_addr or C_cond_addr or (R_cond_addr and (jump_ff='1')) or RST_n or PCHL or PUSH_rp or PUSH_PSW, InstCompleted);
               else             hold_or_T1(M_nxt,T_nxt,hold_ff,M1,COMPLETED, InstCompleted);
               end if;
            when TWH => -- Halt State (Page 13)
               M_nxt <= M_cur;
               if     HOLD='1'                   then T_nxt <= HM2; -- Stay in hold mode
               elsif (INT='1') and (inte_ff='1') then T_nxt <= T1;  -- Resume normal flow
               else                                   T_nxt <= TWH; -- Stay in wait state
               end if;
            when HM1 => -- DATA and ADDRESS lines should be high impedance
               M_nxt <= M_cur;
               if HOLD='1' then T_nxt <= HM1;
               else             T_nxt <= T1; -- Resume normal flow
               end if;
            when HM2 => -- DATA and ADDRESS lines should be high impedance
               M_nxt <= M_cur;
               if HOLD='1' then T_nxt <= HM2;
               else             T_nxt <= TWH;
               end if;
         end case;
      end if; -- rising_edge(clk)
   end process;

   OUTPUT_DECODER: -- Output decoder
   process(M_cur,T_cur,
           MOV_r1_r2, MOV_r_M, MOV_M_r, SPHL, MVI_r_data, MVI_M_data, LXI_rp_data, LDA_addr, STA_addr, LHLD_addr, SHLD_addr, LDAX_rp, STAX_rp, XCHG, ALU_r, ALU_M, ALU_data, INR_DCR_r, INR_DCR_M, INX_DCX_rp, DAD_rp, DAA, ROTATE, CMA_CMC, STC, JMP_addr, J_cond_addr, CALL_addr, C_cond_addr, RET, R_cond_addr, RST_n, PCHL, PUSH_rp, PUSH_PSW, POP_rp, POP_PSW, XTHL, IN_port, OUT_port, EI_DI, HLT, NOP,
           jump_ff, rot_code, math_code, alu_ff, int_ff, halt_ff, SSS, DDD, RP_Select, IR, Condition, Flags)
   begin
      AccumulatorRead <= '0';
      AccumulatorWrite <= '0';
      AccumulatorBypass <= '0';
      AccumulatorComplement <= '0';
      AccumulatorLatchEnable <= '0';
      TempRegRead <= '0';
      TempRegWrite <= '0';
      FlagsRead <= '0';
      FlagsWrite <= '0';
      FlagsCY <= '0';
      FlagsCMC <= '0';
      FlagsSTC <= '0';
      DataBusEReadSignal <= '0';
      DataBusEWriteSignal <= '0';
      DataBusIRead <= '0';
      DataBusIWrite <= '0';
      IREnable <= '0';
      register_select <= "000";
      byte_select <= '0';
      WZ_both <= '0';
      WZ_RST <= '0';
      take_data <= '0';
      give_data <= '0';
      inc_dec <= '0';
      operate <= '0';
      update_select <= "000";
      status_select <= "000";
      status_update <= '0';
      status_active <= '0';
      HL_DE <= '0';
      PC_HL <= '0';
      SP_HL <= '0';
      HL_WZ <= '0';
      pc_jump <= '0';
      operation <= NONE;
      ALU_enable <= '0';

      alu_request <= '0';
      jump_request <= '0';

      if (T_cur = HM1) or (T_cur = HM2) or  -- If in HOLD MODE...
         (T_cur = T4)  or (T_cur = T5) then -- or T4-T5...
         status_active <= '1'; -- ...address line is high-impedance
      end if;

      -- Cover the easy T1-T3 in M1
      if M_cur=M1 then
         if    T_cur=T1 then -- PC OUT STATUS
            status_update <= '1';
            if jump_ff = '1' then status_select <= W;  -- Jump instruction replaces subcycle of next instruction
            else                  status_select <= PC; -- Normal mode
            end if;
         elsif T_cur=T2 then -- PC=PC+1
            update_select <= PC; operate <= not halt_ff; -- Update PC if not in halt state
            pc_jump <= jump_ff; -- Use WZ as previous PC if previous instruction jumped
            inc_dec <= not int_ff; -- Increment PC if there is no interrupt
            
            if alu_ff='1' then -- Math opcode is still available since IR hasn't changed
               if ROTATE then operation <= alu_rot_op(rot_code); -- Rotation operation
               else           operation <= alu_math_op(math_code); -- Math operation
               end if;
               if ROTATE or (alu_math_op(math_code) /= COMPARE) then
                  AccumulatorRead <= '1'; -- Accumulator loads value during next clock edge
               end if;
               ALU_enable <= '1'; -- Also updates Flags during this operation
            end if;
            if halt_ff='0' then
               DataBusEReadSignal <= '1';
            end if;
         elsif T_cur=T3 then -- INST->TMP/IR
            -- if halt_ff='0' then
               -- DataBusEReadSignal <= '1';
            -- end if;
            DataBusIWrite <= '1';
            TempRegRead <= '1';
            IREnable <= '1';
            
            AccumulatorLatchEnable <= '1'; -- Really only useful for DAA
         end if;
      end if;

      -- The rest
      if    MOV_r1_r2   then
         if    M_cur=M1 and T_cur=T4 then -- (SSS)->TMP
            if    SSS="111" then AccumulatorWrite <= '1';
            elsif SSS="000" then register_select <= B; byte_select <= '1'; give_data <= '1';
            elsif SSS="001" then register_select <= B; byte_select <= '0'; give_data <= '1';
            elsif SSS="010" then register_select <= D; byte_select <= '1'; give_data <= '1';
            elsif SSS="011" then register_select <= D; byte_select <= '0'; give_data <= '1';
            elsif SSS="100" then register_select <= H; byte_select <= '1'; give_data <= '1';
            elsif SSS="101" then register_select <= H; byte_select <= '0'; give_data <= '1';
            end if;
            TempRegRead <= '1';
         elsif M_cur=M1 and T_cur=T5 then -- (TMP)->DDD
            TempRegWrite <= '1';
            if    DDD="111" then AccumulatorRead <= '1';
            elsif DDD="000" then register_select <= B; byte_select <= '1'; take_data <= '1';
            elsif DDD="001" then register_select <= B; byte_select <= '0'; take_data <= '1';
            elsif DDD="010" then register_select <= D; byte_select <= '1'; take_data <= '1';
            elsif DDD="011" then register_select <= D; byte_select <= '0'; take_data <= '1';
            elsif DDD="100" then register_select <= H; byte_select <= '1'; take_data <= '1';
            elsif DDD="101" then register_select <= H; byte_select <= '0'; take_data <= '1';
            end if;
         end if;
      elsif MOV_r_M     then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- HL OUT STATUS
            status_update <= '1'; status_select <= H;
         elsif M_cur=M2 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1'; -- Read external data bus
         elsif M_cur=M2 and T_cur=T3 then --                DDD
            DataBusIWrite <= '1'; -- Write data bus to internal data bus
            if    DDD="111" then AccumulatorRead <= '1';
            elsif DDD="000" then register_select <= B; byte_select <= '1'; take_data <= '1';
            elsif DDD="001" then register_select <= B; byte_select <= '0'; take_data <= '1';
            elsif DDD="010" then register_select <= D; byte_select <= '1'; take_data <= '1';
            elsif DDD="011" then register_select <= D; byte_select <= '0'; take_data <= '1';
            elsif DDD="100" then register_select <= H; byte_select <= '1'; take_data <= '1';
            elsif DDD="101" then register_select <= H; byte_select <= '0'; take_data <= '1';
            end if;
         end if;
      elsif MOV_M_r     then
         if    M_cur=M1 and T_cur=T4 then -- (SSS)->TMP
            if    SSS="111" then AccumulatorWrite <= '1';
            elsif SSS="000" then register_select <= B; byte_select <= '1'; give_data <= '1';
            elsif SSS="001" then register_select <= B; byte_select <= '0'; give_data <= '1';
            elsif SSS="010" then register_select <= D; byte_select <= '1'; give_data <= '1';
            elsif SSS="011" then register_select <= D; byte_select <= '0'; give_data <= '1';
            elsif SSS="100" then register_select <= H; byte_select <= '1'; give_data <= '1';
            elsif SSS="101" then register_select <= H; byte_select <= '0'; give_data <= '1';
            end if;
            TempRegRead <= '1';
         elsif M_cur=M2 and T_cur=T1 then -- HL OUT STATUS
            status_update <= '1'; status_select <= H;
         elsif M_cur=M2 and T_cur=T2 then --          (TMP)->
            TempRegWrite <= '1';
            DataBusIRead <= '1'; -- Write to data bus latch
         elsif M_cur=M2 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1'; -- Transmit data bus contents
         end if;
      elsif SPHL        then
         if    M_cur=M1 and T_cur=T4 then --          (HL)->
            SP_HL <= '1';
         elsif M_cur=M1 and T_cur=T5 then --                SP
            -- Unused
         end if;
      elsif MVI_r_data  then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                DDD
            DataBusIWrite <= '1';
            if    DDD="111" then AccumulatorRead <= '1';
            elsif DDD="000" then register_select <= B; byte_select <= '1'; take_data <= '1';
            elsif DDD="001" then register_select <= B; byte_select <= '0'; take_data <= '1';
            elsif DDD="010" then register_select <= D; byte_select <= '1'; take_data <= '1';
            elsif DDD="011" then register_select <= D; byte_select <= '0'; take_data <= '1';
            elsif DDD="100" then register_select <= H; byte_select <= '1'; take_data <= '1';
            elsif DDD="101" then register_select <= H; byte_select <= '0'; take_data <= '1';
            end if;
         end if;
      elsif MVI_M_data  then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                TMP
            DataBusIWrite <= '1';
            TempRegRead <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- HL OUT STATUS
            status_update <= '1'; status_select <= H;
         elsif M_cur=M3 and T_cur=T2 then --          (TMP)->
            TempRegWrite <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif LXI_rp_data then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                rl
            DataBusIWrite <= '1';
            register_select <= RP_Select; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                rh
            DataBusIWrite <= '1';
            register_select <= RP_Select; byte_select <= '1'; take_data <= '1';
         end if;
      elsif LDA_addr    then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M4 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                A
            DataBusIWrite <= '1';
            AccumulatorRead <= '1';
         end if;
      elsif STA_addr    then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M4 and T_cur=T2 then --          (A)-->
            AccumulatorWrite <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif LHLD_addr   then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M4 and T_cur=T2 then -- WZ=WZ+1  DATA->
            update_select <= W; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                L
            DataBusIWrite <= '1';
            register_select <= H; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M5 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M5 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1';
         elsif M_cur=M5 and T_cur=T3 then --                H
            DataBusIWrite <= '1';
            register_select <= H; byte_select <= '1'; take_data <= '1';
         end if;
      elsif SHLD_addr   then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            DataBusEReadSignal <= '1';
            update_select <= PC; inc_dec <= '1'; operate <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            DataBusEReadSignal <= '1';
            update_select <= PC; inc_dec <= '1'; operate <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M4 and T_cur=T2 then -- WZ=WZ+1  (L)-->
            update_select <= W; inc_dec <= '1'; operate <= '1';
            register_select <= H; byte_select <= '0'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M5 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M5 and T_cur=T2 then --          (H)-->
            register_select <= H; byte_select <= '1'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M5 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif LDAX_rp     then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- rp OUT STATUS
            status_update <= '1'; status_select <= RP_Select;
         elsif M_cur=M2 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                A
            DataBusIWrite <= '1';
            AccumulatorRead <= '1';
         end if;
      elsif STAX_rp     then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- rp OUT STATUS
            status_update <= '1'; status_select <= RP_Select;
         elsif M_cur=M2 and T_cur=T2 then --          (A)-->
            AccumulatorWrite <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif XCHG        then
         if    M_cur=M1 and T_cur=T4 then -- (HL)<->(DE)
            HL_DE <= '1';
         end if;
      elsif ALU_r       then
         if    M_cur=M1 and T_cur=T4 then -- (SSS)->TMP (A)->ACT
            if    SSS="111" then AccumulatorWrite <= '1';
            elsif SSS="000" then register_select <= B; byte_select <= '1'; give_data <= '1';
            elsif SSS="001" then register_select <= B; byte_select <= '0'; give_data <= '1';
            elsif SSS="010" then register_select <= D; byte_select <= '1'; give_data <= '1';
            elsif SSS="011" then register_select <= D; byte_select <= '0'; give_data <= '1';
            elsif SSS="100" then register_select <= H; byte_select <= '1'; give_data <= '1';
            elsif SSS="101" then register_select <= H; byte_select <= '0'; give_data <= '1';
            end if;
            TempRegRead <= '1';
            AccumulatorLatchEnable <= '1';
            alu_request <= '1'; -- Perform operation during next instruction fetch
         end if;
      elsif ALU_M       then
         if    M_cur=M1 and T_cur=T4 then -- (A)->ACT
            AccumulatorLatchEnable <= '1';
         elsif M_cur=M2 and T_cur=T1 then -- HL OUT STATUS
            status_update <= '1'; status_select <= H;
         elsif M_cur=M2 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                TMP
            DataBusIWrite <= '1';
            TempRegRead <= '1';
            alu_request <= '1'; -- Perform operation during next instruction fetch
         end if;
      elsif ALU_data    then
         if    M_cur=M1 and T_cur=T4 then -- (A)->ACT
            AccumulatorLatchEnable <= '1';
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                TMP
            DataBusIWrite <= '1';
            TempRegRead <= '1';
            alu_request <= '1'; -- Perform operation during next instruction fetch
         end if;
      elsif INR_DCR_r   then
         if    M_cur=M1 and T_cur=T4 then -- (DDD)->TMP (TMP)+/-1->ALU
            if    DDD="111" then AccumulatorWrite <= '1';
            elsif DDD="000" then register_select <= B; byte_select <= '1'; give_data <= '1';
            elsif DDD="001" then register_select <= B; byte_select <= '0'; give_data <= '1';
            elsif DDD="010" then register_select <= D; byte_select <= '1'; give_data <= '1';
            elsif DDD="011" then register_select <= D; byte_select <= '0'; give_data <= '1';
            elsif DDD="100" then register_select <= H; byte_select <= '1'; give_data <= '1';
            elsif DDD="101" then register_select <= H; byte_select <= '0'; give_data <= '1';
            end if;
            TempRegRead <= '1';
         elsif M_cur=M1 and T_cur=T5 then -- ALU->DDD
            if IR(0)='0' then operation <= INCREMENT; else operation <= DECREMENT; end if;
            ALU_enable <= '1';
            if    DDD="111" then AccumulatorRead <= '1';
            elsif DDD="000" then register_select <= B; byte_select <= '1'; take_data <= '1';
            elsif DDD="001" then register_select <= B; byte_select <= '0'; take_data <= '1';
            elsif DDD="010" then register_select <= D; byte_select <= '1'; take_data <= '1';
            elsif DDD="011" then register_select <= D; byte_select <= '0'; take_data <= '1';
            elsif DDD="100" then register_select <= H; byte_select <= '1'; take_data <= '1';
            elsif DDD="101" then register_select <= H; byte_select <= '0'; take_data <= '1';
            end if;
         end if;
      elsif INR_DCR_M   then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- HL OUT STATUS
            status_update <= '1'; status_select <= H;
         elsif M_cur=M2 and T_cur=T2 then -- DATA->   (TMP)+/-1-->
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --       TMP            ALU
            DataBusIWrite <= '1';
            TempRegRead <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- HL OUT STATUS
            status_update <= '1'; status_select <= H;
         elsif M_cur=M3 and T_cur=T2 then -- ALU-->
            if IR(0)='0' then operation <= INCREMENT; else operation <= DECREMENT; end if;
            ALU_enable <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M3 and T_cur=T3 then --       DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif INX_DCX_rp  then
         if    M_cur=M1 and T_cur=T4 then -- (rp)+/-1--->
            update_select <= RP_Select;
            if IR(3) = '0' then
               inc_dec <= '1'; -- '1' means increment
            else
               inc_dec <= '0'; -- '0' means decrement
            end if;
            operate <= '1';
         elsif M_cur=M1 and T_cur=T5 then --             rp
            -- Unused
         end if;
      elsif DAD_rp      then
      --DataBusEWriteSignal
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- (rl)->ACT
            register_select <= RP_Select; byte_select <= '0'; give_data <= '1';
            AccumulatorBypass <= '1'; -- Allows BUS to bypass Accumulator and go directly to ACT
            AccumulatorLatchEnable <= '1';
         elsif M_cur=M2 and T_cur=T2 then -- (L)->TMP (ACT)+(TMP)->ALU
            register_select <= H; byte_select <= '0'; give_data <= '1';
            TempRegRead <= '1';
         elsif M_cur=M2 and T_cur=T3 then -- ALU->L,CY
            ALU_enable <= '1'; operation <= ADD;
            register_select <= H; byte_select <= '0'; take_data <= '1';
            FlagsCY <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- (rh)->ACT
            register_select <= RP_Select; byte_select <= '1'; give_data <= '1';
            AccumulatorBypass <= '1';
            AccumulatorLatchEnable <= '1';
         elsif M_cur=M3 and T_cur=T2 then -- (H)->TMP (ACT)+(TMP)+CY->ALU
            register_select <= H; byte_select <= '1'; give_data <= '1';
            TempRegRead <= '1';
         elsif M_cur=M3 and T_cur=T3 then -- ALU->H,CY
            ALU_enable <= '1'; operation <= ADD_WITH_CARRY;
            register_select <= H; byte_select <= '1'; take_data <= '1';
            FlagsCY <= '1';
         end if;
      elsif DAA         then
         if    M_cur=M1 and T_cur=T4 then -- DAA->A,FLAGS
            operation <= DECIMAL_ADJUST;
            ALU_enable <= '1';
            AccumulatorRead <= '1';
         end if;
      elsif ROTATE      then
         if    M_cur=M1 and T_cur=T4 then -- (A)[,CY]->ALU  ROTATE
            AccumulatorLatchEnable <= '1'; -- Unlike chart, I'm loading A->ATC->ALU vs A->ALU. Just like the arithmetic ALU operations.
            alu_request <= '1';
         end if;
      elsif CMA_CMC     then
         if    M_cur=M1 and T_cur=T4 then -- not A/CY->A/CY
            if IR(4) = '1' then
               FlagsCMC <= '1';
            else
               AccumulatorComplement <= '1';
            end if;
         end if;
      elsif STC         then
         if    M_cur=M1 and T_cur=T4 then -- 1->CY
            FlagsSTC <= '1';
         end if;
      elsif JMP_addr    then
         if    M_cur=M1 and T_cur=T4 then -- X
            jump_request <= '1';
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            DataBusEReadSignal <= '1';
            update_select <= PC; inc_dec <= '1'; operate <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         end if;
      elsif J_cond_addr then
         if    M_cur=M1 and T_cur=T4 then -- JUDGE CONDITION
            if test(Condition, Flags) then
               jump_request <= '1';
            end if;
         elsif M_cur=M1 and T_cur=T5 then -- JUDGE CONDITION
            -- Unused
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS - Jump has occured
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         end if;
      elsif CALL_addr   then
         if    M_cur=M1 and T_cur=T4 then -- SP=SP-1
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            jump_request <= '1';
         elsif M_cur=M1 and T_cur=T5 then -- SP=SP-1
            -- Unused
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  B3--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M4 and T_cur=T2 then -- SP=SP-1 (PCH)->
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            register_select <= PC; byte_select <= '1'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M5 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M5 and T_cur=T2 then --         (PCL)->
            register_select <= PC; byte_select <= '0'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M5 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif C_cond_addr then
         if    M_cur=M1 and T_cur=T4 then -- JUDGE CONDITION    IF TRUE, SP=SP-1
            if test(Condition, Flags) then
               jump_request <= '1';
               update_select <= SP; inc_dec <= '0'; operate <= '1';
            end if;
         elsif M_cur=M1 and T_cur=T5 then -- JUDGE CONDITION
            -- Unused
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS - Jump has occured
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  DATA->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M3 and T_cur=T2 then -- PC=PC+1  DATA->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M4 and T_cur=T2 then -- SP=SP-1 (PCH)->
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            register_select <= PC; byte_select <= '1'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M5 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M5 and T_cur=T2 then --         (PCL)->
            register_select <= PC; byte_select <= '0'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M5 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif RET         then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
            jump_request <= '1';
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         end if;
      elsif R_cond_addr then
         if    M_cur=M1 and T_cur=T4 then -- JUDGE CONDITION
            if test(Condition, Flags) then
               jump_request <= '1';
            end if;
         elsif M_cur=M1 and T_cur=T5 then -- JUDGE CONDITION
            -- Unused
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         end if;
      elsif RST_n       then
         if    M_cur=M1 and T_cur=T4 then -- SP=SP-1
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            jump_request <= '1';
         elsif M_cur=M1 and T_cur=T5 then -- SP=SP-1
            -- T3 originally had 0->W. I'm doing that here now along with (TMP-00NNN000)->Z
            WZ_RST <= '1';
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP-1  (PCH)->
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            register_select <= PC; byte_select <= '1'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then --          (PCL)->        (TMP-00NNN000)->
            register_select <= PC; byte_select <= '0'; give_data <= '1';
            DataBusIRead <= '1';
            -- (TMP-00NNN000)->Z finished in earlier section
         elsif M_cur=M3 and T_cur=T3 then --                DATA BUS                Z
            DataBusEWriteSignal <= '1';
         end if;
      elsif PCHL        then
         if    M_cur=M1 and T_cur=T4 then --          (HL)->
            PC_HL <= '1';
         elsif M_cur=M1 and T_cur=T5 then --                PC
            -- Unused
         end if;
      elsif PUSH_rp     then
         if    M_cur=M1 and T_cur=T4 then -- SP=SP-1
            update_select <= SP; inc_dec <= '0'; operate <= '1';
         elsif M_cur=M1 and T_cur=T5 then -- SP=SP-1
            -- Unused
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP-1  (rh)->
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            register_select <= RP_Select; byte_select <= '1'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then --          (rl)->
            register_select <= RP_Select; byte_select <= '0'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif PUSH_PSW    then
         if    M_cur=M1 and T_cur=T4 then -- SP=SP-1
            update_select <= SP; inc_dec <= '0'; operate <= '1';
         elsif M_cur=M1 and T_cur=T5 then -- SP=SP-1
            -- Unused
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP-1  (A)-->
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            AccumulatorWrite <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then --          FLAGS->
            FlagsWrite <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif POP_rp      then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                rl
            DataBusIWrite <= '1';
            register_select <= RP_Select; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                rh
            DataBusIWrite <= '1';
            register_select <= RP_Select; byte_select <= '1'; take_data <= '1';
         end if;
      elsif POP_PSW     then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                FLAGS
            DataBusIWrite <= '1';
            FlagsRead <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                A
            DataBusIWrite <= '1';
            AccumulatorRead <= '1';
         end if;
      elsif XTHL        then -- Longest Operation!
         if    M_cur=M1 and T_cur=T4 then -- XCHG
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M2 and T_cur=T2 then -- SP=SP+1  DATA->
            update_select <= SP; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '0'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M3 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                W
            DataBusIWrite <= '1';
            register_select <= W; byte_select <= '1'; take_data <= '1';
         elsif M_cur=M4 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M4 and T_cur=T2 then -- SP=SP-1  (H)-->                     **NOTE: Added SP=SP-1 because it was missing
            update_select <= SP; inc_dec <= '0'; operate <= '1';
            register_select <= H; byte_select <= '1'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M4 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M5 and T_cur=T1 then -- SP OUT STATUS
            status_update <= '1'; status_select <= SP;
         elsif M_cur=M5 and T_cur=T2 then --          (L)-->
            register_select <= H; byte_select <= '0'; give_data <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M5 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         elsif M_cur=M5 and T_cur=T4 then --          (WZ)->
            HL_WZ <= '1';
         elsif M_cur=M5 and T_cur=T5 then --                HL
            -- Unused
         end if;
      elsif IN_port     then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z,W
            DataBusIWrite <= '1';
            WZ_both <= '1'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M3 and T_cur=T2 then --          DATA->
            DataBusEReadSignal <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                A
            DataBusIWrite <= '1';
            AccumulatorRead <= '1';
         end if;
      elsif OUT_port    then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         elsif M_cur=M2 and T_cur=T1 then -- PC OUT STATUS
            status_update <= '1'; status_select <= PC;
         elsif M_cur=M2 and T_cur=T2 then -- PC=PC+1  B2--->
            update_select <= PC; inc_dec <= '1'; operate <= '1';
            DataBusEReadSignal <= '1';
         elsif M_cur=M2 and T_cur=T3 then --                Z,W
            DataBusIWrite <= '1';
            WZ_both <= '1'; take_data <= '1';
         elsif M_cur=M3 and T_cur=T1 then -- WZ OUT STATUS
            status_update <= '1'; status_select <= W;
         elsif M_cur=M3 and T_cur=T2 then --          (A)-->
            AccumulatorWrite <= '1';
            DataBusIRead <= '1';
         elsif M_cur=M3 and T_cur=T3 then --                DATA BUS
            DataBusEWriteSignal <= '1';
         end if;
      elsif EI_DI       then
         if    M_cur=M1 and T_cur=T4 then -- SET/RESET INTE F/F
            -- The setting of the INTE F/F is handled in the Next State Decoder.
         end if;
      elsif HLT         then
         if    M_cur=M1 and T_cur=T4 then -- Just set internal halt f/f.
            -- The setting of the HALT F/F is handled in the Next State Decoder.
         end if;
      elsif NOP         then
         if    M_cur=M1 and T_cur=T4 then -- X
            -- Do nothing
         end if;
      end if;
   end process;

end Behavioral;