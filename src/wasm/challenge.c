#include <emscripten.h>
#include <stdlib.h>

EMSCRIPTEN_KEEPALIVE
int cstart_size(int max) { return rand() % max; }

EMSCRIPTEN_KEEPALIVE
int outline_color(int outline_x, int inner_x, int size, int variance) {
  int circle_right_edge = outline_x + size;
  return (circle_right_edge >= inner_x - variance &&
          circle_right_edge <= inner_x + variance);
}

EMSCRIPTEN_KEEPALIVE
void increment_position(int *start_x, int *start_y, int end_x, int end_y,
                        int radius) {
  *start_x = end_x - radius;
  *start_y = end_y - radius;
}
