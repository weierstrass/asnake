
#include <stdio.h>
#include "SDL/SDL_main.h"
#include "SDL/SDL.h"

#define PM 4 /* Pixel magnifier */
#define PMW 0.5 /* Pixel magnifier */

SDL_Surface *screen;

void g_init(int w, int h){
  SDL_Init( SDL_INIT_EVERYTHING );
  screen = SDL_SetVideoMode( w, h, 32, SDL_SWSURFACE );

  SDL_WM_SetCaption("Assembler snake", "Assembler snake");
  printf("init graphics\n");
}

void g_draw(unsigned char *arr, unsigned char len){
  int i;
  SDL_Rect r;
  r.w = PM;
  r.h = PM;

  SDL_FillRect(screen, NULL, 0x000000);

  for(i = 0; i < len*2; i+=2){
    printf("x: %d, y: %d\n", *(arr-i), *(arr-i-1));
    r.x = *(arr-i) * PM;
    r.y = *(arr-i-1) * PM;
    SDL_FillRect(screen, &r, 0xffffff);
  }
  
  // draw apple
  printf("apple (%d, %d)\n", *(arr - 66), *(arr - 65)); 
  r.x = *(arr - 66) * PM;
  r.y = *(arr - 65) * PM;
  SDL_FillRect(screen, &r, 0xff0000);

  SDL_Flip( screen );
}
