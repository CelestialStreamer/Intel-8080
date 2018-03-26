#include "State8080.h"

#include <algorithm>

#include "OpcodeFunctions.h"

#define FOR_CPUDIAG
#define DEBUG

#define CODE_1 ((opcode >> 3) & 0x7) // Grabs bits ..XX X...
#define CODE_2 ((opcode >> 0) & 0x7) // Grabs bits .... .XXX

void State8080::generateInterrupt(uint8_t opcode)
{
   interruptOpcode = opcode;
   interruptRequested = true;
}

int State8080::Emulate8080Op()
{
   if (stopped) // Halt state
      return 0;

   unsigned char opcode;

   if (interruptRequested && interrupt_enabled)
   {
      interrupt_enabled = false;
      interruptRequested = false;
      opcode = interruptOpcode; // Fetch interrupt opcode
      this->updatePC = false;
   }
   else
   {
      opcode = memory[Reg.pc]; // Fetch normal opcode
      this->updatePC = true;
   }

   switch (opcode)
   {          // Opcode Instruction size  flags          function
   // CARRY BIT INSTRUCTIONS: CMC, STC
   case 0x3F: // 0x3f   CMC         1     CY             CY <- !CY
   {
      Reg.f.c = !Reg.f.c;
      this->incrementPC(1);
      return 4; // 4 cycles
   }
   case 0x37: // 0x37   STC         1     CY             CY <- 1
   {
      Reg.f.c = 1;
      this->incrementPC(1);
      return 4; // 4 cycles
   }

   // SINGLE REGISTER INSTRUCTIONS: INR, DCR, CMA, DAA
   case 0x04: // 0x04   INR B       1     Z S P AC       B <- B+1
   case 0x0C: // 0x0c   INR C       1     Z S P AC       C <- C+1
   case 0x14: // 0x14   INR D       1     Z S P AC       D <- D+1
   case 0x1C: // 0x1c   INR E       1     Z S P AC       E <- E+1
   case 0x24: // 0x24   INR H       1     Z S P AC       H <- H+1
   case 0x2C: // 0x2c   INR L       1     Z S P AC       L <- L+1
   case 0x34: // 0x34   INR M       1     Z S P AC       (HL) <- (HL)+1
   case 0x3C: // 0x3c   INR A       1     Z S P AC       A <- A+1
   {
      INR(this, CODE_1);
      this->incrementPC(1);
      return 5; // 5 cycles
   }

   case 0x05: // 0x05   DCR B       1     Z S P AC       B <- B-1
   case 0x0D: // 0x0d   DCR C       1     Z S P AC       C <- C-1
   case 0x15: // 0x15   DCR D       1     Z S P AC       D <- D-1
   case 0x1D: // 0x1d   DCR E       1     Z S P AC       E <- E-1
   case 0x25: // 0x25   DCR H       1     Z S P AC       H <- H-1
   case 0x2D: // 0x2d   DCR L       1     Z S P AC       L <- L-1
   case 0x35: // 0x35   DCR M       1     Z S P AC       (HL) <- (HL)-1
   case 0x3D: // 0x3d   DCR A       1     Z S P AC       A <- A-1
   {
      DCR(this, CODE_1);
      this->incrementPC(1);
      return 5; // 5 cycles
   }

   case 0x2F: // 0x2f   CMA         1                    A <- !A
   {
      Reg.a = ~Reg.a;
      this->incrementPC(1);
      return 4; // 4 cycles
   }
   case 0x27: // 0x27   DAA         1     Z S P CY AC    special
   {
      DAA(this);
      this->incrementPC(1);
      return 4; // 4 cycles
   }

   // NOP INSTRUCTION
   case 0x00: // 0x00   NOP         1
   {
      this->incrementPC(1);
      return 4; // 4 cycles
   }

   // DATA TRANSFER INSTRUCTIONS: MOV, STAX, LDAX
   case 0x40: // 0x40   MOV BB      1                    B <- B
   case 0x41: // 0x41   MOV BC      1                    B <- C
   case 0x42: // 0x42   MOV BD      1                    B <- D
   case 0x43: // 0x43   MOV BE      1                    B <- E
   case 0x44: // 0x44   MOV BH      1                    B <- H
   case 0x45: // 0x45   MOV BL      1                    B <- L
   case 0x46: // 0x46   MOV BM      1                    B <- (HL)
   case 0x47: // 0x47   MOV BA      1                    B <- A
   case 0x48: // 0x48   MOV CB      1                    C <- B
   case 0x49: // 0x49   MOV CC      1                    C <- C
   case 0x4A: // 0x4a   MOV CD      1                    C <- D
   case 0x4B: // 0x4b   MOV CE      1                    C <- E
   case 0x4C: // 0x4c   MOV CH      1                    C <- H
   case 0x4D: // 0x4d   MOV CL      1                    C <- L
   case 0x4E: // 0x4e   MOV CM      1                    C <- (HL)
   case 0x4F: // 0x4f   MOV CA      1                    C <- A
   case 0x50: // 0x50   MOV DB      1                    D <- B
   case 0x51: // 0x51   MOV DC      1                    D <- C
   case 0x52: // 0x52   MOV DD      1                    D <- D
   case 0x53: // 0x53   MOV DE      1                    D <- E
   case 0x54: // 0x54   MOV DH      1                    D <- H
   case 0x55: // 0x55   MOV DL      1                    D <- L
   case 0x56: // 0x56   MOV DM      1                    D <- (HL)
   case 0x57: // 0x57   MOV DA      1                    D <- A
   case 0x58: // 0x58   MOV EB      1                    E <- B
   case 0x59: // 0x59   MOV EC      1                    E <- C
   case 0x5A: // 0x5a   MOV ED      1                    E <- D
   case 0x5B: // 0x5b   MOV EE      1                    E <- E
   case 0x5C: // 0x5c   MOV EH      1                    E <- H
   case 0x5D: // 0x5d   MOV EL      1                    E <- L
   case 0x5E: // 0x5e   MOV EM      1                    E <- (HL)
   case 0x5F: // 0x5f   MOV EA      1                    E <- A
   case 0x60: // 0x60   MOV HB      1                    H <- B
   case 0x61: // 0x61   MOV HC      1                    H <- C
   case 0x62: // 0x62   MOV HD      1                    H <- D
   case 0x63: // 0x63   MOV HE      1                    H <- E
   case 0x64: // 0x64   MOV HH      1                    H <- H
   case 0x65: // 0x65   MOV HL      1                    H <- L
   case 0x66: // 0x66   MOV HM      1                    H <- (HL)
   case 0x67: // 0x67   MOV HA      1                    H <- A
   case 0x68: // 0x68   MOV LB      1                    L <- B
   case 0x69: // 0x69   MOV LC      1                    L <- C
   case 0x6A: // 0x6a   MOV LD      1                    L <- D
   case 0x6B: // 0x6b   MOV LE      1                    L <- E
   case 0x6C: // 0x6c   MOV LH      1                    L <- H
   case 0x6D: // 0x6d   MOV LL      1                    L <- L
   case 0x6E: // 0x6e   MOV LM      1                    L <- (HL)
   case 0x6F: // 0x6f   MOV LA      1                    L <- A
   case 0x70: // 0x70   MOV MB      1                    (HL) <- B
   case 0x71: // 0x71   MOV MC      1                    (HL) <- C
   case 0x72: // 0x72   MOV MD      1                    (HL) <- D
   case 0x73: // 0x73   MOV ME      1                    (HL) <- E
   case 0x74: // 0x74   MOV MH      1                    (HL) <- H
   case 0x75: // 0x75   MOV ML      1                    (HL) <- L
   case 0x77: // 0x77   MOV MA      1                    (HL) <- A
   case 0x78: // 0x78   MOV AB      1                    A <- B
   case 0x79: // 0x79   MOV AC      1                    A <- C
   case 0x7A: // 0x7a   MOV AD      1                    A <- D
   case 0x7B: // 0x7b   MOV AE      1                    A <- E
   case 0x7C: // 0x7c   MOV AH      1                    A <- H
   case 0x7D: // 0x7d   MOV AL      1                    A <- L
   case 0x7E: // 0x7e   MOV AM      1                    A <- (HL)
   case 0x7F: // 0x7f   MOV AA      1                    A <- A
   {
      uint8_t dst = CODE_1; // 01DDDSSS
      uint8_t src = CODE_2; // 01DDDSSS
      getRegister(dst) = getRegister(src);

      this->incrementPC(1);
      return (dst == 6) || (src == 6) ? 7 : 5; // 7 cycles if memory operation, else 5 cycles
   }

   case 0x02: // 0x02   STAX B      1                    (BC) <- A
   {
      memory[Reg.b << 8 | Reg.c] = Reg.a;
      this->incrementPC(1);
      return 7; // 7 cycles
   }
   case 0x12: // 0x12   STAX D      1                    (DE) <- A
   {
      memory[Reg.d << 8 | Reg.e] = Reg.a;
      this->incrementPC(1);
      return 7; // 7 cycles
   }

   case 0x0A: // 0x0a   LDAX B      1                    A <- (BC)
   {
      Reg.a = memory[Reg.b << 8 | Reg.c];
      this->incrementPC(1);
      return 7; // 7 cycles
   }
   case 0x1A: // 0x1a   LDAX D      1                    A <- (DE)
   {
      Reg.a = memory[Reg.d << 8 | Reg.e];
      this->incrementPC(1);
      return 7; // 7 cycles
   }

   // REGISTER OR MEMORY TO ACCUMULATOR INSTRUCTIONS: ADD, ADC, SUB, SBB, ANA, XRA, ORA, CMP
   case 0x80: // 0x80   ADD B       1     Z S P CY AC    A <- A + B
   case 0x81: // 0x81   ADD C       1     Z S P CY AC    A <- A + C
   case 0x82: // 0x82   ADD D       1     Z S P CY AC    A <- A + D
   case 0x83: // 0x83   ADD E       1     Z S P CY AC    A <- A + E
   case 0x84: // 0x84   ADD H       1     Z S P CY AC    A <- A + H
   case 0x85: // 0x85   ADD L       1     Z S P CY AC    A <- A + L
   case 0x86: // 0x86   ADD M       1     Z S P CY AC    A <- A + (HL)
   case 0x87: // 0x87   ADD A       1     Z S P CY AC    A <- A + A
   case 0x88: // 0x88   ADC B       1     Z S P CY AC    A <- A + B + CY
   case 0x89: // 0x89   ADC C       1     Z S P CY AC    A <- A + C + CY
   case 0x8A: // 0x8a   ADC D       1     Z S P CY AC    A <- A + D + CY
   case 0x8B: // 0x8b   ADC E       1     Z S P CY AC    A <- A + E + CY
   case 0x8C: // 0x8c   ADC H       1     Z S P CY AC    A <- A + H + CY
   case 0x8D: // 0x8d   ADC L       1     Z S P CY AC    A <- A + L + CY
   case 0x8E: // 0x8e   ADC M       1     Z S P CY AC    A <- A + (HL) + CY
   case 0x8F: // 0x8f   ADC A       1     Z S P CY AC    A <- A + A + CY
   case 0x90: // 0x90   SUB B       1     Z S P CY AC    A <- A - B
   case 0x91: // 0x91   SUB C       1     Z S P CY AC    A <- A - C
   case 0x92: // 0x92   SUB D       1     Z S P CY AC    A <- A + D
   case 0x93: // 0x93   SUB E       1     Z S P CY AC    A <- A - E
   case 0x94: // 0x94   SUB H       1     Z S P CY AC    A <- A + H
   case 0x95: // 0x95   SUB L       1     Z S P CY AC    A <- A - L
   case 0x96: // 0x96   SUB M       1     Z S P CY AC    A <- A + (HL)
   case 0x97: // 0x97   SUB A       1     Z S P CY AC    A <- A - A
   case 0x98: // 0x98   SBB B       1     Z S P CY AC    A <- A - B - CY
   case 0x99: // 0x99   SBB C       1     Z S P CY AC    A <- A - C - CY
   case 0x9A: // 0x9a   SBB D       1     Z S P CY AC    A <- A - D - CY
   case 0x9B: // 0x9b   SBB E       1     Z S P CY AC    A <- A - E - CY
   case 0x9C: // 0x9c   SBB H       1     Z S P CY AC    A <- A - H - CY
   case 0x9D: // 0x9d   SBB L       1     Z S P CY AC    A <- A - L - CY
   case 0x9E: // 0x9e   SBB M       1     Z S P CY AC    A <- A - (HL) - CY
   case 0x9F: // 0x9f   SBB A       1     Z S P CY AC    A <- A - A - CY
   case 0xA0: // 0xa0   ANA B       1     Z S P CY AC    A <- A & B
   case 0xA1: // 0xa1   ANA C       1     Z S P CY AC    A <- A & C
   case 0xA2: // 0xa2   ANA D       1     Z S P CY AC    A <- A & D
   case 0xA3: // 0xa3   ANA E       1     Z S P CY AC    A <- A & E
   case 0xA4: // 0xa4   ANA H       1     Z S P CY AC    A <- A & H
   case 0xA5: // 0xa5   ANA L       1     Z S P CY AC    A <- A & L
   case 0xA6: // 0xa6   ANA M       1     Z S P CY AC    A <- A & (HL)
   case 0xA7: // 0xa7   ANA A       1     Z S P CY AC    A <- A & A
   case 0xA8: // 0xa8   XRA B       1     Z S P CY AC    A <- A ^ B
   case 0xA9: // 0xa9   XRA C       1     Z S P CY AC    A <- A ^ C
   case 0xAA: // 0xaa   XRA D       1     Z S P CY AC    A <- A ^ D
   case 0xAB: // 0xab   XRA E       1     Z S P CY AC    A <- A ^ E
   case 0xAC: // 0xac   XRA H       1     Z S P CY AC    A <- A ^ H
   case 0xAD: // 0xad   XRA L       1     Z S P CY AC    A <- A ^ L
   case 0xAE: // 0xae   XRA M       1     Z S P CY AC    A <- A ^ (HL)
   case 0xAF: // 0xaf   XRA A       1     Z S P CY AC    A <- A ^ A
   case 0xB0: // 0xb0   ORA B       1     Z S P CY AC    A <- A | B
   case 0xB1: // 0xb1   ORA C       1     Z S P CY AC    A <- A | C
   case 0xB2: // 0xb2   ORA D       1     Z S P CY AC    A <- A | D
   case 0xB3: // 0xb3   ORA E       1     Z S P CY AC    A <- A | E
   case 0xB4: // 0xb4   ORA H       1     Z S P CY AC    A <- A | H
   case 0xB5: // 0xb5   ORA L       1     Z S P CY AC    A <- A | L
   case 0xB6: // 0xb6   ORA M       1     Z S P CY AC    A <- A | (HL)
   case 0xB7: // 0xb7   ORA A       1     Z S P CY AC    A <- A | A
   case 0xB8: // 0xb8   CMP B       1     Z S P CY AC    A - B
   case 0xB9: // 0xb9   CMP C       1     Z S P CY AC    A - C
   case 0xBA: // 0xba   CMP D       1     Z S P CY AC    A - D
   case 0xBB: // 0xbb   CMP E       1     Z S P CY AC    A - E
   case 0xBC: // 0xbc   CMP H       1     Z S P CY AC    A - H
   case 0xBD: // 0xbd   CMP L       1     Z S P CY AC    A - L
   case 0xBE: // 0xbe   CMP M       1     Z S P CY AC    A - (HL)
   case 0xBF: // 0xbf   CMP A       1     Z S P CY AC    A - A
   {
      // Get which math operation is performed
      uint8_t op = CODE_1;

      // Get which register the operation will be performed on
      uint8_t reg = CODE_2;

      // Using function pointers, perform the operation
      math[op](this, getRegister(reg));

      // Update program counter
      this->incrementPC(1);
      return reg == 6 ? 7 : 4; // 7 cycles if memory access, else 4 cycles
   }

   // ROTATE ACCUMULATOR INSTRUCTIONS: RLC, RRC, RAL, RAR
   case 0x07: // 0x07   RLC         1     CY             A = A << 1; bit 0 = prev bit 7; CY = prev bit 7
   {
      /// Carry bit is set equal to the high-order bit of the accumulator
      Reg.f.c = ((Reg.a & 0x80) == 0x80);

      // Rotate to the right while wrapping first bit (7) to the last bit (0)
      Reg.a = ((Reg.a << 1) & 0xfe) | ((Reg.a >> 7) & 0x01);

      this->incrementPC(1);
      return 4; // 4 cycles
   }
   case 0x0F: // 0x0f   RRC         1     CY             A = A >> 1; bit 7 = prev bit 0; CY = prev bit 0
   {
      /// Carry bit is set equal to the low-order bit of the accumulator
      Reg.f.c = ((Reg.a & 0x01) == 0x01);

      // Rotate to the left while wrapping last bit (0) to first bit (7)
      Reg.a = ((Reg.a >> 1) & 0x7f) | ((Reg.a << 7) & 0x80);

      this->incrementPC(1);
      return 4; // 4 cycles
   }
   case 0x17: // 0x17   RAL         1     CY             A = A << 1; bit 0 = prev CY; CY = prev bit 7
   {
      uint8_t carry = Reg.f.c; // Copy of carry bit

      /// High-order bit of the accumulator replaces the Carry bit
      Reg.f.c = ((Reg.a & 0x80) == 0x80);

      // Rotate left
      Reg.a = Reg.a << 1;

      /// Carry bit replaces the *low-order bit of the accumulator
      Reg.a = (Reg.a & 0xfe) | (carry << 0);

      this->incrementPC(1);
      return 4; // 4 cycles
      // * Originally high-order, but I followed low-order to match diagram depicted.
   }
   case 0x1F: // 0x1f   RAR         1     CY             A = A >> 1; bit 7 = prev bit 7; CY = prev bit 0
   {
      uint8_t carry = Reg.f.c; // Copy of carry bit

      /// Low-order bit of the accumulator replaces the Carry bit
      Reg.f.c = ((Reg.a & 0x01) == 0x01);

      // Rotate right
      Reg.a = Reg.a >> 1;

      /// Carry bit replaces the high-order bit of the accumulator
      Reg.a = (Reg.a & 0x7f) | (carry << 7);

      this->incrementPC(1);
      return 4; // 4 cycles
   }

   // REGISTER PAIR INSTRUCTIONS: PUSH, POP, DAD INX, DCX, XCHG, XTHL, SPHL
   case 0xC5: // 0xc5   PUSH B      1                    (sp-2)<-C; (sp-1)<-B; sp <- sp - 2
   {
      PUSH(this, Reg.b, Reg.c);
      this->incrementPC(1);
      return 11; // 11 cycles
   }
   case 0xD5: // 0xd5   PUSH D      1                    (sp-2)<-E; (sp-1)<-D; sp <- sp - 2
   {
      PUSH(this, Reg.d, Reg.e);
      this->incrementPC(1);
      return 11; // 11 cycles
   }
   case 0xE5: // 0xe5   PUSH H      1                    (sp-2)<-L; (sp-1)<-H; sp <- sp - 2
   {
      PUSH(this, Reg.h, Reg.l);
      this->incrementPC(1);
      return 11; // 11 cycles
   }
   case 0xF5: // 0xf5   PUSH PSW    1                    (sp-2)<-flags; (sp-1)<-A; sp <- sp - 2
   {
      PUSH(this, Reg.a,
         (Reg.f.s << 7) |
         (Reg.f.z << 6) |
         (0 << 5)       |
         (Reg.f.a << 4) |
         (0 << 3)       |
         (Reg.f.p << 2) |
         (1 << 1)       |
         (Reg.f.c << 0));
      this->incrementPC(1);
      return 11; // 11 cycles
   }

   case 0xC1: // 0xc1   POP B       1                    C <- (sp); B <- (sp+1); sp <- sp+2
   {
      POP(this, Reg.b, Reg.c);
      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0xD1: // 0xd1   POP D       1                    E <- (sp); D <- (sp+1); sp <- sp+2
   {
      POP(this, Reg.d, Reg.e);
      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0xE1: // 0xe1   POP H       1                    L <- (sp); H <- (sp+1); sp <- sp+2
   {
      POP(this, Reg.h, Reg.l);
      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0xF1: // 0xf1   POP PSW     1     Z S P CY AC    flags <- (sp); A <- (sp+1); sp <- sp+2
   {
      uint8_t flags = memory[Reg.sp];
      POP(this, Reg.a, flags);

      // Condition bits
      Reg.f.s = ((flags & (1 << 7)) == (1 << 7)); // Sign bit
      Reg.f.z = ((flags & (1 << 6)) == (1 << 6)); // Zero bit
      // Ignore ((flags & (1 << 5)) == (1 << 5));
      Reg.f.a = ((flags & (1 << 4)) == (1 << 4)); // Auxiliary Carry bit
      // Ignore ((flags & (1 << 3)) == (1 << 3));
      Reg.f.p = ((flags & (1 << 2)) == (1 << 2)); // Parity bit
      // Ignore ((flags & (1 << 1)) == (1 << 1));
      Reg.f.c = ((flags & (1 << 0)) == (1 << 0)); // Carry bit

      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0x09: // 0x09   DAD B       1     CY             HL = HL + BC
   {
      DAD(this, (Reg.b << 8) | Reg.c);
      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0x19: // 0x19   DAD D       1     CY             HL = HL + DE
   {
      DAD(this, (Reg.d << 8) | Reg.e);
      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0x29: // 0x29   DAD H       1     CY             HL = HL + HL
   {
      DAD(this, (Reg.h << 8) | Reg.l);
      this->incrementPC(1);
      return 10; // 10 cycles
   }
   case 0x39: // 0x39   DAD SP      1     CY             HL = HL + SP
   {
      DAD(this, Reg.sp);
      this->incrementPC(1);
      return 10; // 10 cycles
   }

   case 0x03: // 0x03   INX B       1                    BC <- BC + 1
   {
      INX(this, Reg.b, Reg.c);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0x13: // 0x13   INX D       1                    DE <- DE + 1
   {
      INX(this, Reg.d, Reg.e);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0x23: // 0x23   INX H       1                    HL <- HL + 1
   {
      INX(this, Reg.h, Reg.l);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0x33: // 0x33   INX SP      1                    SP = SP + 1
   {
      Reg.sp = Reg.sp + 1;
      this->incrementPC(1);
      return 5; // 5 cycles
   }

   case 0x0B: // 0x0b   DCX B       1                    BC = BC - 1
   {
      DCX(this, Reg.b, Reg.c);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0x1B: // 0x1b   DCX D       1                    DE = DE - 1
   {
      DCX(this, Reg.d, Reg.e);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0x2B: // 0x2b   DCX H       1                    HL = HL - 1
   {
      DCX(this, Reg.h, Reg.l);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0x3B: // 0x3b   DCX SP      1                    SP = SP - 1
   {
      Reg.sp = Reg.sp - 1;
      this->incrementPC(1);
      return 5; // 5 cycles
   }

   case 0xEB: // 0xeb   XCHG        1                    H <-> D; L <-> E
   {
      std::swap(Reg.h, Reg.d);
      std::swap(Reg.l, Reg.e);
      this->incrementPC(1);
      return 5; // 5 cycles
   }
   case 0xE3: // 0xe3   XTHL        1                    L <-> (SP); H <-> (SP+1)
   {
      std::swap(Reg.l, memory[Reg.sp + 0]);
      std::swap(Reg.h, memory[Reg.sp + 1]);
      this->incrementPC(1);
      return 18; // 18 cycles (Longest operation!)
   }
   case 0xF9: // 0xf9   SPHL        1                    SP=HL
   {
      Reg.sp = (Reg.h << 8) | (Reg.l);
      this->incrementPC(1);
      return 5; // 5 cycles
   }

   // IMMEDIATE INSTRUCTIONS: LXI, MVI, ADI, ACI, SUI, SBI, ANI, XRI, ORI, CPI
   case 0x01: // 0x01   LXI BD16    3                    B <- byte 3 C <- byte 2
   {
      LXI(this, Reg.b, Reg.c);
      this->incrementPC(3);
      return 10; // 10 cycles
   }
   case 0x11: // 0x11   LXI DD16    3                    D <- byte 3 E <- byte 2
   {
      LXI(this, Reg.d, Reg.e);
      this->incrementPC(3);
      return 10; // 10 cycles
   }
   case 0x21: // 0x21   LXI HD16    3                    H <- byte 3 L <- byte 2
   {
      LXI(this, Reg.h, Reg.l);
      this->incrementPC(3);
      return 10; // 10 cycles
   }
   case 0x31: // 0x31   LXI SP D16  3                    SP.hi <- byte 3 SP.lo <- byte 2
   {
      Reg.sp = address();
      this->incrementPC(3);
      return 10; // 10 cycles
   }

   case 0x06: // 0x06   MVI B D8    2                    B <- byte 2
   case 0x0E: // 0x0e   MVI C D8    2                    C <- byte 2
   case 0x16: // 0x16   MVI D D8    2                    D <- byte 2
   case 0x1E: // 0x1e   MVI E D8    2                    E <- byte 2
   case 0x26: // 0x26   MVI H D8    2                    H <- byte 2
   case 0x2E: // 0x2e   MVI L D8    2                    L <- byte 2
   case 0x36: // 0x36   MVI M D8    2                    (HL) <- byte 2
   case 0x3E: // 0x3e   MVI A D8    2                    A <- byte 2
   {
      int reg = CODE_1;
      getRegister(reg) = immediate(1);
      this->incrementPC(2);
      return 7; // 7 cycles
   }

   case 0xC6: // 0xc6   ADI D8      2     Z S P CY AC    A <- A + byte
   case 0xCE: // 0xce   ACI D8      2     Z S P CY AC    A <- A + data + CY
   case 0xD6: // 0xd6   SUI D8      2     Z S P CY AC    A <- A - data
   case 0xDE: // 0xde   SBI D8      2     Z S P CY AC    A <- A - data - CY
   case 0xE6: // 0xe6   ANI D8      2     Z S P CY AC    A <- A & data
   case 0xEE: // 0xee   XRI D8      2     Z S P CY AC    A <- A ^ data
   case 0xF6: // 0xf6   ORI D8      2     Z S P CY AC    A <- A | data
   case 0xFE: // 0xfe   CPI D8      2     Z S P CY AC    A - data
   {
      uint8_t op = CODE_1;
      math[op](this, immediate());

      this->incrementPC(2);
      return 7; // 7 cycles
   }

   // DIRECT ADDRESSING INSTRUCTIONS: STA, LDA, SHLD, LHLD
   case 0x32: // 0x32   STA adr     3                    (adr) <- A
   {
      uint16_t adr = address();
      memory[adr] = Reg.a;
      this->incrementPC(3);
      return 13; // 13 cycles
   }
   case 0x3A: // 0x3a   LDA adr     3                    A <- (adr)
   {
      uint16_t adr = address();
      Reg.a = memory[adr];
      this->incrementPC(3);
      return 13; // 13 cycles
   }
   case 0x22: // 0x22   SHLD adr    3                    (adr) <-L; (adr+1)<-H
   {
      uint16_t adr = address();
      memory[adr + 0] = Reg.l;
      memory[adr + 1] = Reg.h;
      this->incrementPC(3);
      return 16; // 16 cycles
   }
   case 0x2A: // 0x2a   LHLD adr    3                    L <- (adr); H<-(adr+1)
   {
      uint16_t adr = address();
      Reg.l = memory[adr + 0];
      Reg.h = memory[adr + 1];
      this->incrementPC(3);
      return 16; // 16 cycles
   }

   // JUMP INSTRUCTIONS: PCHL, JMP, JC, JNC, JZ, JNZ, JM, JP, JPE, JPO
   case 0xE9: // 0xe9   PCHL        1                    pc.hi <- H; pc.lo <- L
   {
      Reg.pc = (Reg.h << 8) | (Reg.l << 0);
      return 5; // 5 cycles
   }
   case 0xC3: // 0xc3   JMP adr     3                    pc <- adr
   {
      Reg.pc = address();
      return 10; // 10 cycles
   }
   case 0xDA: // 0xda   JC  adr     3                    if C  pc <- adr
   case 0xD2: // 0xd2   JNC adr     3                    if NC pc <- adr
   case 0xCA: // 0xca   JZ  adr     3                    if Z  pc <- adr
   case 0xC2: // 0xc2   JNZ adr     3                    if NZ pc <- adr
   case 0xFA: // 0xfa   JM  adr     3                    if M  pc <- adr
   case 0xF2: // 0xf2   JP  adr     3                    if P  pc <- adr
   case 0xEA: // 0xea   JPE adr     3                    if PE pc <- adr
   case 0xE2: // 0xe2   JPO adr     3                    if PO pc <- adr
   {
      int test = CODE_1;
      if (tests[test](this))
         Reg.pc = address();
      else
         this->incrementPC(3);
      return 10; // 10 cycles
   }

   // CALL SUBROUTINE INSTRUCTIONS: CALL, CC, CNC, CZ, CNZ, CM, CP, CPE, CPO
   case 0xCD: // 0xcd   CALL adr    3                    (SP-1) <- pc.hi; (SP-2) <- pc.lo; SP <- SP + 2; pc = adr
   {
      CALL(this, address());
      return 17; // 17 cycles
   }
   case 0xDC: // 0xdc   CC  adr     3                    if C  CALL adr
   case 0xD4: // 0xd4   CNC adr     3                    if NC CALL adr
   case 0xCC: // 0xcc   CZ  adr     3                    if Z  CALL adr
   case 0xC4: // 0xc4   CNZ adr     3                    if NZ CALL adr
   case 0xFC: // 0xfc   CM  adr     3                    if M  CALL adr
   case 0xF4: // 0xf4   CP  adr     3                    if P  CALL adr
   case 0xEC: // 0xec   CPE adr     3                    if PE CALL adr
   case 0xE4: // 0xe4   CPO adr     3                    if PO CALL adr
   {
      int test = CODE_1;
      if (tests[test](this))
      {
         CALL(this, address());
         return 17; // 17 cycles
      }

      this->incrementPC(3);
      return 11; // 11 cycles
   }

   // RETURN FROM SUBROUTINE INSTRUCTIONS: RET, RN, RNC, RZ, RNZ, RM, RP, RPE, RPO
   case 0xC9: // 0xc9   RET         1                    pc.lo <- (sp); pc.hi <- (sp + 1); SP <- SP + 2
   {
      RET(this);
      return 10; // 10 cycles
   }
   case 0xD8: // 0xd8   RC          1                    if C  RET
   case 0xD0: // 0xd0   RNC         1                    if NC RET
   case 0xC8: // 0xc8   RZ          1                    if Z  RET
   case 0xC0: // 0xc0   RNZ         1                    if NZ RET
   case 0xF8: // 0xf8   RM          1                    if M  RET
   case 0xF0: // 0xf0   RP          1                    if P  RET
   case 0xE8: // 0xe8   RPE         1                    if PE RET
   case 0xE0: // 0xe0   RPO         1                    if PO RET
   {
      int test = CODE_1;
      if (tests[test](this))
      {
         RET(this);
         return 11; // 11 cycles
      }
      
      this->incrementPC(1);
      return 5; // 5 cycles
   }

   // RST INSTRUCTION
   case 0xC7: // 0xc7   RST 0       1                    CALL $0
   case 0xCF: // 0xcf   RST 1       1                    CALL $8
   case 0xD7: // 0xd7   RST 2       1                    CALL $10
   case 0xDF: // 0xdf   RST 3       1                    CALL $18
   case 0xE7: // 0xe7   RST 4       1                    CALL $20
   case 0xEF: // 0xef   RST 5       1                    CALL $28
   case 0xF7: // 0xf7   RST 6       1                    CALL $30
   case 0xFF: // 0xff   RST 7       1                    CALL $38
   {
      RST(this, opcode & 0x38); // opcode & 0x38 == (CODE_1) << 3
      return 11; // 11 cycles
   }

   // INTERRUPT FLIP-FLOP INSTRUCTIONS
   case 0xFB: // 0xfb   EI          1                    special
   {  // Enable Interrupts
      interrupt_enabled = true;
      this->incrementPC(1);
      return 4; // 4 cycles
   }
   case 0xF3: // 0xf3   DI          1                    special
   {  // Disable Interrupts
      interrupt_enabled = false;
      this->incrementPC(1);
      return 4; // 4 cycles
   }

   // INPUT/OUTPUT INSTRUCTIONS: IN, OUT
   case 0xDB: // 0xdb   IN  D8      2                    special
   {  // Read input port into A
      uint8_t port = immediate();
      Reg.a = io->read(port);
      this->incrementPC(2);
      return 10; // 10 cycles
   }
   case 0xD3: // 0xd3   OUT D8      2                    special
   {  // Write A to ouput port
      uint8_t port = immediate();
      io->write(port, Reg.a);
      this->incrementPC(2);
      return 10; // 10 cycles
   }

   // HLT HALT INSTRUCTION
   case 0x76: // 0x76   HLT         1                    special
   {  // Halt processor
      this->incrementPC(1);
      stopped = true;
      return 7; // 7 cycles
   }

   // unused
   default: // 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0xcb, 0xd9, 0xdd, 0xed, 0xfd
   {
      this->incrementPC(1);
      return 4; // 4 cycles
   }
   }
}