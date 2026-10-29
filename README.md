<div align="center">

# 📈 zero_chart

**120Hz Element-Bypass Financial & Real-Time Telemetry Charting Engine for Flutter.**  
*Largest-Triangle-Three-Buckets (`LTTB`) downsampling, OHLCV Candlestick & Volume, Level-2 OrderBook Depth, Technical Indicators (`SMA`, `EMA`, `RSI`, `BollingerBands`), and Multi-Pane Synchronized Crosshair — Zero external dependencies.*

[![pub package](https://img.shields.io/pub/v/zero_chart.svg?color=00E676&label=pub.dev)](https://pub.dev/packages/zero_chart)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-2979FF)](https://pub.dev/packages/zero_chart)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-ZERO-FF1744)](https://pub.dev/packages/zero_chart)
[![License: MIT](https://img.shields.io/badge/license-MIT-AA00FF)](https://opensource.org/licenses/MIT)
[![RedLight Apps](https://img.shields.io/badge/Crafted%20by-RedLight%20Apps-FF3D00)](https://redlightapps.com)

<br/>

### 🌍 Available Documentation in 11 Languages
[**English**](#english-overview) · [**Türkçe**](#türkçe-genel-bakış) · [**Deutsch**](#deutsch-übersicht) · [**Français**](#français-aperçu) · [**Español**](#español-resumen) · [**Русский**](#русский-обзор) · [**中文**](#中文-概述) · [**日本語**](#日本語-概要) · [**한국어**](#한국어-개요) · [**العربية**](#العربية-نظرة-عامة) · [**Português**](#português-visão-geral)

📚 **Deep-Dive Guides:** [Full Architecture (`DOCUMENTATION.md`)](DOCUMENTATION.md) · [Türkçe Kılavuz (`doc/TR_GUIDE.md`)](doc/TR_GUIDE.md) · [English Guide (`doc/EN_GUIDE.md`)](doc/EN_GUIDE.md)

<br/>

<img src="https://raw.githubusercontent.com/RedlightApps/zero_chart/main/doc/screenshots/zero_chart_demo.gif" width="320" alt="zero_chart 120Hz Live Animated Demo"/>
&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/RedlightApps/zero_chart/main/doc/screenshots/zero_chart_showcase.png" width="320" alt="zero_chart 120Hz Multi-Pane Financial Terminal Showcase"/>

</div>

---

<a name="english-overview"></a>
## 🇬🇧 English Overview

### Why `zero_chart`?
Conventional Flutter chart libraries rebuild their entire widget tree and `Path` geometry on every live WebSocket tick, causing severe frame drops past 5,000 data points and lacking multi-pane synchronized crosshairs.

**`zero_chart` is engineered for 120Hz trading terminals and real-time telemetry dashboards with zero external dependencies:**
1. **`LttbDownsampler` (Largest-Triangle-Three-Buckets):** Reduces 100,000+ streaming points to screen pixel density in $O(N)$ single-pass time while preserving visual peaks and troughs.
2. **`SynchronizedChartController` (Element-Bypass Multi-Pane Crosshair):** Links stacked charts (`Candlestick` + `RSI` + `Telemetry`) via `CustomPainter(repaint: syncController)` so moving the cursor in one pane updates all panes at 120Hz without `setState`.
3. **`ZeroCandlestickChart` & `TechnicalIndicators`:** Renders OHLCV candles, volume histograms, and built-in `SMA`, `EMA`, `RSI`, and `BollingerBands` overlays.
4. **`ZeroDepthChart` & `ZeroLineAreaChart`:** Cumulative Bid/Ask Level-2 OrderBook liquidity walls with live spread HUD and gradient streaming telemetry curves.

### Quick Start
```yaml
dependencies:
  zero_chart: ^1.0.0
```

```dart
import 'package:zero_chart/zero_chart.dart';

final sync = SynchronizedChartController();

Column(
  children: [
    Expanded(
      flex: 3,
      child: ZeroCandlestickChart(
        candles: myOhlcvCandles,
        syncController: sync,
        smaPeriod: 20,
        emaPeriod: 9,
        showBollingerBands: true,
      ),
    ),
    Expanded(
      flex: 1,
      child: ZeroLineAreaChart(
        points: myRsiPoints,
        syncController: sync,
      ),
    ),
    Expanded(
      flex: 2,
      child: ZeroDepthChart(bids: myBids, asks: myAsks),
    ),
  ],
);
```

---

<a name="türkçe-genel-bakış"></a>
## 🇹🇷 Türkçe — Genel Bakış

`zero_chart`, Flutter için geliştirilmiş **sıfır harici bağımlılıklı, 120Hz Element-Bypass finansal ve gerçek zamanlı telemetri grafik motorudur**.
- **`LttbDownsampler`:** 100.000+ canlı akış verisini tepe ve dip noktalarını kaybetmeden $O(N)$ karmaşıklıkta ekran piksel yoğunluğuna indirger.
- **`SynchronizedChartController` (Multi-Pane Crosshair):** Alt alta dizilmiş Mum (`ZeroCandlestickChart`), İndikatör (`ZeroLineAreaChart`) ve Derinlik (`ZeroDepthChart`) grafiklerinde imleci `setState` olmadan 120Hz hızında senkronize eder.
- **`TechnicalIndicators`:** Dahili `SMA`, `EMA`, `RSI` ve `BollingerBands` hesaplayıcıları içerir.

---

<a name="deutsch-übersicht"></a>
## 🇩🇪 Deutsch — Übersicht

`zero_chart` ist eine **120Hz Element-Bypass Finanz- und Echtzeit-Telemetrie-Chart-Engine** für Flutter ohne externe Abhängigkeiten (`LttbDownsampler`, `ZeroCandlestickChart`, `ZeroDepthChart`, `TechnicalIndicators`, `SynchronizedChartController`).

---

<a name="français-aperçu"></a>
## 🇫🇷 Français — Aperçu

`zero_chart` est un **moteur graphique financier et de télémétrie temps réel à 120Hz** pour Flutter sans dépendance externe (`LttbDownsampler`, chandeliers OHLCV, carnet d'ordres L2, `SMA`/`EMA`/`RSI`/`Bollinger` et curseur multi-panneaux synchronisé).

---

<a name="español-resumen"></a>
## 🇪🇸 Español — Resumen

`zero_chart` es un **motor de gráficos financieros y telemetría en tiempo real a 120Hz** para Flutter sin dependencias externas (`LttbDownsampler`, velas OHLCV, profundidad de mercado L2, indicadores técnicos y cursor sincronizado).

---

<a name="русский-обзор"></a>
## 🇷🇺 Русский — Обзор

`zero_chart` — это **финансовый и телеметрический графический движок 120Hz** для Flutter без внешних зависимостей (`LttbDownsampler`, свечи OHLCV, стакан глубины L2, индикаторы `SMA`/`EMA`/`RSI`/`Bollinger` и синхронизированный перекрестный курсор).

---

<a name="中文-概述"></a>
## 🇨🇳 中文 — 概述

`zero_chart` 是专为 Flutter 打造的**零外部依赖 120Hz 金融与实时遥测图表引擎**，内置 `LttbDownsampler` 降采样、OHLCV K 线图、L2 订单簿深度图、`SMA`/`EMA`/`RSI`/`BollingerBands` 指标以及多面板同步十字光标。

---

<a name="日本語-概要"></a>
## 🇯🇵 日本語 — 概要

`zero_chart` は外部依存ゼロの **Flutter 向け 120Hz 金融・リアルタイムテレメトリチャートエンジン**です（`LttbDownsampler`、OHLCV ローソク足、L2 板情報デプスチャート、テクニカル指標、マルチペイン同期クロスヘア内蔵）。

---

<a name="한국어-개요"></a>
## 🇰🇷 한국어 — 개요

`zero_chart`는 외부 의존성이 없는 **Flutter용 120Hz 금융 및 실시간 텔레메트리 차트 엔진**입니다 (`LttbDownsampler`, OHLCV 캔들스틱, L2 호가 깊이 차트, 보조지표 및 다중 패널 동기화 크로스헤어 지원).

---

<a name="العربية-نظرة-عامة"></a>
## 🇸🇦 العربية — نظرة عامة

`zero_chart` هو **محرك رسوم بيانية مالية وقياسات فورية بسرعة 120Hz** لـ Flutter بدون تبعيات خارجية (`LttbDownsampler`، شموع OHLCV، عمق السوق L2، المؤشرات الفنية، ومؤشر متزامن متعدد اللوحات).

---

<a name="português-visão-geral"></a>
## 🇧🇷 Português — Visão Geral

`zero_chart` é um **motor de gráficos financeiros e telemetria em tempo real a 120Hz** para Flutter com zero dependências externas (`LttbDownsampler`, candlesticks OHLCV, profundidade L2, indicadores técnicos e crosshair sincronizado).

---

## 💖 Sponsor & Support

Crafted with precision by **[RedLight Apps](https://redlightapps.com)** (Yusuf Kaval).
- ☕ [Buy Me a Coffee](https://www.buymeacoffee.com/yusufkaval)
- 💜 [GitHub Sponsors (@kvlyusuf)](https://github.com/sponsors/kvlyusuf)
- 🌐 [RedLight Apps Official Website](https://redlightapps.com)
