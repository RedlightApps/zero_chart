import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zero_chart/src/common/zero_chart_dict.dart';
import 'package:zero_chart/src/controller/synchronized_chart_controller.dart';
import 'package:zero_chart/src/engine/lttb_and_indicators.dart';
import 'package:zero_chart/src/model/chart_models.dart';

/// 120Hz financial OHLCV Candlestick & Volume chart with built-in SMA, EMA,
/// and Bollinger Bands overlays plus [SynchronizedChartController] crosshair.
class ZeroCandlestickChart extends StatelessWidget {
  /// Creates a [ZeroCandlestickChart].
  const ZeroCandlestickChart({
    required this.candles,
    this.syncController,
    this.smaPeriod = 20,
    this.emaPeriod = 9,
    this.showBollingerBands = true,
    this.showVolumeBars = true,
    this.theme = const ZeroChartTheme(),
    super.key,
  });

  /// Ordered list of OHLCV candles.
  final List<OhlcvCandle> candles;
  /// Optional controller synchronizing crosshair and viewport across panes.
  final SynchronizedChartController? syncController;
  /// Period for Simple Moving Average overlay (`null` disables SMA).
  final int? smaPeriod;
  /// Period for Exponential Moving Average overlay (`null` disables EMA).
  final int? emaPeriod;
  /// Whether to draw upper/lower Bollinger Bands (`period: 20, k: 2.0`).
  final bool showBollingerBands;
  /// Whether to render translucent volume bars along the bottom 22% of canvas.
  final bool showVolumeBars;
  /// Visual theme configuration.
  final ZeroChartTheme theme;

