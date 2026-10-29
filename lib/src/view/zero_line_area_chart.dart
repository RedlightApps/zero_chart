import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zero_chart/src/common/zero_chart_dict.dart';
import 'package:zero_chart/src/controller/synchronized_chart_controller.dart';
import 'package:zero_chart/src/engine/lttb_and_indicators.dart';
import 'package:zero_chart/src/model/chart_models.dart';

/// 120Hz Element-Bypass streaming line and gradient area chart with automatic
/// [LttbDownsampler] and [SynchronizedChartController] multi-pane crosshair.
class ZeroLineAreaChart extends StatelessWidget {
  /// Creates a [ZeroLineAreaChart].
  const ZeroLineAreaChart({
    required this.points,
    this.syncController,
    this.maxRenderedPoints = 240,
    this.strokeWidth = 2.0,
    this.fillArea = true,
    this.lineColor,
    this.theme = const ZeroChartTheme(),
    this.valueFormatter,
    super.key,
  });

  /// Raw time-series or telemetry points.
  final List<ChartPoint> points;

  /// Optional controller linking crosshair and zoom across multiple panes.
  final SynchronizedChartController? syncController;

  /// Maximum points rendered on screen after LTTB downsampling.
  final int maxRenderedPoints;

  /// Stroke width of the line path.
  final double strokeWidth;

  /// Whether to fill the region under the curve with a vertical gradient.
  final bool fillArea;

  /// Optional override for the line color.
  final Color? lineColor;

  /// Visual theme configuration.
  final ZeroChartTheme theme;

  /// Optional formatter for HUD y-values.
  final String Function(double y)? valueFormatter;

  void _updatePointer(Offset localPosition, double width) {
    if (syncController == null || width <= 0) return;
    syncController!.updateCrosshair(
      normalizedX: (localPosition.dx / width).clamp(0.0, 1.0),
      localY: localPosition.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
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
                painter: _LineAreaPainter(
                  points: points,
                  syncController: syncController,
                  maxRenderedPoints: maxRenderedPoints,
                  strokeWidth: strokeWidth,
                  fillArea: fillArea,
                  lineColor: lineColor ?? theme.accentLineColor,
                  theme: theme,
                  valueFormatter: valueFormatter,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LineAreaPainter extends CustomPainter {
  _LineAreaPainter({
    required this.points,
    required this.syncController,
    required this.maxRenderedPoints,
    required this.strokeWidth,
    required this.fillArea,
    required this.lineColor,
    required this.theme,
    required this.valueFormatter,
  }) : super(repaint: syncController);

  final List<ChartPoint> points;
  final SynchronizedChartController? syncController;
  final int maxRenderedPoints;
  final double strokeWidth;
  final bool fillArea;
  final Color lineColor;
  final ZeroChartTheme theme;
  final String Function(double y)? valueFormatter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = theme.backgroundColor,
    );

    final gridPaint = Paint()
      ..color = theme.gridLineColor
      ..strokeWidth = 1.0;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final startFrac = syncController?.startFraction ?? 0.0;
    final endFrac = syncController?.endFraction ?? 1.0;
    final startIdx = (points.length * startFrac).floor().clamp(0, points.length - 1);
    final endIdx = (points.length * endFrac).ceil().clamp(startIdx + 1, points.length);
    final slice = points.sublist(startIdx, endIdx);
    final sampled = LttbDownsampler.downsample(slice, maxRenderedPoints);
    if (sampled.isEmpty) return;

    final minX = sampled.first.x;
    var maxX = sampled.last.x;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (final p in sampled) {
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    if (maxX <= minX) maxX = minX + 1.0;
    if (maxY <= minY) {
      minY -= 1.0;
      maxY += 1.0;
    }
    final padY = (maxY - minY) * 0.08;
    minY -= padY;
    maxY += padY;

    Offset toCanvas(ChartPoint p) {
      final nx = (p.x - minX) / (maxX - minX);
      final ny = 1.0 - ((p.y - minY) / (maxY - minY));
      return Offset(nx * size.width, ny * size.height);
    }

    final path = Path();
    final firstPt = toCanvas(sampled.first);
    path.moveTo(firstPt.dx, firstPt.dy);
    for (var i = 1; i < sampled.length; i++) {
      final pt = toCanvas(sampled[i]);
      path.lineTo(pt.dx, pt.dy);
    }

    if (fillArea && sampled.length >= 2) {
      final lastPt = toCanvas(sampled.last);
      final fillPath = Path.from(path)
        ..lineTo(lastPt.dx, size.height)
        ..lineTo(firstPt.dx, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.32),
              lineColor.withValues(alpha: 0.0),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );

    final cross = syncController?.crosshair;
    if (cross != null) {
      final idx = ((sampled.length - 1) * cross.normalizedX)
          .round()
          .clamp(0, sampled.length - 1);
      final activePt = sampled[idx];
      final screenPt = toCanvas(activePt);
      final crossPaint = Paint()
        ..color = theme.crosshairColor
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(screenPt.dx, 0),
        Offset(screenPt.dx, size.height),
        crossPaint,
      );
      canvas.drawCircle(screenPt, 4.0, Paint()..color = lineColor);

      final label = valueFormatter != null
          ? valueFormatter!(activePt.y)
          : activePt.y.toStringAsFixed(2);
      final tp = TextPainter(
        text: TextSpan(text: label, style: theme.hudTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, tp.width + 12, tp.height + 6),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, Paint()..color = theme.hudBackgroundColor);
      tp.paint(canvas, const Offset(14, 11));
    }
  }

  @override
  bool shouldRepaint(covariant _LineAreaPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillArea != fillArea;
}
