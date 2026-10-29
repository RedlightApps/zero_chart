import 'dart:math' as math;
import 'package:zero_chart/src/model/chart_models.dart';

/// Largest-Triangle-Three-Buckets (LTTB) visual downsampling engine.
///
/// Reduces 100,000+ streaming [ChartPoint] items to [targetCount] in $O(N)$
/// single-pass time while mathematically preserving local peaks, valleys, and
/// visual shape.
abstract final class LttbDownsampler {
  /// Downsamples [data] to at most [targetCount] points using the LTTB
  /// triangle-area maximization algorithm.
  static List<ChartPoint> downsample(List<ChartPoint> data, int targetCount) {
    final length = data.length;
    if (targetCount >= length || targetCount < 3 || length < 3) {
      return data;
    }

    final sampled = List<ChartPoint>.filled(targetCount, data.first);
    final every = (length - 2) / (targetCount - 2);
    var a = 0;

    for (var i = 0; i < targetCount - 2; i++) {
      var avgX = 0.0;
      var avgY = 0.0;
      final avgRangeStart = ((i + 1) * every).floor() + 1;
      var avgRangeEnd = ((i + 2) * every).floor() + 1;
      if (avgRangeEnd > length) avgRangeEnd = length;

      final avgRangeLength = math.max(1, avgRangeEnd - avgRangeStart);
      for (var idx = avgRangeStart; idx < avgRangeEnd; idx++) {
        avgX += data[idx].x;
        avgY += data[idx].y;
      }
      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      final rangeOffs = (i * every).floor() + 1;
      final rangeTo =
          math.min(length - 1, ((i + 1) * every).floor() + 1);

      final pointAX = data[a].x;
      final pointAY = data[a].y;
      var maxArea = -1.0;
      var nextA = rangeOffs;

      for (var idx = rangeOffs; idx < rangeTo; idx++) {
        final area = ((pointAX - avgX) * (data[idx].y - pointAY) -
                (pointAX - data[idx].x) * (avgY - pointAY))
            .abs();
        if (area > maxArea) {
          maxArea = area;
          nextA = idx;
        }
      }

      sampled[i + 1] = data[nextA];
      a = nextA;
    }

    sampled[targetCount - 1] = data.last;
    return sampled;
  }
}

/// Bollinger Bands calculation result (`upper`, `middle`, `lower`).
class BollingerBandPoint {
  /// Creates a [BollingerBandPoint].
  const BollingerBandPoint({
    required this.upper,
    required this.middle,
    required this.lower,
  });

  /// Upper band (`SMA + k * stdDev`).
  final double upper;

  /// Middle band (`SMA`).
  final double middle;

  /// Lower band (`SMA - k * stdDev`).
  final double lower;
}

/// Zero-allocation technical analysis indicator calculator (`SMA`, `EMA`,
/// `RSI`, and `BollingerBands`).
abstract final class TechnicalIndicators {
  /// Computes Simple Moving Average (`SMA`) over [period] for [values].
  ///
  /// Entries before `period - 1` are `null`.
  static List<double?> sma(List<double> values, int period) {
    if (period <= 0 || values.isEmpty) return const [];
    final out = List<double?>.filled(values.length, null);
    var windowSum = 0.0;
    for (var i = 0; i < values.length; i++) {
      windowSum += values[i];
      if (i >= period) {
        windowSum -= values[i - period];
      }
      if (i >= period - 1) {
        out[i] = windowSum / period;
      }
    }
    return out;
  }

  /// Computes Exponential Moving Average (`EMA`) over [period] for [values].
  static List<double?> ema(List<double> values, int period) {
    if (period <= 0 || values.isEmpty) return const [];
    final out = List<double?>.filled(values.length, null);
    final k = 2.0 / (period + 1);
    var prevEma = values.first;
    out[0] = prevEma;
    for (var i = 1; i < values.length; i++) {
      prevEma = values[i] * k + prevEma * (1.0 - k);
      out[i] = prevEma;
    }
    return out;
  }

  /// Computes Wilder's Relative Strength Index (`RSI`) in `[0, 100]` over
  /// [period].
  static List<double?> rsi(List<double> closes, {int period = 14}) {
    if (period <= 0 || closes.length <= period) {
      return List<double?>.filled(closes.length, null);
    }
    final out = List<double?>.filled(closes.length, null);
    var gainSum = 0.0;
    var lossSum = 0.0;
    for (var i = 1; i <= period; i++) {
      final diff = closes[i] - closes[i - 1];
      if (diff >= 0) {
        gainSum += diff;
      } else {
        lossSum -= diff;
      }
    }
    var avgGain = gainSum / period;
    var avgLoss = lossSum / period;
    out[period] = _calcRsi(avgGain, avgLoss);

    for (var i = period + 1; i < closes.length; i++) {
      final diff = closes[i] - closes[i - 1];
      final gain = diff > 0 ? diff : 0.0;
      final loss = diff < 0 ? -diff : 0.0;
      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;
      out[i] = _calcRsi(avgGain, avgLoss);
    }
    return out;
  }

  /// Computes Bollinger Bands (`SMA +/- multiplier * stdDev`) over [period].
  static List<BollingerBandPoint?> bollingerBands(
    List<double> values, {
    int period = 20,
    double multiplier = 2.0,
  }) {
    if (period <= 0 || values.isEmpty) return const [];
    final out = List<BollingerBandPoint?>.filled(values.length, null);
    final smaValues = sma(values, period);
    for (var i = period - 1; i < values.length; i++) {
      final mean = smaValues[i]!;
      var sqDiffSum = 0.0;
      for (var j = i - period + 1; j <= i; j++) {
        final d = values[j] - mean;
        sqDiffSum += d * d;
      }
      final stdDev = math.sqrt(sqDiffSum / period);
      out[i] = BollingerBandPoint(
        upper: mean + multiplier * stdDev,
        middle: mean,
        lower: mean - multiplier * stdDev,
      );
    }
    return out;
  }

  static double _calcRsi(double avgGain, double avgLoss) {
    if (avgLoss == 0.0) return 100.0;
    final rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1.0 + rs));
  }
}
