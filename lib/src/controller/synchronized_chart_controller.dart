import 'package:flutter/foundation.dart';

/// Shared state snapshot broadcast across multi-pane charts (`Candlestick`,
/// `Volume`, `RSI`, `Telemetry`) at 120Hz via `CustomPainter(repaint: ...)`.
class CrosshairSnapshot {
  /// Creates a [CrosshairSnapshot].
  const CrosshairSnapshot({
    required this.normalizedX,
    this.localY,
    this.activeIndex,
  });

  /// Normalized horizontal cursor position in `[0.0, 1.0]` across the chart
  /// viewport.
  final double normalizedX;

  /// Optional vertical pixel coordinate inside the originating pane.
  final double? localY;

  /// Optional resolved data index under the cursor.
  final int? activeIndex;
}

/// Element-bypass controller that synchronizes crosshair cursor movement and
/// horizontal viewport zoom/pan across multiple stacked chart panes without
/// triggering `setState` in parent widgets.
class SynchronizedChartController extends ChangeNotifier {
  /// Creates a [SynchronizedChartController].
  SynchronizedChartController({
    double startFraction = 0.0,
    double endFraction = 1.0,
  })  : _startFraction = startFraction.clamp(0.0, 1.0),
        _endFraction = endFraction.clamp(0.0, 1.0);

  CrosshairSnapshot? _crosshair;
  double _startFraction;
  double _endFraction;

  /// Active synchronized crosshair position, or `null` when inactive.
  CrosshairSnapshot? get crosshair => _crosshair;

  /// Normalized start of the visible horizontal zoom window (`[0.0, 1.0]`).
  double get startFraction => _startFraction;

  /// Normalized end of the visible horizontal zoom window (`[0.0, 1.0]`).
  double get endFraction => _endFraction;

  /// Broadcasts a new crosshair position to all attached chart painters.
  void updateCrosshair({
    required double normalizedX,
    double? localY,
    int? activeIndex,
  }) {
    _crosshair = CrosshairSnapshot(
      normalizedX: normalizedX.clamp(0.0, 1.0),
      localY: localY,
      activeIndex: activeIndex,
    );
    notifyListeners();
  }

  /// Hides the synchronized crosshair across all attached panes.
  void clearCrosshair() {
    if (_crosshair == null) return;
    _crosshair = null;
    notifyListeners();
  }

  /// Updates the visible horizontal zoom/pan window in `[0.0, 1.0]`.
  void setViewportWindow(double start, double end) {
    final clampedStart = start.clamp(0.0, 0.98);
    final clampedEnd = end.clamp(clampedStart + 0.02, 1.0);
    if (_startFraction == clampedStart && _endFraction == clampedEnd) return;
    _startFraction = clampedStart;
    _endFraction = clampedEnd;
    notifyListeners();
  }
}
