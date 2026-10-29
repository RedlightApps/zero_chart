import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_chart/zero_chart.dart';

void main() {
  group('LttbDownsampler & TechnicalIndicators tests', () {
    test('downsamples 50,000 points to 200 preserving endpoints and extrema',
        () {
      final raw = List<ChartPoint>.generate(
        50000,
        (i) => ChartPoint(x: i.toDouble(), y: math.sin(i * 0.01) * 100.0),
      );
      raw[25000] = const ChartPoint(x: 25000, y: 9999.0);

      final sampled = LttbDownsampler.downsample(raw, 200);
      expect(sampled.length, 200);
      expect(sampled.first.x, 0.0);
      expect(sampled.last.x, 49999.0);
      expect(sampled.any((p) => p.y == 9999.0), isTrue);
    });

    test('computes SMA, EMA, RSI, and Bollinger Bands accurately', () {
      final prices = List<double>.generate(30, (i) => 100.0 + i * 2.0);
      final sma5 = TechnicalIndicators.sma(prices, 5);
      expect(sma5[3], isNull);
      expect(sma5[4], closeTo(104.0, 1e-6));

      final ema5 = TechnicalIndicators.ema(prices, 5);
      expect(ema5.first, 100.0);
      expect(ema5.last, greaterThan(140.0));

      final rsi14 = TechnicalIndicators.rsi(prices, period: 14);
      expect(rsi14[14], 100.0);

      final bb = TechnicalIndicators.bollingerBands(prices, period: 5);
      expect(bb[4], isNotNull);
      expect(bb[4]!.upper, greaterThan(bb[4]!.middle));
      expect(bb[4]!.lower, lessThan(bb[4]!.middle));
    });
  });

  group('ZeroCandlestickChart, ZeroLineAreaChart & ZeroDepthChart widget tests',
      () {
    testWidgets('renders multi-pane synchronized charts and depth chart',
        (tester) async {
      final sync = SynchronizedChartController();
      final candles = List<OhlcvCandle>.generate(
        40,
        (i) => OhlcvCandle(
          timestampMs: 1700000000000 + i * 60000,
          open: 100.0 + i,
          high: 105.0 + i,
          low: 98.0 + i,
          close: 102.0 + i,
          volume: 1000.0 + i * 50,
        ),
      );
      final linePoints = List<ChartPoint>.generate(
        100,
        (i) => ChartPoint(x: i.toDouble(), y: 50.0 + (i % 20)),
      );
      const bids = [
        OrderBookLevel(price: 99.5, quantity: 12),
        OrderBookLevel(price: 99.0, quantity: 25),
      ];
      const asks = [
        OrderBookLevel(price: 100.5, quantity: 10),
        OrderBookLevel(price: 101.0, quantity: 30),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ZeroCandlestickChart(
                    candles: candles,
                    syncController: sync,
                  ),
                ),
                Expanded(
                  child: ZeroLineAreaChart(
                    points: linePoints,
                    syncController: sync,
                  ),
                ),
                const Expanded(
                  child: ZeroDepthChart(bids: bids, asks: asks),
                ),
              ],
            ),
          ),
        ),
      );

      sync.updateCrosshair(normalizedX: 0.5, localY: 40.0);
      await tester.pump();
      expect(sync.crosshair?.normalizedX, 0.5);

      sync.clearCrosshair();
      await tester.pump();
      expect(sync.crosshair, isNull);
    });
  });
}
