import 'dart:async';
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
  late List<OhlcvCandle> _candles;
  late List<ChartPoint> _rsiPoints;
  late List<OrderBookLevel> _bids;
  late List<OrderBookLevel> _asks;
  Timer? _tickTimer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _rebuildMarketState(0);
    _sync.updateCrosshair(normalizedX: 0.64, localY: 90.0);
    _tickTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
      if (!mounted) return;
      _tick++;
      final normX = 0.50 + math.sin(_tick * 0.09) * 0.38;
      final localY = 95.0 + math.cos(_tick * 0.11) * 45.0;
      _sync.updateCrosshair(normalizedX: normX.clamp(0.08, 0.92), localY: localY);
      setState(() => _rebuildMarketState(_tick));
    });
  }

  void _rebuildMarketState(int step) {
    var price = 68200.0 + math.sin(step * 0.14) * 140.0;
    _candles = List<OhlcvCandle>.generate(48, (i) {
      final wave = math.sin((i + step * 0.25) * 0.32) * 210.0;
      final bias = (i + step ~/ 4) % 3 == 0 ? 95.0 : -55.0;
      final open = price;
      final close = open + wave + bias;
      final high = math.max(open, close) + 115.0 + (i % 4) * 18.0;
      final low = math.min(open, close) - 95.0 - (i % 3) * 15.0;
      price = close;
      return OhlcvCandle(
        timestampMs: 1700000000000 + i * 60000,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 140.0 + ((i + step) % 12) * 42.0,
      );
    });

    final closes = _candles.map((c) => c.close).toList(growable: false);
    final rsi = TechnicalIndicators.rsi(closes, period: 14);
    _rsiPoints = List<ChartPoint>.generate(
      _candles.length,
      (i) => ChartPoint(x: i.toDouble(), y: rsi[i] ?? 52.0),
    );

    final pulse = math.sin(step * 0.18) * 1.6;
    _bids = List<OrderBookLevel>.generate(
      20,
      (i) => OrderBookLevel(
        price: 68400.0 - i * 15.0,
        quantity: (3.5 + i * 1.1 + math.sin(i * 0.5 + step * 0.2) * 1.8 + pulse).clamp(0.5, 40.0),
      ),
    );
    _asks = List<OrderBookLevel>.generate(
      20,
      (i) => OrderBookLevel(
        price: 68420.0 + i * 15.0,
        quantity: (3.0 + i * 1.2 + math.cos(i * 0.4 + step * 0.2) * 1.8 - pulse).clamp(0.5, 40.0),
      ),
    );
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _sync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastClose = _candles.last.close;
    final pct = ((lastClose - 68200.0) / 68200.0 * 100.0);
    final pctLabel = '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFF070910),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E1322),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('zero_chart — 120Hz Multi-Pane Terminal', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('BTC-PERP • OHLCV + Bollinger + RSI(14) + L2 Depth', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Text(pctLabel, style: const TextStyle(color: Color(0xFF00E676), fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
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
