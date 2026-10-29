## 1.0.2

- Added animated GIF live showcase (`doc/screenshots/zero_chart_demo.gif`) and real-time multi-pane synchronized crosshair + L2 OrderBook depth streaming tour in `example/`.

## 1.0.1

- Added high-resolution iOS Simulator showcase screenshots (`pubspec.yaml` gallery & `README.md`) and pre-activated multi-pane synchronized crosshair in the financial terminal example.

## 1.0.0

- **Initial Stable Release of `zero_chart` by RedLight Apps (`https://redlightapps.com`).**
- **LTTB Visual Downsampler (`LttbDownsampler`):** Largest-Triangle-Three-Buckets $O(N)$ algorithm preserving visual peaks and troughs while reducing 100,000+ streaming points to screen pixel density.
- **Technical Indicators Engine (`TechnicalIndicators`):** Built-in zero-allocation calculators for Simple Moving Average (`SMA`), Exponential Moving Average (`EMA`), Relative Strength Index (`RSI`), and Bollinger Bands.
- **Synchronized Multi-Pane Crosshair (`SynchronizedChartController`):** Sub-frame cursor synchronization linking price, volume, and indicator panes without rebuilding parent widget trees.
- **120Hz OHLCV Candlestick & Volume Chart (`ZeroCandlestickChart`):** Interactive pinch-to-zoom, pan, SMA/EMA/Bollinger overlays, and live crosshair HUD.
- **Real-Time L2 OrderBook Depth & Streaming Area Chart (`ZeroDepthChart`, `ZeroLineAreaChart`):** Cumulative bid/ask market depth walls and high-frequency telemetry area charts.
