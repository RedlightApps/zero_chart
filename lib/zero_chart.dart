/// 120Hz Element-Bypass Financial & Real-Time Telemetry Charting Engine for
/// Flutter.
///
/// Engineered by RedLight Apps (https://redlightapps.com) with zero external
/// dependencies:
/// - **LTTB Downsampler ([LttbDownsampler]):** $O(N)$ Largest-Triangle-Three-
///   Buckets algorithm reducing 100,000+ streaming points without losing peaks.
/// - **Technical Indicators ([TechnicalIndicators]):** Zero-allocation `SMA`,
///   `EMA`, `RSI`, and `BollingerBands` calculators.
/// - **Multi-Pane Crosshair ([SynchronizedChartController]):** Sub-frame cursor
///   and zoom synchronization across stacked chart panes.
/// - **Financial & Telemetry Canvases ([ZeroCandlestickChart],
///   [ZeroLineAreaChart], [ZeroDepthChart]):** 120Hz `CustomPainter(repaint:)`
///   renderers.
library;

export 'src/common/zero_chart_dict.dart';
export 'src/controller/synchronized_chart_controller.dart';
export 'src/engine/lttb_and_indicators.dart';
export 'src/model/chart_models.dart';
export 'src/view/zero_candlestick_chart.dart';
export 'src/view/zero_depth_chart.dart';
export 'src/view/zero_line_area_chart.dart';
