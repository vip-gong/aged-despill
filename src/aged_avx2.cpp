#include "aged_despill.h"
#include <algorithm>

namespace aged {

void despill_avx2(const uint8_t* fg_rgb, const float* alpha,
                  uint8_t* output,
                  size_t width, size_t height,
                  ScreenType type,
                  float threshold) {
    // AVX2 implementation placeholder
    // For now, fall back to scalar implementation
    despill_scalar(fg_rgb, alpha, output, width, height, type, threshold);
}

} // namespace aged
