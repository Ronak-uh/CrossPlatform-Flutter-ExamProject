import 'package:flutter_test/flutter_test.dart';
import 'package:water_save/main.dart';

void main() {
  testWidgets('WaterSave basic render test', (WidgetTester tester) async {
    await tester.pumpWidget(const WaterSaveApp());
    expect(find.text('WaterSave Dashboard'), findsOneWidget);
  });
}
