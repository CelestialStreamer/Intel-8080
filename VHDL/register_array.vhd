----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
-- 
-- Create Date:    20:37:50 11/22/2013 
-- Design Name:    
-- Module Name:    register_array - Behavioral 
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions: 
-- Description:
--    Register array found in the Intel 8080 CPU.
--    There are three general purpose registers, one temporary register,
--    the stack pointer register and the program counter register.
--    Each register can be read/written to/from the data bus with one byte at a time.
--    Increment/decrement operation on most registers.
--    Some special operations.
--    
--    +----------+----------+
--    |   High   |   Low    |
--    +----------+----------+
--    |    W     |    Z     | Temporary (Hidden from program)
--    |    B     |    C     | General Purpose
--    |    D     |    E     | General Purpose
--    |    H     |    L     | General Purpose
--    |    Stack Pointer    | Special
--    |   Program Coutner   | Special
--    +----------+----------+
--
-- Dependencies:   None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_array is
      port ( clk : in  std_logic;
              CE : in  std_logic;
           reset : in  std_logic;
          dataIN : in  std_logic_vector(7  downto 0);
         dataOUT : out std_logic_vector(7  downto 0);
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
end register_array;

architecture Behavioral of register_array is
   -- Registers
   signal W,Z : std_logic_vector(7 downto 0); -- Temporary registers
   signal B,C : std_logic_vector(7 downto 0); -- General purpose registers
   signal D,E : std_logic_vector(7 downto 0); -- General purpose registers
   signal H,L : std_logic_vector(7 downto 0); -- General purpose registers
   signal SP, PC : std_logic_vector(15 downto 0); -- Stack pointer and program counter
   
   alias SP_H : std_logic_vector(7 downto 0) is SP(15 downto 8);
   alias SP_L : std_logic_vector(7 downto 0) is SP(7 downto 0);
   alias PC_H : std_logic_vector(7 downto 0) is PC(15 downto 8);
   alias PC_L : std_logic_vector(7 downto 0) is PC(7 downto 0);
   
   -- Select signals
   signal select_W, select_Z : boolean;
   signal select_B, select_C : boolean;
   signal select_D, select_E : boolean;
   signal select_H, select_L : boolean;
   signal select_SP_H, select_SP_L: boolean;
   signal select_PC_H, select_PC_L: boolean;
   
   constant Z16 : std_logic_vector(address'range) := (address'range=>'0');
   constant Z8  : std_logic_vector(dataOUT'range) := (dataOUT'range=>'0');
   
   signal addressReg : std_logic_vector(address'range) := (address'range=>'0');
begin
   -- WZ <= W & Z;BC <= B & C;DE <= D & E;HL <= H & L;SP_out <= SP;PC_out <= PC; -- Debug only
   
   -- Put contents of register pair to address line. Default is program counter
   address <= Z16 when status_active = '1' or reset = '1' else -- address line is zero (documentation calls for high impedence)
              W&Z when status_update = '1' and status_select = "000" else
              B&C when status_update = '1' and status_select = "001" else
              D&E when status_update = '1' and status_select = "010" else
              H&L when status_update = '1' and status_select = "011" else
              SP  when status_update = '1' and status_select = "100" else
              PC  when status_update = '1' and status_select = "101" else
              addressReg;
              
   -- Select what byte of which register is being used
   select_W    <= byte_select = '1' and register_select = "000";
   select_Z    <= byte_select = '0' and register_select = "000";
   select_B    <= byte_select = '1' and register_select = "001";
   select_C    <= byte_select = '0' and register_select = "001";
   select_D    <= byte_select = '1' and register_select = "010";
   select_E    <= byte_select = '0' and register_select = "010";
   select_H    <= byte_select = '1' and register_select = "011";
   select_L    <= byte_select = '0' and register_select = "011";
   select_SP_H <= byte_select = '1' and register_select = "100";
   select_SP_L <= byte_select = '0' and register_select = "100";
   select_PC_H <= byte_select = '1' and register_select = "101";
   select_PC_L <= byte_select = '0' and register_select = "101";

   -- This assignment takes care of writing register byte to the bus.
   dataOUT<= Z8 when give_data = '0' else
           W    when select_W        else
           Z    when select_Z        else
           B    when select_B        else
           C    when select_C        else
           D    when select_D        else
           E    when select_E        else
           H    when select_H        else
           L    when select_L        else
           SP_H when select_SP_H     else
           SP_L when select_SP_L     else
           PC_H when select_PC_H     else
           PC_L; -- when select_PC_L;
   
   -- Process handles all assignments into each register.
   -- There are six different types of assignments.
   -- (1) Register assigned value from data bus.
   -- (2) Register assigned with its value +/- 1.
   -- (3-6) Specific register assigned specific values
   process(clk, reset)
      variable result : std_logic_vector(15 downto 0) := (others=>'0');
   begin
      if reset = '1' then
         PC <= (others=>'0'); -- Only the PC is reset.
      elsif rising_edge(clk) and CE = '1' then
         if status_update = '1' then
            if    status_select = "000" then addressReg <= W&Z;
            elsif status_select = "001" then addressReg <= B&C;
            elsif status_select = "010" then addressReg <= D&E;
            elsif status_select = "011" then addressReg <= H&L;
            elsif status_select = "100" then addressReg <= SP;
            elsif status_select = "101" then addressReg <= PC;
            end if;
         end if;
      
         -- Special reset case if you will. Used during RST function
         if WZ_RST = '1' then
            W <= (others=>'0');
            Z <= "00"&RST_NNN&"000";
         end if;
         
         -- Register is assigned value from data bus. Register is selected based on select signals.
         if take_data = '1' then
            if    WZ_both='1' then W    <= dataIN; Z <= dataIN;
            elsif select_W    then W    <= dataIN;
            elsif select_Z    then Z    <= dataIN;
            elsif select_B    then B    <= dataIN;
            elsif select_C    then C    <= dataIN;
            elsif select_D    then D    <= dataIN;
            elsif select_E    then E    <= dataIN;
            elsif select_H    then H    <= dataIN;
            elsif select_L    then L    <= dataIN;
            elsif select_SP_H then SP_H <= dataIN;
            elsif select_SP_L then SP_L <= dataIN;
            elsif select_PC_H then PC_H <= dataIN;
            elsif select_PC_L then PC_L <= dataIN;
            end if;
         elsif operate = '1' then -- register <- register +/- 1
            if inc_dec = '1' then -- increment register pair
               case update_select is
                  when "000" => -- WZ
                     result := std_logic_vector(unsigned(W & Z) + 1);
                     W <= result(15 downto 8); Z <= result(7 downto 0);
                  when "001" => -- BC
                     result := std_logic_vector(unsigned(B & C) + 1);
                     B <= result(15 downto 8); C <= result(7 downto 0);
                  when "010" => -- DE
                     result := std_logic_vector(unsigned(D & E) + 1);
                     D <= result(15 downto 8); E <= result(7 downto 0);
                  when "011" => -- HL
                     result := std_logic_vector(unsigned(H & L) + 1);
                     H <= result(15 downto 8); L <= result(7 downto 0);
                  when "100" => -- SP
                     SP <= std_logic_vector(unsigned(SP) + 1);
                  when "101" => -- PC
                     if pc_jump='1' then PC <= std_logic_vector(unsigned(W&Z) + 1); -- WZ+1->PC
                     else                PC <= std_logic_vector(unsigned(PC)  + 1); -- PC+1->PC
                     end if;
                  when others => -- No register is selected. Should never happen
               end case;
            else -- decrement register pair
               case update_select is
                  when "000" => -- WZ (WZ never decremented)
                  when "001" => -- BC
                     result := std_logic_vector(unsigned(B & C) - 1);
                     B <= result(15 downto 8); C <= result(7 downto 0);
                  when "010" => -- DE
                     result := std_logic_vector(unsigned(D & E) - 1);
                     D <= result(15 downto 8); E <= result(7 downto 0);
                  when "011" => -- HL
                     result := std_logic_vector(unsigned(H & L) - 1);
                     H <= result(15 downto 8); L <= result(7 downto 0);
                  when "100" => -- SP
                     SP <= std_logic_vector(unsigned(SP) - 1);
                  when "101" => -- PC (PC never decremented)
                     if pc_jump='1' then PC <= W&Z; end if; -- WZ->PC if needed
                  when others => -- No register is selected. Should never happen.
               end case;
            end if;
         elsif PC_HL = '1' then -- PC <- (HL)
            PC <= H & L;
         elsif SP_HL = '1' then -- SP <- (HL)
            SP <= H & L;
         elsif HL_DE = '1' then --(HL)<->(DE)
            H <= D; D <= H;
            L <= E; E <= L;
         elsif HL_WZ = '1' then --(HL)<- (WZ)
            H <= W; L <= Z;
         end if;
      end if;
   end process;
   
end Behavioral;