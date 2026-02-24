# Alpha-Gated Edge Despill (AGED)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![C++](https://img.shields.io/badge/C%2B%2B-17-blue.svg)]()
[![CUDA](https://img.shields.io/badge/CUDA-11.0-green.svg)]()
[![Build Status](https://github.com/yourusername/aged-despill/actions/workflows/build.yml/badge.svg)]()

**Zero-parameter, Alpha-aware chroma key spill suppression for real-time compositing.**

## ✨ Visual Results

<div align="center">
<table>
<tr>
<td align="center">
<img src="assets/tradition.png" alt="Traditional Global Despill" width="400"/>
<br />
<b>Traditional Global Despill</b><br/>
(Note damaged interior colors)
</td>
<td align="center">
<img src="assets/aged_dispill.png" alt="AGED Edge-Only Despill" width="400"/>
<br />
<b>AGED Edge-Only Despill</b><br/>
(Perfect interior preservation)
</td>
</tr>
</table>
</div>

> **Note:** AGED only processes pixels with `0 < α < 1`, leaving fully opaque areas completely untouched.

AGED is a lightweight, high-performance despill algorithm specifically designed for **alpha boundary pixels** ($0 < \alpha < 1$). Unlike traditional global despill methods, AGED applies conditional channel replacement only to edge pixels where green spill actually occurs during compositing, preserving interior colors perfectly.

## Key Features

- 🎯 **Alpha-Gated Processing**: Only processes pixels with $0 < \alpha < 1$, avoiding interior color distortion.
- ⚡ **Zero Parameters**: No manual tuning of spillmix, thresholds, or color spaces.
- 🧮 **Hardware-Friendly**: Branchless SIMD implementation, ideal for GPU/FPGA.
- 🎨 **Perceptually Optimized**: Hard-decision replacement eliminates green fringing without complex luminance compensation.
- 📹 **Real-Time**: $O(N)$ complexity, 4K@60fps on consumer GPUs.

## Mathematical Formulation

Given foreground pixel **F** = $(R, G, B)$, background **B**, and alpha mask $\alpha \in [0,1]$:

### 1. Edge Detection Mask
$$\mathcal{M}_{\text{edge}} = \mathbb{I}(\alpha \in (0,1))$$

### 2. Spill Condition (Green Screen)
$$\mathcal{M}_{\text{spill}} = \mathbb{I}(G = \max(R, G, B))$$

### 3. Conditional Replacement
$$F' = \begin{cases} (R, \max(R, B), B) & \text{if } \mathcal{M}_{\text{edge}} \land \mathcal{M}_{\text{spill}} \\ F & \text{otherwise} \end{cases}$$

### 4. Standard Alpha Compositing
$$C = \alpha \cdot F' + (1-\alpha) \cdot B_{\text{bg}}$$

## Quick Start

### Python (NumPy/Cython)
```python
import aged
import cv2

# Load your RGBA image (H, W, 4)
rgba = cv2.imread("keyed_image.png", cv2.IMREAD_UNCHANGED) / 255.0
alpha = rgba[:, :, 3]

# Apply AGED despill (Maintains float32 dtype automatically)
result = aged.despill(rgba[:, :, :3], alpha, screen_type='green')