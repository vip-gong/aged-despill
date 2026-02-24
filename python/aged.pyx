# cython: language_level=3, boundscheck=False, wraparound=False
import numpy as np
cimport numpy as np
from libc.stdint cimport uint8_t

cdef extern from "../include/aged_despill.h" namespace "aged":
    cdef enum ScreenType:
        SCREEN_GREEN
        SCREEN_BLUE
    
    void despill_scalar(const uint8_t* fg_rgb, const float* alpha,
                        uint8_t* output, size_t width, size_t height,
                        ScreenType type, float threshold)

def despill(np.ndarray fg_rgb, 
            np.ndarray[np.float32_t, ndim=2] alpha,
            str screen_type='green', 
            float threshold=1e-3):
    """
    AGED Despill Algorithm
    """
    cdef size_t height = fg_rgb.shape[0]
    cdef size_t width = fg_rgb.shape[1]
    
    # Track original dtype to ensure float in -> float out
    is_float = fg_rgb.dtype in (np.float32, np.float64)
    
    cdef np.ndarray[np.uint8_t, ndim=3] fg_uint8
    if is_float:
        fg_uint8 = np.clip(fg_rgb * 255.0, 0, 255).astype(np.uint8)
    else:
        fg_uint8 = fg_rgb.astype(np.uint8)
        
    cdef np.ndarray[np.uint8_t, ndim=3] output = np.empty_like(fg_uint8)
    cdef ScreenType st = SCREEN_GREEN if screen_type == 'green' else SCREEN_BLUE
    
    despill_scalar(&fg_uint8[0,0,0], &alpha[0,0], &output[0,0,0],
                   width, height, st, threshold)
                   
    if is_float:
        return output.astype(np.float32) / 255.0
    return output