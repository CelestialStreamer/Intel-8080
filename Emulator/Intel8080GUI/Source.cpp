#include <iostream>
#include <string>
#include <vector>

#include "Application.h"
#include "LTimer.h"
#include "SpaceInvaders.h"

#include "stdafx.h"

int main(int argc, char** argv)
{
   if (argc != 2 && argc != 2 + 9)
      return 0;

   Application* app;
   try
   {
      app = new Application();
   }
   catch (const std::string& msg)
   {
      std::cout << msg << std::endl;
      return 1;
   }

   SpaceInvaders* game;
   if (argc == 2 + 9)
      game = new SpaceInvaders(argv[1], &argv[2]); // Load the 9 sounds
   else
      game = new SpaceInvaders(argv[1]);

   std::vector<unsigned char> pixels(WIDTH * HEIGHT * 4, 0); // Game video
   bool quit = false; // Main loop flag
   SDL_Event event; // Event handler
   LTimer capTimer; // The frames per second cap timer

   while (!quit) // While application is running
   {
      // Start cap timer
      capTimer.start();

      // Handle events on queue
      while (SDL_PollEvent(&event) != 0)
      {
         // User requests quit
         if (event.type == SDL_QUIT)
            quit = true;
         else if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_r)
            game->reset();
         else
            game->handleInput(event);
      }

      // Run game for another frame
      game->CPU_Cycles();

      // Render what we want
      game->draw(pixels);

      app->update(pixels, WIDTH * 4);

      int frameTicks = capTimer.getTicks(); // Get frame time
      if (frameTicks < SCREEN_TICK_PER_FRAME) // If frame finished early
         SDL_Delay(SCREEN_TICK_PER_FRAME - frameTicks); // Wait remaining time
   }

   delete game;
   delete app;

   return 0;
}