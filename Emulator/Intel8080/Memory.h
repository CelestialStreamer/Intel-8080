#pragma once
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iomanip>

#define MAX(A,B) ((A)>(B)?(A):(B))

class Memory
{
private:
   uint16_t largestAddress;
   bool enablePrint;
public:
   uint8_t memory[0xffff]={};
   Memory(char* file, bool enablePrint = false)
   {
      this->setPrint(enablePrint);
      std::ifstream stream(file, std::ios::binary);
      stream.read((char*)memory, 0xffff);
      stream.close();
      largestAddress = 0;
   }

   void setPrint(bool enablePrint) { this->enablePrint = enablePrint; }

   uint8_t read(uint16_t address)
   {
      if (enablePrint) std::cout << std::endl << std::hex << std::setw(4) << (int)address << " " << std::setw(2) << (int)memory[address] << " r";
      return memory[address];
   }

   void write(uint16_t address, uint8_t value)
   {
      if (enablePrint) std::cout << std::endl << std::hex << std::setw(4) << (int)address << " " << std::setw(2) << (int)value << " w";

      if (address < 0x2000)
      {
         std::cerr << "Fatal error" << std::endl;
         return;
      }

      memory[address] = value;
   }

   void memDump(const char* file)
   {
      std::ofstream stream(file, std::ios::binary);
      stream.write((char*)memory, 0x3fff);
      stream.close();
   }

   uint16_t getStats() { return largestAddress; }
};

