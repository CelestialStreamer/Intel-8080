#include "State8080.h"
#include "IO.h"
#include "Memory.h"
#include <iostream>
#include <fstream>
//#include <Windows.h>
#include <string>
#include <iomanip>

State8080* state;

#define PrintMessage 0x08F3
#define DrawNumCredits 0x1947

#define CALL 0xCD
#define RET 0xC9
#define JUMP 0xC3
#define OUT 0xD3

bool print = false;
bool debug = true;

void CPU_Cycles()
{
   long int cycles = 0;
   bool firstInterrupt = true;
   int howOftenToInterrupt = 2'000'000 / 120;
   int nextInterrupt = 0 + howOftenToInterrupt;

   std::cout << std::hex << std::setfill('0');

   std::string filePath = "memdump/dump/frame";
   int frame = 0;

   while (!state->isStopped())
   {
      if (print) std::cout << std::endl;
      cycles += state->Emulate8080Op();
      if (debug)
      {
         std::cout << " ";
         state->Disassemble8080Op();
         state->displayAbrev();
         std::cout << std::endl;
      }

      if (state->Reg.pc == 0x090e)
      {
         break;
      }

      //if (state->isInterruptEnabled())
      //   break;

      //uint8_t opcode = state->memory->memory[state->Reg.pc];

      //if (opcode == OUT)
      //{
      //   std::cout << "";
      //}

      if (cycles >= nextInterrupt)
      {
         state->memory->memDump((filePath + std::to_string(frame++)).c_str());
         nextInterrupt += howOftenToInterrupt;

         if (firstInterrupt)
            state->generateInterrupt(0xcf);
         else
            state->generateInterrupt(0xd7);

         firstInterrupt = !firstInterrupt;
      }
      if (cycles > 2 * 60 * 2'000'000) // Run time
         break;
   }
   std::cerr << cycles << std::endl;
}

void init(char** argv)
{
   state = new State8080(new Memory(argv[1], print), print);
}

int main(int argc, char** argv)
{
   if (argc != 2)
      return 0;

   init(argv);

   CPU_Cycles();

   return 0;
}