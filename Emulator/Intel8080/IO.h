#pragma once
#include <cstdint>

class IO
{
public:
   uint8_t read(uint8_t port);
   void write(uint8_t port, uint8_t value);

   IO() {}

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

private:
   uint8_t shift_offset;

   uint8_t shift0;
   uint8_t shift1;
};