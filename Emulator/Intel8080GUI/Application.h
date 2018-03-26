#pragma once
#include <string>
#include <vector>

#include "cleanup.h"

#include "stdafx.h"

class Application
{
public:
   Application()
   {
      try
      {
         init();
         pixels.resize(WIDTH * HEIGHT * 4, 0);
      }
      catch (const std::string& msg)
      {
         throw msg;
      }
   }
   ~Application()
   {
      cleanup(window, renderer, texture);
      SDL_Quit();
   }

   void update(std::vector<uint8_t> &pixels, int pitch)
   {
      SDL_RenderClear(renderer);
      SDL_RenderCopy(renderer, texture, nullptr, nullptr);
      SDL_RenderPresent(renderer);
      SDL_UpdateTexture(texture, nullptr, &pixels[0], pitch);
   }
private:
   SDL_Window* window;
   SDL_Renderer* renderer;
   SDL_Texture* texture;

   std::vector<uint8_t> pixels;

   void init()
   {
      if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO) != 0)
         throw logSDLError("SDL_Init");

      if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0)
      {
         SDL_Quit();
         throw logSDLError("SDL_mixer initialize");
      }

      SDL_DisplayMode DM;
      SDL_GetCurrentDisplayMode(0, &DM);
      int scale = (int)((0.8 * DM.h) / HEIGHT); // Scale to fit close to height of screen, but not too close

      window = SDL_CreateWindow("Space Invaders", 100, 100, WIDTH * scale, HEIGHT * scale, SDL_WINDOW_SHOWN);
      if (window == nullptr)
      {
         SDL_Quit();
         throw logSDLError("CreateWindow");
      }

      renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
      if (renderer == nullptr)
      {
         cleanup(window);
         SDL_Quit();
         throw logSDLError("CreateRenderer");
      }

      texture = SDL_CreateTexture(
         renderer,
         SDL_PIXELFORMAT_ABGR8888,
         SDL_TEXTUREACCESS_STREAMING,
         WIDTH, HEIGHT
      );
   }

   std::string logSDLError(const std::string &msg)
   {
      return msg + " error: " + SDL_GetError();
   }
};

