library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_package is
   type ALU_Function is
   (
      ADD,
      ADD_WITH_CARRY,
      SUBTRACT,
      SUBTRACT_WITH_CARRY,
      LOGICAL_AND,
      LOGICAL_XOR,
      LOGICAL_OR,
      COMPARE,
            
      ROTATELEFT,
      ROTATERIGHT,
      ROTATELEFT_THROUGH_CARRY,
      ROTATERIGHT_THROUGH_CARRY,
      
      INCREMENT,
      DECREMENT,
      
      DECIMAL_ADJUST,
      
      NONE
   );
end;

package body alu_package is
end alu_package;