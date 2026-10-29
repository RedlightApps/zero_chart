# `zero_chart` — Architecture & Mathematical Reference

## 1. Largest-Triangle-Three-Buckets (`LttbDownsampler`)

Given $N$ input points and a target bucket count $K$, the series is partitioned into $K$ buckets. For each bucket $i \in [1, K-2]$, `LttbDownsampler.downsample` selects the point $P_m$ that maximizes the area of the triangle formed with the previously selected point $P_a$ and the centroid $\bar{P}_{i+1}$ of the next bucket:

$$\text{Area} = \frac{1}{2} \left| (x_a - \bar{x}_{i+1})(y_m - y_a) - (x_a - x_m)(\bar{y}_{i+1} - y_a) \right|$$

## 2. Element-Bypass Multi-Pane Crosshair (`SynchronizedChartController`)

`ZeroCandlestickChart` and `ZeroLineAreaChart` pass `syncController` directly to `CustomPainter(repaint: syncController)`. Pointer hover/pan gestures update `CrosshairSnapshot` and mark only the render objects' paint phase dirty—zero widget rebuilds occur on the main thread.
