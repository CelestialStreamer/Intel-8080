#pragma once
#include <cstdint>
#include <algorithm>
#include <SDL_mixer.h>
#include <string>

#include "stdafx.h"

class IO
{
public:
   uint8_t read(uint8_t port);
   void write(uint8_t port, uint8_t value);

   IO() {}
   IO(WAV* sounds) : sounds(sounds) {}
   IO(char** soundFiles)
   {
      sounds = new WAV[9];
      for (auto sound = 0; sound < 9; sound++)
         if ((sounds[sound] = Mix_LoadWAV(soundFiles[sound])) == nullptr)
            throw std::string("Failed to load sound effect! Mix_LoadWAV error: ") + SDL_GetError();
   }
   ~IO()
   {
      // Free sound effects
      if (sounds != nullptr)
         for (auto sound = 0; sound < 9; sound++)
            Mix_FreeChunk(sounds[sound]);
      delete[] sounds;
      Mix_Quit();
   }

   struct Read1
   {
      uint8_t coin = 1; // Coin (0 when active)
      uint8_t player2Start = 0;
      uint8_t player1Start = 0;
      uint8_t fill1 = 0; // ?
      uint8_t player1Shoot = 0;
      uint8_t player1joystickLeft = 0;
      uint8_t player1joystickRight = 0;
      uint8_t fill2 = 0; // ?
   } Read1;
   struct Read2
   {
      uint8_t lives = 3; // Dipswitch number of lives (0:3,1:4,2:5,3:6)
      uint8_t tilt = 0; // Tilt 'button'
      uint8_t bonusLife = 0; // Dipswitch bonus life at 1:1000,0:1500    
      uint8_t player2Shoot = 0;
      uint8_t player2joystickLeft = 0;
      uint8_t player2joystickRight = 0;
      uint8_t coinInfo = 0; // Dipswitch coin info 1:off,0:on  
   } Read2;

   void setLives(int value) { Read2.lives = value & 3; }
   void setCoin()      { Read1.coin                 = 1; } void resetCoin()      { Read1.coin                 = 0; }
   void setTilt()      { Read2.tilt                 = 1; } void resetTilt()      { Read2.tilt                 = 0; }
   void setBonusLife() { Read2.bonusLife            = 1; } void resetBonusLife() { Read2.bonusLife            = 0; }
   void setCoinInfo()  { Read2.coinInfo             = 1; } void resetCoinInfo()  { Read2.coinInfo             = 0; }

   void setP1Start()   { Read1.player1Start         = 1; } void resetP1Start()   { Read1.player1Start         = 0; }
   void setP1Shoot()   { Read1.player1Shoot         = 1; } void resetP1Shoot()   { Read1.player1Shoot         = 0; }
   void setP1Left()    { Read1.player1joystickLeft  = 1; } void resetP1Left()    { Read1.player1joystickLeft  = 0; }
   void setP1Right()   { Read1.player1joystickRight = 1; } void resetP1Right()   { Read1.player1joystickRight = 0; }
                                                                                 
   void setP2Start()   { Read1.player2Start         = 1; } void resetP2Start()   { Read1.player2Start         = 0; }
   void setP2Shoot()   { Read2.player2Shoot         = 1; } void resetP2Shoot()   { Read2.player2Shoot         = 0; }
   void setP2Left()    { Read2.player2joystickLeft  = 1; } void resetP2Left()    { Read2.player2joystickLeft  = 0; }
   void setP2Right()   { Read2.player2joystickRight = 1; } void resetP2Right()   { Read2.player2joystickRight = 0; }
private:
   WAV* sounds;

   uint8_t shift_offset;

   uint8_t shift0;
   uint8_t shift1;
};