  void _updatePointer(Offset local, double width) {
    if (syncController == null || width <= 0) return;
    syncController!.updateCrosshair(
      normalizedX: (local.dx / width).clamp(0.0, 1.0),
      localY: local.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return ColoredBox(
        color: theme.backgroundColor,
        child: Center(
          child: Text(ZeroChartDict.emptySeriesLabel, style: theme.axisTextStyle),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = math.max(1.0, constraints.maxWidth);
        return MouseRegion(
          onHover: (e) => _updatePointer(e.localPosition, w),
          onExit: (_) => syncController?.clearCrosshair(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _updatePointer(d.localPosition, w),
            onPanUpdate: (d) => _updatePointer(d.localPosition, w),
            onPanEnd: (_) => syncController?.clearCrosshair(),
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(w, math.max(1.0, constraints.maxHeight)),
                painter: _CandlestickPainter(
                  candles: candles,
                  syncController: syncController,
                  smaPeriod: smaPeriod,
                  emaPeriod: emaPeriod,
                  showBollinger: showBollingerBands,
                  showVolume: showVolumeBars,
                  theme: theme,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.candles,
    required this.syncController,
    required this.smaPeriod,
    required this.emaPeriod,
    required this.showBollinger,
    required this.showVolume,
    required this.theme,
  }) : super(repaint: syncController);

  final List<OhlcvCandle> candles;
  final SynchronizedChartController? syncController;
  final int? smaPeriod;
  final int? emaPeriod;
  final bool showBollinger;
  final bool showVolume;
  final ZeroChartTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    final gridPaint = Paint()..color = theme.gridLineColor..strokeWidth = 1.0;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final startFrac = syncController?.startFraction ?? 0.0;
    final endFrac = syncController?.endFraction ?? 1.0;
    final sIdx = (candles.length * startFrac).floor().clamp(0, candles.length - 1);
    final eIdx = (candles.length * endFrac).ceil().clamp(sIdx + 1, candles.length);
    final visible = candles.sublist(sIdx, eIdx);
    if (visible.isEmpty) return;

    var minPrice = double.infinity;
    var maxPrice = double.negativeInfinity;
    var maxVol = 1.0;
    final closes = List<double>.generate(visible.length, (i) => visible[i].close);
    for (final c in visible) {
      if (c.low < minPrice) minPrice = c.low;
      if (c.high > maxPrice) maxPrice = c.high;
      if (c.volume > maxVol) maxVol = c.volume;
    }
    final pad = math.max(1e-6, (maxPrice - minPrice) * 0.1);
    minPrice -= pad;
    maxPrice += pad;

    double priceToY(double px) =>
        (1.0 - ((px - minPrice) / (maxPrice - minPrice))) * size.height;

    final slotW = size.width / visible.length;
    final bodyW = (slotW * 0.68).clamp(2.0, 22.0);

    for (var i = 0; i < visible.length; i++) {
      final c = visible[i];
      final cx = (i + 0.5) * slotW;
      final color = c.isBullish ? theme.bullishColor : theme.bearishColor;

      if (showVolume && c.volume > 0) {
        final vh = (c.volume / maxVol) * (size.height * 0.22);
        canvas.drawRect(
          Rect.fromLTWH(cx - bodyW / 2, size.height - vh, bodyW, vh),
          Paint()..color = color.withValues(alpha: 0.18),
        );
      }

      canvas.drawLine(
        Offset(cx, priceToY(c.high)),
        Offset(cx, priceToY(c.low)),
        Paint()..color = color..strokeWidth = 1.2,
      );
      final topY = priceToY(math.max(c.open, c.close));
      final botY = priceToY(math.min(c.open, c.close));
      canvas.drawRect(
        Rect.fromLTWH(cx - bodyW / 2, topY, bodyW, math.max(1.5, botY - topY)),
        Paint()..color = color,
      );
    }

    if (smaPeriod != null) {
      _drawOverlayLine(canvas, TechnicalIndicators.sma(closes, smaPeriod!),
          slotW, priceToY, const Color(0xFFF59E0B));
    }
    if (emaPeriod != null) {
      _drawOverlayLine(canvas, TechnicalIndicators.ema(closes, emaPeriod!),
          slotW, priceToY, theme.accentLineColor);
    }
    if (showBollinger) {
      final bb = TechnicalIndicators.bollingerBands(closes);
      _drawOverlayLine(canvas, bb.map((b) => b?.upper).toList(), slotW,
          priceToY, const Color(0x88A855F7));
      _drawOverlayLine(canvas, bb.map((b) => b?.lower).toList(), slotW,
          priceToY, const Color(0x88A855F7));
    }

    final cross = syncController?.crosshair;
    if (cross != null) {
      final idx = ((visible.length - 1) * cross.normalizedX)
          .round()
          .clamp(0, visible.length - 1);
      final c = visible[idx];
      final cx = (idx + 0.5) * slotW;
      canvas.drawLine(
        Offset(cx, 0),
        Offset(cx, size.height),
        Paint()..color = theme.crosshairColor..strokeWidth = 1.0,
      );
      final hud = '${ZeroChartDict.openPrefix}${c.open.toStringAsFixed(2)}  '
          '${ZeroChartDict.highPrefix}${c.high.toStringAsFixed(2)}  '
          '${ZeroChartDict.lowPrefix}${c.low.toStringAsFixed(2)}  '
          '${ZeroChartDict.closePrefix}${c.close.toStringAsFixed(2)}';
      final tp = TextPainter(
        text: TextSpan(text: hud, style: theme.hudTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(8, 8, tp.width + 14, tp.height + 6),
          const Radius.circular(6),
        ),
        Paint()..color = theme.hudBackgroundColor,
      );
      tp.paint(canvas, const Offset(15, 11));
    }
  }

  void _drawOverlayLine(
    Canvas canvas,
    List<double?> values,
    double slotW,
    double Function(double) priceToY,
    Color color,
  ) {
    final path = Path();
    var started = false;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final pt = Offset((i + 0.5) * slotW, priceToY(v));
      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    if (started) {
      canvas.drawPath(
        path,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) =>
      oldDelegate.candles != candles ||
      oldDelegate.showBollinger != showBollinger ||
      oldDelegate.showVolume != showVolume;
}
