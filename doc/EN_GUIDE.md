# `zero_chart` — English Developer Guide

## 1. Overview
`zero_chart` is a 120Hz Element-Bypass financial and real-time telemetry charting engine for Flutter created by **RedLight Apps** (`https://redlightapps.com`) with zero external dependencies.

## 2. Core Modules
- **`LttbDownsampler`:** $O(N)$ Largest-Triangle-Three-Buckets visual downsampling.
- **`TechnicalIndicators`:** Zero-allocation `SMA`, `EMA`, `RSI`, and `BollingerBands`.
- **`SynchronizedChartController`:** Multi-pane crosshair and viewport synchronization via `CustomPainter(repaint:)`.
- **`ZeroCandlestickChart`, `ZeroLineAreaChart`, `ZeroDepthChart`:** High-frequency financial and telemetry canvases.
