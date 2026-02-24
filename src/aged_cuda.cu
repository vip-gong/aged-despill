#include "aged_despill.h"
#include <cuda_runtime.h>

namespace aged {

// Warp-level optimized kernel using uchar4 for 128-bit memory transactions
__global__ void despill_rgba_kernel(const uchar4* __restrict__ input,
                                    uchar4* __restrict__ output,
                                    int width, int height,
                                    ScreenType type) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    int idx = y * width + x;
    uchar4 pixel = input[idx];

    // Alpha check (assume alpha is the 4th channel, 0-255)
    // Edge condition: strictly greater than 0 and less than 255
    bool is_edge = (pixel.w > 0 && pixel.w < 255);

    // 🔥 WARP-LEVEL OPTIMIZATION 🔥
    // Evaluate if ANY thread in the current warp has an edge pixel
    // If the entire 32-thread warp is purely interior/exterior, skip all math branches
    unsigned int active_mask = __ballot_sync(0xFFFFFFFF, is_edge);

    if (active_mask == 0) {
        // Fast path: Just pure coalesced memory write
        output[idx] = pixel;
        return;
    }

    // Only threads with actual edge pixels execute the math
    if (is_edge) {
        if (type == SCREEN_GREEN) {
            if (pixel.y > pixel.x && pixel.y > pixel.z) {
                pixel.y = max(pixel.x, pixel.z);
            }
        } else { // SCREEN_BLUE
            if (pixel.z > pixel.x && pixel.z > pixel.y) {
                pixel.z = max(pixel.x, pixel.y);
            }
        }
    }

    output[idx] = pixel;
}

void despill_cuda_rgba(const uint8_t* d_rgba_in, uint8_t* d_rgba_out,
                       size_t width, size_t height,
                       ScreenType type, void* stream) {
    
    cudaStream_t cu_stream = static_cast<cudaStream_t>(stream);
    
    dim3 block(32, 8); // 256 threads per block, aligned to Warp size
    dim3 grid((width + block.x - 1) / block.x, 
              (height + block.y - 1) / block.y);

    despill_rgba_kernel<<<grid, block, 0, cu_stream>>>(
        reinterpret_cast<const uchar4*>(d_rgba_in),
        reinterpret_cast<uchar4*>(d_rgba_out),
        width, height, type
    );
}

} // namespace aged