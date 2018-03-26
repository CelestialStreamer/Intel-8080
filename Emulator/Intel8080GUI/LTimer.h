#pragma once
#include <SDL.h>

class LTimer
{
public:
   // Various clock actions
   void start();
   void stop();
   void pause();
   void unpause();

   // Get the timer's time
   Uint32 getTicks();

   // Checks the status of the timer
   bool isStarted() { return mStarted; } // Timer is running and paused or unpaused
   bool isPaused() { return mPaused && mStarted; } // Timer is running and paused

private:
   // The clock time when the timer started
   Uint32 mStartTicks = 0;

   // The ticks stored when the timer paused
   Uint32 mPausedTicks = 0;

   // The timer status
   bool mPaused = false;
   bool mStarted = false;
};

