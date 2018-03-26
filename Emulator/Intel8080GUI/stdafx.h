// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include <SDL.h>
#include <SDL_mixer.h>

const int WIDTH = 224;
const int HEIGHT = 256;

const int SCREEN_FPS = 60;
const int SCREEN_TICK_PER_FRAME = 1000 / SCREEN_FPS;

typedef Mix_Chunk* WAV; // Used for .wav files a lot