# aged-despill
Alpha-Gated Edge Despill
# Alpha-Gated Edge Despill (AGED)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![C++](https://img.shields.io/badge/C%2B%2B-17-blue.svg)]()
[![CUDA](https://img.shields.io/badge/CUDA-11.0-green.svg)]()

**Zero-parameter, Alpha-aware chroma key spill suppression for real-time compositing.**

AGED is a lightweight, high-performance despill algorithm specifically designed for **alpha boundary pixels** (0 < α < 1). Unlike traditional global despill methods, AGED applies conditional channel replacement only to edge pixels where green spill actually occurs during compositing, preserving interior colors perfectly.

> **Important Note:** AGED assumes the input foreground is in **Straight (Unassociated) RGB** color space, not Premultiplied RGB.

## Key Features

- 🎯 **Alpha-Gated Processing**: Only processes pixels with `0 < α < 1`, avoiding interior color distortion.
- ⚡ **Zero Parameters**: No manual tuning of spillmix, thresholds, or color spaces.
- 🧮 **Warp-Optimized GPU**: CUDA implementation uses `__ballot_sync` for warp-level early exit on non-edge pixels.
- 🎨 **Perceptually Optimized**: Hard-decision replacement eliminates green fringing without complex luminance compensation.
- 📹 **Real-Time**: O(1) per-pixel complexity, operates at memory bandwidth limits.

## Mathematical Formulation

Given foreground pixel **F** = (R, G, B), background **B**, and alpha mask α ∈ [0,1]:

### 1. Edge Detection Mask
$$\mathcal{M}_{\text{edge}} = \mathbb{I}(\alpha \in (0,1))$$

### 2. Spill Condition (Green Screen)
$$\mathcal{M}_{\text{spill}} = \mathbb{I}(G > R \land G > B)$$

### 3. Conditional Replacement
$$
F' = 
\begin{cases} 
(R, \max(R, B), B) & \text{if } \mathcal{M}_{\text{edge}} \land \mathcal{M}_{\text{spill}} \\
F & \text{otherwise}
\end{cases}
$$

## Quick Start (Python)
```bash
pip install aged-despill