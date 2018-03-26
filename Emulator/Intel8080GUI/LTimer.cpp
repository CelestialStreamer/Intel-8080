#include "LTimer.h"

void LTimer::start()
{
   // Start the timer
   mStarted = true;

   // Unpause the timer
   mPaused = false;

   // Get the current clock time
   mStartTicks = SDL_GetTicks();
   mPausedTicks = 0;
}

void LTimer::stop()
{
   // Stop the timer
   mStarted = false;

   // Unpause the timer
   mPaused = false;

   // Clear tick variables
   mStartTicks = 0;
   mPausedTicks = 0;
}

void LTimer::pause()
{
   // If the timer is running and isn't already paused
   if (mStarted && !mPaused)
   {
      // Pause the timer
      mPaused = true;

      // Calculate the paused ticks
      mPausedTicks = SDL_GetTicks() - mStartTicks;
      mStartTicks = 0;
   }
}

void LTimer::unpause()
{
   // If the timer is running and paused
   if (mStarted && mPaused)
   {
      // Unpause the timer
      mPaused = false;

      // Reset the starting ticks
      mStartTicks = SDL_GetTicks() - mPausedTicks;

      // Reset the paused ticks
      mPausedTicks = 0;
   }
}

Uint32 LTimer::getTicks()
{
   Uint32 time = 0; // The actual timer time

   if (mStarted) // If the timer is running
   {
      if (mPaused) // If the timer is paused
         time = mPausedTicks; // Return the number of ticks when the timer was paused
      else
         time = SDL_GetTicks() - mStartTicks; // Return the current time minus the start time
   }

   return time;
}
