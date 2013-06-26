#include <stdio.h>

#include "SDL/SDL_main.h"
#include "SDL/SDL.h"


int main(){
  
  SDL_Event event;
  SDL_PollEvent( &event );
  printf("%d, %d", event.type, event.key.keysym.sym);
  
  //  int test_array[10];
  //int b = test_array[0] + test_array[2];

  return 0;
}
