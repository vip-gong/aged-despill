#ifndef AGED_DESPILL_H
#define AGED_DESPILL_H

#include <cstdint>
#include <cstddef>

namespace aged {

enum ScreenType {
    SCREEN_GREEN,
    SCREEN_BLUE
};

void despill_scalar(const uint8_t* fg_rgb, const float* alpha,
                    uint8_t* output, size_t width, size_t height,
                    ScreenType type, float threshold);

void despill_cuda_rgba(const uint8_t* d_rgba_in, uint8_t* d_rgba_out,
                       size_t width, size_t height,
                       ScreenType type, void* stream);

} // namespace aged

#endif // AGED_DESPILL_H
