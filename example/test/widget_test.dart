import 'package:flutter_test/flutter_test.dart';
import 'package:zero_chart_example/main.dart';

void main() {
  testWidgets('ZeroChartShowcaseApp renders multi-pane financial terminal',
      (tester) async {
    await tester.pumpWidget(const ZeroChartShowcaseApp());
    expect(find.text('zero_chart — 120Hz Multi-Pane Terminal'), findsOneWidget);
  });
}
