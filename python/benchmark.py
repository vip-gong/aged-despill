#!/usr/bin/env python3
import time
import numpy as np
from aged import despill

def create_test_pattern(width=3840, height=2160):
    """Create a 4K synthetic testing pattern"""
    fg = np.zeros((height, width, 3), dtype=np.uint8)
    fg[500:1500, 1000:2800] = [180, 120, 100] 
    
    alpha = np.zeros((height, width), dtype=np.float32)
    # Simulate a rough circular mask with soft edges
    y, x = np.ogrid[:height, :width]
    dist = np.sqrt((x - width//2)**2 + (y - height//2)**2)
    alpha = np.clip(1.0 - (dist - 800) / 100, 0, 1)
    
    return fg, alpha

def global_despill_numpy(fg_float, mix=0.5):
    """Memory-bound simulation of traditional global despill (e.g., FFmpeg)"""
    r = fg_float[:, :, 0]
    g = fg_float[:, :, 1]
    b = fg_float[:, :, 2]
    
    # Standard mix calculation: Limit Green based on Red and Blue
    g_limit = mix * r + (1 - mix) * b
    g_new = np.minimum(g, g_limit)
    
    result = fg_float.copy()
    result[:, :, 1] = g_new
    return result

if __name__ == "__main__":
    print("AGED Algorithm vs Global Despill (Memory-Bound Benchmark)")
    print("=" * 60)
    
    fg_uint8, alpha = create_test_pattern()
    fg_float = fg_uint8.astype(np.float32) / 255.0
    
    # Warmup
    _ = despill(fg_float, alpha)
    _ = global_despill_numpy(fg_float)
    
    # Benchmark AGED
    start = time.perf_counter()
    for _ in range(50):
        _ = despill(fg_float, alpha)
    aged_time = (time.perf_counter() - start) / 50 * 1000
    
    # Benchmark Global Despill
    start = time.perf_counter()
    for _ in range(50):
        _ = global_despill_numpy(fg_float)
    global_time = (time.perf_counter() - start) / 50 * 1000
    
    print(f"Resolution: 4K (3840x2160)")
    print(f"AGED (C++ backend):       {aged_time:.2f} ms per frame")
    print(f"Global Despill (Vector):  {global_time:.2f} ms per frame")
    print(f"Speedup:                  {global_time/aged_time:.1f}x")