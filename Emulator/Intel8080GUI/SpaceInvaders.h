#pragma once
#include <vector>

#include "stdafx.h"
#include "State8080.h"
#include "IO.h"

class SpaceInvaders
{
public:
   SpaceInvaders(char* file, char** soundFiles)
   {
      try
      {
         io = new IO(soundFiles);
         state = new State8080(file, io);
      }
      catch (const std::string& msg)
      {
         throw msg;
      }
   }
   SpaceInvaders(char* file)
   {
      try
      {
         io = new IO();
         state = new State8080(file, io);
      }
      catch (const std::string& msg)
      {
         throw msg;
      }
   }
   ~SpaceInvaders()
   {
      delete state;
      delete io;
   }

   void reset() { state->reset(); }

   void CPU_Cycles() // Run CPU for 1/60s or two video interrupts
   {
      bool firstInterrupt = true;
      for (;;)
      {
         cycles += state->Emulate8080Op();

         if (cycles >= nextInterrupt)
         {
            nextInterrupt += howOftenToInterrupt;

            if (firstInterrupt)
            {
               state->generateInterrupt(0xcf);
               firstInterrupt = !firstInterrupt;
            }
            else
            {
               state->generateInterrupt(0xd7);
               break; // Only do two interrupts
            }
         }
      }
   }

   void handleInput(SDL_Event event)
   {
      if (event.type == SDL_KEYDOWN)
         switch (event.key.keysym.sym)
         {
         case SDLK_c:     io->setCoin();    break; // Coin

         case SDLK_t:     io->setTilt();    break; // Tilt (I want to see what happens)

         case SDLK_RCTRL: io->setP1Start(); break; // P1 start
         case SDLK_LEFT:  io->setP1Left();  break; // P1 left
         case SDLK_RIGHT: io->setP1Right(); break; // P1 right
         case SDLK_SPACE: io->setP1Shoot(); break; // P1 shoot

         case SDLK_LCTRL: io->setP2Start(); break; // P2 start
         case SDLK_a:     io->setP2Left();  break; // P2 left
         case SDLK_d:     io->setP2Right(); break; // P2 right
         case SDLK_LSHIFT:io->setP2Shoot(); break; // P2 shoot

         default: break;
         }
      else if (event.type == SDL_KEYUP)
         switch (event.key.keysym.sym)
         {
         case SDLK_c:     io->resetCoin();    break; // Coin

         case SDLK_t:     io->resetTilt();    break; // Tilt (I want to see what happens)

         case SDLK_RCTRL: io->resetP1Start(); break; // P1 start
         case SDLK_LEFT:  io->resetP1Left();  break; // P1 left
         case SDLK_RIGHT: io->resetP1Right(); break; // P1 right
         case SDLK_SPACE: io->resetP1Shoot(); break; // P1 shoot

         case SDLK_LCTRL: io->resetP2Start(); break; // P2 start
         case SDLK_a:     io->resetP2Left();  break; // P2 left
         case SDLK_d:     io->resetP2Right(); break; // P2 right
         case SDLK_LSHIFT:io->resetP2Shoot(); break; // P2 shoot

         default: break;
         }
   }

   void draw(std::vector<unsigned char> &pixels) { // Assumes pixels has dimensions WIDTH*HEIGHT*4
      for (unsigned int row = 0; row < HEIGHT; row++)
         for (unsigned int col = 0; col < WIDTH; col++)
         {
            unsigned int offset = (WIDTH * 4 * row) + col * 4; // Get pixel in vector

            uint8_t byte = state->memory[0x2400 + HEIGHT / 8 * col + (0x1F - (row) / 8)]; // row is reverse so first row (0x1F) minus (row/8) because 1 byte has 8 rows (bits)
            uint8_t pixel = byte & (1 << (7 - row % 8)); // Select pixel in byte

            pixels[offset + 0] = (pixel ? 0xFF : 0x00);
            pixels[offset + 1] = (pixel ? 0xFF : 0x00);
            pixels[offset + 2] = (pixel ? 0xFF : 0x00);
            pixels[offset + 3] = SDL_ALPHA_OPAQUE;
         }
   }
private:

   State8080* state;
   IO* io;

   int howOftenToInterrupt = 2'000'000 / 120;
   Uint64 nextInterrupt = 0 + howOftenToInterrupt;
   Uint64 cycles = 0; // Counter will overflow in about 250K years
};