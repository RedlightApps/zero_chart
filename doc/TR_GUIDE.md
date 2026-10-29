# `zero_chart` — Türkçe Mimari ve Kullanım Kılavuzu

## 1. Neden `zero_chart`?
Standart Flutter grafik paketleri her canlı veri akışında Widget ağacını yeniden oluşturur. `zero_chart`, `CustomPainter(repaint: syncController)` ve $O(N)$ `LttbDownsampler` motoruyla 100.000+ veriyi 120Hz hızında çizer.

## 2. Temel Bileşenler
- **`ZeroCandlestickChart`:** OHLCV mum grafiği, hacim çubukları ve dahili `SMA`, `EMA`, `BollingerBands` katmanları.
- **`ZeroLineAreaChart`:** Otomatik LTTB örneklemeli gerçek zamanlı çizgi ve gradyan alan grafiği.
- **`ZeroDepthChart`:** L2 OrderBook kümülatif alış/satış (Bid/Ask) derinlik duvarları ve Spread HUD göstergesi.
- **`SynchronizedChartController`:** Çoklu grafik panelleri arasında 120Hz senkronize Crosshair imleci.
