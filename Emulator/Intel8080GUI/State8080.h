#pragma once
#include "IO.h"

#include <cstdint> // uint8_t, uint16_t, uint32_t
#include <fstream>

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

   uint8_t memory[0x10000] = {};
   State8080(char* file, IO* io) : io(io)
   {
      std::ifstream stream(file, std::ios::binary);
      stream.read((char*)memory, 0x2400);
      stream.close();
      reset();
   }

   int  Emulate8080Op();
   int  Disassemble8080Op();
   void displayFull();
   void displayAbrev();
   bool isStopped() { return stopped; }

   void reset()
   {
      Reg.pc = 0;
      stopped = false;
      interrupt_enabled = false;
   }

   uint8_t immediate(int byte = 1) { return memory[Reg.pc + byte]; }

   uint16_t address() { return (immediate(2) << 8) | (immediate(1) << 0); }

   uint8_t &getRegister(int code)
   {
      switch (code)
      {
      case 0: return Reg.b;
      case 1: return Reg.c;
      case 2: return Reg.d;
      case 3: return Reg.e;
      case 4: return Reg.h;
      case 5: return Reg.l;
      case 6: return memory[Reg.h << 8 | Reg.l];
      default: return Reg.a;
      }
   }

   void generateInterrupt(uint8_t opcode);
   uint16_t incrementPC(int inc)
   {
      if (updatePC)
         Reg.pc += inc;
      return Reg.pc;
   }
   void report(std::ostream &stream);
   void memDump(const char* file)
   {
      std::ofstream stream(file, std::ios::binary);
      stream.write((char*)&memory[0x2400], 0x1BFF);
      stream.close();
   }
private:
   IO *io;
   bool interrupt_enabled = false;  // Are we ready to take interrupts?
   bool interruptRequested = false; // Is there an interrupt now?
   unsigned char interruptOpcode = 0;
   bool stopped = false;
   long int hitCount[256] = {};
   bool updatePC = true;
};
