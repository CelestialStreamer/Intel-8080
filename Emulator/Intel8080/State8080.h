#pragma once
#include "IO.h"
#include "Memory.h"
#include <cstdint> // uint8_t, uint16_t, uint32_t

#define SET 1
#define RESET 0

// From manual Parity Bit
// "The Parity bit is set to 1 for even parity, and is reset to 0 for odd parity."
#define EVEN SET
#define ODD RESET

uint8_t parity(uint8_t v);

class State8080 {
public:
   struct Reg
   {
      uint8_t a = 0;
      struct ConditionCodes {
         // 7 6 5 4 3 2 1 0
         // S Z 0 A 0 P 1 C
         uint8_t c; // Carry
         uint8_t p; // Parity
         uint8_t a; // Auxiliary Carry
         uint8_t z; // Zero
         uint8_t s; // Sign
      }f = { RESET, RESET, RESET, RESET, RESET };
      uint8_t b = 0, c = 0;
      uint8_t d = 0, e = 0;
      uint8_t h = 0, l = 0;
      uint16_t pc = 0, sp = 0;
   } Reg;

   Memory *memory;
   State8080(Memory *memory, bool enablePrint = false) : memory(memory), io(new IO()) { setPrint(enablePrint); }

   void setPrint(bool enablePrint) { this->enablePrint = enablePrint; }

   int  Emulate8080Op();
   int  Disassemble8080Op();
   void displayFull();
   void displayAbrev();
   bool isStopped() { return stopped; }
   bool isInterruptEnabled() { return interruptEnabled; }

   uint8_t immediate(uint8_t byte = 1) { return memory->read(Reg.pc + byte); }

   uint16_t address() { return (immediate(1) << 0) | (immediate(2) << 8); }

   uint8_t getRegister(uint8_t code)
   {
      switch (code)
      {
      case 0: return Reg.b;
      case 1: return Reg.c;
      case 2: return Reg.d;
      case 3: return Reg.e;
      case 4: return Reg.h;
      case 5: return Reg.l;
      case 6: return memory->read((Reg.h << 8) | (Reg.l << 0));
      default: return Reg.a;
      }
   }

   void setRegister(uint8_t code, uint8_t val)
   {
      switch (code)
      {
      case 0: Reg.b = val; break;
      case 1: Reg.c = val; break;
      case 2: Reg.d = val; break;
      case 3: Reg.e = val; break;
      case 4: Reg.h = val; break;
      case 5: Reg.l = val; break;
      case 6: memory->write((Reg.h << 8) | (Reg.l << 0), val); break;
      default: Reg.a = val; break;
      }
   }

   void generateInterrupt(uint8_t opcode);
   uint16_t incrementPC(uint16_t inc)
   {
      if (updatePC)
      {
         //if (inc > 2) memory->read(Reg.pc + 1); // Totally only for debug. Final emulator can remove this
         //if (inc > 1) memory->read(Reg.pc + 2); // Totally only for debug. Final emulator can remove this
         Reg.pc += inc;
      }
      return Reg.pc;
   }
   void report(std::ostream &stream);
private:
   bool enablePrint;
   IO *io;
   bool interruptEnabled = false;  // Are we ready to take interrupts?
   bool interruptRequested = false; // Is there an interrupt now?
   unsigned char interruptOpcode = 0;
   bool stopped = false;
   long int hitCount[256] = {};
   bool updatePC = true;
};
