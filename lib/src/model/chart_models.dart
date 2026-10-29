import 'package:flutter/material.dart';

/// 2D point `(x, y)` for high-frequency line, area, or scatter series.
class ChartPoint {
  /// Creates a [ChartPoint].
  const ChartPoint({required this.x, required this.y});

  /// Horizontal coordinate (e.g., timestamp epoch milliseconds or index).
  final double x;

  /// Vertical coordinate (e.g., price, sensor reading, or indicator value).
  final double y;
}

/// Financial OHLCV (Open, High, Low, Close, Volume) candlestick bar.
class OhlcvCandle {
  /// Creates an [OhlcvCandle].
  const OhlcvCandle({
    required this.timestampMs,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0.0,
  });

  /// Unix timestamp in milliseconds.
  final int timestampMs;

  /// Opening price of the interval.
  final double open;

  /// Highest price reached during the interval.
  final double high;

  /// Lowest price reached during the interval.
  final double low;

  /// Closing price of the interval.
  final double close;

  /// Traded volume during the interval.
  final double volume;

  /// Returns `true` when `close >= open` (bullish bar).
  bool get isBullish => close >= open;
}

/// Price/volume level in a Level-2 (L2) market order book.
class OrderBookLevel {
  /// Creates an [OrderBookLevel].
  const OrderBookLevel({required this.price, required this.quantity});

  /// Limit order price level.
  final double price;

  /// Order quantity available at [price].
  final double quantity;
}

/// Visual theme configuration for `zero_chart` canvases.
class ZeroChartTheme {
  /// Creates a [ZeroChartTheme].
  const ZeroChartTheme({
    this.backgroundColor = const Color(0xFF090C14),
    this.gridLineColor = const Color(0xFF161D2F),
    this.bullishColor = const Color(0xFF00E676),
    this.bearishColor = const Color(0xFFFF1744),
    this.accentLineColor = const Color(0xFF38BDF8),
    this.crosshairColor = const Color(0xCC94A3B8),
    this.hudBackgroundColor = const Color(0xD9111726),
    this.hudTextStyle = const TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
    ),
    this.axisTextStyle = const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 10.5,
    ),
  });

  /// Canvas background color.
  final Color backgroundColor;

  /// Subtle horizontal/vertical reference grid line color.
  final Color gridLineColor;

  /// Color for bullish candles and bid depth walls.
  final Color bullishColor;

  /// Color for bearish candles and ask depth walls.
  final Color bearishColor;

  /// Default stroke color for line/area telemetry charts.
  final Color accentLineColor;

  /// Synchronized crosshair line color.
  final Color crosshairColor;

  /// Background color for floating HUD badges.
  final Color hudBackgroundColor;

  /// Text style for HUD values.
  final TextStyle hudTextStyle;

  /// Text style for axis labels.
  final TextStyle axisTextStyle;
}
