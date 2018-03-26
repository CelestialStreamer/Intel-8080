#include "IO.h"

#include <iostream>

uint8_t IO::read(uint8_t port)
{
   switch (port)
   {
   case 1: return
      (Read1.coin << 0)
      | (Read1.player2Start << 1)
      | (Read1.player1Start << 2)
      | (Read1.fill1 << 3)
      | (Read1.player1Shoot << 4)
      | (Read1.player1joystickLeft << 5)
      | (Read1.player1joystickRight << 6)
      | (Read1.fill2 << 7);
   case 2: return
      (Read2.lives << 0)
      | (Read2.tilt << 2)
      | (Read2.bonusLife << 3)
      | (Read2.player2Shoot << 4)
      | (Read2.player2joystickLeft << 5)
      | (Read2.player2joystickRight << 6)
      | (Read2.coinInfo << 7);
   case 3: return // Shift register result
      ((((shift1 << 8) | shift0) >> (8 - shift_offset)) & 0xff);
   default: return 0; // Should never happen
   }
}

void IO::write(uint8_t port, uint8_t value)
{
   switch (port)
   {
   case 0: // Not in actual Space Invaders hardware. Debug use only.
      std::cout << value;
      break;
   case 2: // Shift register result offset (bits 0,1,2)
      shift_offset = value & 0x7;
      break;
   case 3: { // Sounds
      if (sounds != nullptr)
         for (auto n = 0; n < 4; n++)
            if (value & (1 << n)) // If nth bit is set, play corresponding sound
               Mix_PlayChannel(-1, sounds[n], 0);
      break; 
   }
   case 4: // Fill shift register
      shift0 = shift1;
      shift1 = value;
      break;
   case 5: { // Sounds
      if (sounds != nullptr)
         for (auto n = 0; n < 5; n++)
            if (value & (1 << n)) // If nth bit is set, play corresponding sound
               Mix_PlayChannel(-1, sounds[n + 4], 0);
      break;
   }
   case 6: break; // strange 'debug' port? eg. it writes to this port when it writes text to the screen(0 = a, 1 = b, 2 = c, etc)
   default:
      break;
   }
}