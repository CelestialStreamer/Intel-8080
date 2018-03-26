library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_package.all;

entity ALU is
   port (
          A, B : in  std_logic_vector (7 downto 0);
     operation : in  ALU_Function;
        enable : in  std_logic;
      flags_in : in  std_logic_vector (4 downto 0);
     flags_out : out std_logic_vector (4 downto 0);
             C : out std_logic_vector (7 downto 0));
end ALU;

architecture behavioral of ALU is
   signal zero, sign, parity, carry, auxiliary_carry : std_logic;
   signal result : std_logic_vector(7 downto 0);

   alias sign_in            : std_logic is flags_in(4); -- Bit 7
   alias zero_in            : std_logic is flags_in(3); -- Bit 6
   alias auxiliary_carry_in : std_logic is flags_in(2); -- Bit 4
   alias parity_in          : std_logic is flags_in(1); -- Bit 2
   alias carry_in           : std_logic is flags_in(0); -- Bit 0

   procedure other_flags(A : in std_logic_vector(7 downto 0); signal parity, zero, sign : out std_logic) is
   begin
      parity <= not (A(7) xor A(6) xor A(5) xor A(4) xor A(3) xor A(2) xor A(1) xor A(0));
      if A=(A'range=>'0') then
         zero <= '1';
      else
         zero <= '0';
      end if;
      sign <= A(7);
   end other_flags;

   -- Computes A + B
   procedure add_AB(A, B : in  std_logic_vector(7 downto 0);        Ci      : in  std_logic;
             signal Sum  : out std_logic_vector(7 downto 0); signal Co, ACo : out std_logic) is
      variable Cout, Cin : std_logic;
   begin
      Cin := Ci;
      for i in 0 to 7 loop
         Cout := (A(i) and B(i)) or (A(i) and Cin) or (B(i) and Cin);
         Sum(i) <= A(i) xor B(i) xor Cin;
         Cin := Cout;
         if i=3 then ACo <= Cout; end if;
      end loop;
      Co <= Cout; -- Carry is set to carry out of bit 8
   end add_AB;

   -- Computes A - B
   procedure sub   (A, B : in  std_logic_vector(7 downto 0);        Ci      : in  std_logic;
          signal    Dif  : out std_logic_vector(7 downto 0); signal Co, ACo : out std_logic) is
      variable AdjustB : unsigned(7 downto 0);
   begin
      AdjustB := unsigned(B);
      if Ci = '1' then AdjustB := AdjustB + 1; end if;
      if AdjustB             > unsigned(A)             then Co  <= '1'; else Co  <= '0'; end if;
      if AdjustB(3 downto 0) > unsigned(A(3 downto 0)) then ACo <= '1'; else ACo <= '0'; end if;
      Dif <= std_logic_vector(unsigned(A) - AdjustB);
   end sub;

   -- Decimal Adjust Accumulator
   procedure DAA   (A    : in  std_logic_vector(7 downto 0);        Ci, ACi : in  std_logic;
          signal  result : out std_logic_vector(7 downto 0); signal Co, ACo : out std_logic) is
      variable Cout, Cin : std_logic;
      variable temp  : unsigned(7 downto 0);
      constant X06 : std_logic_vector(7 downto 0) := X"06";
      constant X60 : std_logic_vector(7 downto 0) := X"60";
   begin
      temp := unsigned(A);
      Cin := Ci;
      
      if (temp(3 downto 0) > 9) or (ACi = '1') then
         if temp(3 downto 0) > 9 then ACo <= '1';
         else                         ACo <= '0';
         end if;
         temp := temp + 6;
      else
         ACo <= '0';
      end if;
      
      if (temp(7 downto 4) > 9) or (Ci = '1') then
         if temp(7 downto 4) > 9 then Co <= '1';
         else                         Co <= '0';
         end if;
         temp := temp + 96; -- 0x60
      else
         Co <= '0';
      end if;
      
      result <= std_logic_vector(temp);
   end DAA;
begin
   flags_out <= sign & zero & auxiliary_carry & parity & carry;

   C <= result;

   process(A,B,operation,enable,flags_in,result,carry_in,auxiliary_carry_in) is
   begin
      -- Default action for flags is to leave them unchanged
      zero <= zero_in;
      sign <= sign_in;
      parity <= parity_in;
      carry <= carry_in;
      auxiliary_carry <= auxiliary_carry_in;
      result <= (others=>'0');

      -- Execute appropriate operation
      if enable='1' then
         case operation is
            when ADD =>
               add_AB(A,B,'0',result,carry,auxiliary_carry);
               other_flags(result,parity,zero,sign);
            when ADD_WITH_CARRY =>
               add_AB(A,B,carry_in,result,carry,auxiliary_carry);
               other_flags(result,parity,zero,sign);
            when SUBTRACT =>
               sub(A,B,'0',result,carry,auxiliary_carry);
               other_flags(result,parity,zero,sign);
            when SUBTRACT_WITH_CARRY =>
               sub(A,B,carry_in,result,carry,auxiliary_carry);
               other_flags(result,parity,zero,sign);

            when LOGICAL_AND =>
               result <= A and B;
               carry <= '0'; auxiliary_carry <= '0';
               other_flags(result,parity,zero,sign);
            when LOGICAL_XOR =>
               result <= A xor B;
               carry <= '0'; auxiliary_carry <= '0';
               other_flags(result,parity,zero,sign);
            when LOGICAL_OR =>
               result <= A or B;
               carry <= '0'; auxiliary_carry <= '0';
               other_flags(result,parity,zero,sign);
            when COMPARE =>
               sub(A,B,'0',result,carry,auxiliary_carry); -- It is up to the controller to disable output
               other_flags(result,parity,zero,sign);

            when ROTATELEFT =>                -- RLC
               result <= A(6 downto 0) & A(7);
               carry  <= A(7);
            when ROTATERIGHT =>               -- RRC
               result <= A(0) & A(7 downto 1);
               carry  <= A(0);
            when ROTATELEFT_THROUGH_CARRY =>  -- RAL
               result <= A(6 downto 0) & carry_in;
               carry  <= A(7);
            when ROTATERIGHT_THROUGH_CARRY => -- RAR
               result <= carry_in & A(7 downto 1);
               carry  <= A(0);
            
            when INCREMENT =>
               result <= std_logic_vector(unsigned(B) + 1);
               if B(3 downto 0) = "1111" then auxiliary_carry <= '1'; else auxiliary_carry <= '0'; end if;
               other_flags(result,parity,zero,sign);
            when DECREMENT =>
               result <= std_logic_vector(unsigned(B) - 1);
               if B(3 downto 0) = "0000" then auxiliary_carry <= '1'; else auxiliary_carry <= '0'; end if;
               other_flags(result,parity,zero,sign);

            when DECIMAL_ADJUST =>
               DAA(A, carry_in, auxiliary_carry_in, result, carry, auxiliary_carry);
               other_flags(result,parity,zero,sign);
            when others =>
         end case;
      end if;
   end process;

end behavioral;