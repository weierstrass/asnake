
#include <stdio.h>

#include <SDL/SDL_main.h>
#include <SDL/SDL.h>

static const char k_scale = 4; /* scale constant */
static const char k_header_height = 30; /* height of header section*/
SDL_Surface *screen;

void g_init(int iw, int ih)
{
  SDL_Init(SDL_INIT_EVERYTHING);
  SDL_WM_SetCaption("Assembler snake", "Assembler snake");
  int window_width = iw*k_scale;
  int window_height = ih*k_scale + k_header_height;
  screen = SDL_SetVideoMode(window_width, window_height, 32, SDL_SWSURFACE);
  printf("init graphics\n");
}

void g_draw(unsigned char *arr, unsigned char len)
{
  int i;
  SDL_Rect r = {.w = k_scale, .h = k_scale};

  /* draw background */
  SDL_FillRect(screen, NULL, 0x000000);

  /* draw title + score */
  

  /* draw snake */
  for (i = 0; i < len*2; i+=2)
  {
    printf("x: %d, y: %d\n", *(arr-i), *(arr-i-1));
    r.x = *(arr-i) * k_scale;
    r.y = *(arr-i-1) * k_scale + k_header_height;
    SDL_FillRect(screen, &r, 0xffffff);
  }
  
  /* draw apple */
  printf("apple (%d, %d)\n", *(arr - 66), *(arr - 65)); 
  r.x = *(arr - 66) * k_scale;
  r.y = *(arr - 65) * k_scale + k_header_height;
  SDL_FillRect(screen, &r, 0xff0000);

  SDL_Flip(screen);
}
