import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zero_chart/zero_chart.dart';

void main() => runApp(const ZeroChartShowcaseApp());

/// Multi-pane financial trading & LTTB telemetry showcase for `zero_chart`.
class ZeroChartShowcaseApp extends StatefulWidget {
  /// Creates a [ZeroChartShowcaseApp].
  const ZeroChartShowcaseApp({super.key});

  @override
  State<ZeroChartShowcaseApp> createState() => _ZeroChartShowcaseAppState();
}

class _ZeroChartShowcaseAppState extends State<ZeroChartShowcaseApp> {
  final SynchronizedChartController _sync = SynchronizedChartController();
  late final List<OhlcvCandle> _candles;
  late final List<ChartPoint> _rsiPoints;
  late final List<OrderBookLevel> _bids;
  late final List<OrderBookLevel> _asks;

  @override
  void initState() {
    super.initState();
    var price = 68200.0;
    _candles = List<OhlcvCandle>.generate(80, (i) {
      final delta = math.sin(i * 0.25) * 180.0 + (i.isEven ? 65.0 : -45.0);
      final open = price;
      final close = open + delta;
      final high = math.max(open, close) + 95.0;
      final low = math.min(open, close) - 85.0;
      price = close;
      return OhlcvCandle(
        timestampMs: 1700000000000 + i * 60000,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 120.0 + (i % 15) * 35.0,
      );
    });

    final closes = _candles.map((c) => c.close).toList(growable: false);
    final rsi = TechnicalIndicators.rsi(closes, period: 14);
    _rsiPoints = List<ChartPoint>.generate(
      _candles.length,
      (i) => ChartPoint(x: i.toDouble(), y: rsi[i] ?? 50.0),
    );

    _bids = List<OrderBookLevel>.generate(
      24,
      (i) => OrderBookLevel(price: 68400.0 - i * 15.0, quantity: 2.5 + i * 0.8),
    );
    _asks = List<OrderBookLevel>.generate(
      24,
      (i) => OrderBookLevel(price: 68420.0 + i * 15.0, quantity: 2.2 + i * 0.9),
    );
  }

  @override
  void dispose() {
    _sync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFF070910),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E1322),
          title: const Text('zero_chart — 120Hz Multi-Pane Terminal'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: ZeroCandlestickChart(
                candles: _candles,
                syncController: _sync,
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1E293B)),
            Expanded(
              flex: 2,
              child: ZeroLineAreaChart(
                points: _rsiPoints,
                syncController: _sync,
                valueFormatter: (v) => 'RSI(14): ${v.toStringAsFixed(1)}',
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1E293B)),
            Expanded(
              flex: 3,
              child: ZeroDepthChart(bids: _bids, asks: _asks),
            ),
          ],
        ),
      ),
    );
  }
}
