#include "aged_despill.h"
#include <algorithm>

namespace aged {

void despill_scalar(const uint8_t* fg_rgb, const float* alpha,
                    uint8_t* output,
                    size_t width, size_t height,
                    ScreenType type,
                    float threshold) {
    
    const size_t total_pixels = width * height;
    
    for (size_t i = 0; i < total_pixels; ++i) {
        const float a = alpha[i];
        
        // Step 1: Alpha Gating - Early exit for interior/exterior
        if (a <= threshold || a >= (1.0f - threshold)) {
            output[i*3 + 0] = fg_rgb[i*3 + 0];
            output[i*3 + 1] = fg_rgb[i*3 + 1];
            output[i*3 + 2] = fg_rgb[i*3 + 2];
            continue;
        }
        
        // Step 2: Load RGB
        const uint8_t r = fg_rgb[i*3 + 0];
        const uint8_t g = fg_rgb[i*3 + 1];
        const uint8_t b = fg_rgb[i*3 + 2];
        
        uint8_t r_out = r, g_out = g, b_out = b;
        
        // Step 3: Conditional Replacement
        if (type == SCREEN_GREEN) {
            if (g > r && g > b) {
                g_out = std::max(r, b);
            }
        } else { // SCREEN_BLUE
            if (b > r && b > g) {
                b_out = std::max(r, g);
            }
        }
        
        output[i*3 + 0] = r_out;
        output[i*3 + 1] = g_out;
        output[i*3 + 2] = b_out;
    }
}

} // namespace aged