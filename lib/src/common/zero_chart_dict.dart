/// Centralized UI and accessibility string dictionary for `zero_chart`.
///
/// Prevents hard-coded string literals inside chart widgets and HUD overlays.
abstract final class ZeroChartDict {
  /// Default placeholder when a chart series contains no data points.
  static const String emptySeriesLabel = 'No telemetry or market data';

  /// Bid side label for OrderBook depth charts.
  static const String bidSideLabel = 'BIDS';

  /// Ask side label for OrderBook depth charts.
  static const String askSideLabel = 'ASKS';

  /// Spread label for OrderBook depth charts.
  static const String spreadLabel = 'SPREAD';

  /// Open price prefix in OHLCV HUD.
  static const String openPrefix = 'O:';

  /// High price prefix in OHLCV HUD.
  static const String highPrefix = 'H:';

  /// Low price prefix in OHLCV HUD.
  static const String lowPrefix = 'L:';

  /// Close price prefix in OHLCV HUD.
  static const String closePrefix = 'C:';

  /// Volume prefix in OHLCV HUD.
  static const String volumePrefix = 'V:';
}
