import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zero_chart/src/common/zero_chart_dict.dart';
import 'package:zero_chart/src/model/chart_models.dart';

/// 120Hz Level-2 (L2) Market OrderBook Depth chart rendering cumulative Bid
/// and Ask liquidity walls and mid-market spread HUD.
class ZeroDepthChart extends StatelessWidget {
  /// Creates a [ZeroDepthChart].
  const ZeroDepthChart({
    required this.bids,
    required this.asks,
    this.theme = const ZeroChartTheme(),
    super.key,
  });

  /// Bid order book levels (buy orders).
  final List<OrderBookLevel> bids;

  /// Ask order book levels (sell orders).
  final List<OrderBookLevel> asks;

  /// Visual theme configuration.
  final ZeroChartTheme theme;

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty && asks.isEmpty) {
      return ColoredBox(
        color: theme.backgroundColor,
        child: Center(
          child: Text(ZeroChartDict.emptySeriesLabel, style: theme.axisTextStyle),
        ),
      );
    }

    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DepthChartPainter(bids: bids, asks: asks, theme: theme),
      ),
    );
  }
}

class _DepthChartPainter extends CustomPainter {
  const _DepthChartPainter({
    required this.bids,
    required this.asks,
    required this.theme,
  });

  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;
  final ZeroChartTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);

    final sortedBids = List<OrderBookLevel>.of(bids)
      ..sort((a, b) => b.price.compareTo(a.price));
    final sortedAsks = List<OrderBookLevel>.of(asks)
      ..sort((a, b) => a.price.compareTo(b.price));

    final cumBids = <ChartPoint>[];
    var runBid = 0.0;
    for (final b in sortedBids) {
      runBid += b.quantity;
      cumBids.add(ChartPoint(x: b.price, y: runBid));
    }

    final cumAsks = <ChartPoint>[];
    var runAsk = 0.0;
    for (final a in sortedAsks) {
      runAsk += a.quantity;
      cumAsks.add(ChartPoint(x: a.price, y: runAsk));
    }

    final maxCum = math.max(1e-6, math.max(runBid, runAsk) * 1.1);
    final midX = size.width * 0.5;

    if (cumBids.isNotEmpty) {
      _drawWall(
        canvas: canvas,
        points: cumBids,
        startX: midX - 2,
        endX: 0,
        height: size.height,
        maxY: maxCum,
        color: theme.bullishColor,
      );
    }
    if (cumAsks.isNotEmpty) {
      _drawWall(
        canvas: canvas,
        points: cumAsks,
        startX: midX + 2,
        endX: size.width,
        height: size.height,
        maxY: maxCum,
        color: theme.bearishColor,
      );
    }

    if (sortedBids.isNotEmpty && sortedAsks.isNotEmpty) {
      final spread = sortedAsks.first.price - sortedBids.first.price;
      final label =
          '${ZeroChartDict.spreadLabel}: ${spread.toStringAsFixed(2)}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: theme.hudTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          midX - (tp.width + 14) / 2,
          8,
          tp.width + 14,
          tp.height + 6,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(box, Paint()..color = theme.hudBackgroundColor);
      tp.paint(canvas, Offset(midX - tp.width / 2, 11));
    }
  }

  void _drawWall({
    required Canvas canvas,
    required List<ChartPoint> points,
    required double startX,
    required double endX,
    required double height,
    required double maxY,
    required Color color,
  }) {
    final path = Path()..moveTo(startX, height);
    final count = points.length;
    for (var i = 0; i < count; i++) {
      final t = count == 1 ? 1.0 : i / (count - 1);
      final x = startX + (endX - startX) * t;
      final y = height * (1.0 - (points[i].y / maxY));
      path.lineTo(x, y);
    }
    final strokePath = Path.from(path);
    path
      ..lineTo(endX, height)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      strokePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _DepthChartPainter oldDelegate) =>
      oldDelegate.bids != bids || oldDelegate.asks != asks;
}
