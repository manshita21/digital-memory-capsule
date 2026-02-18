import 'package:flutter_test/flutter_test.dart';
import 'package:digital_memory_capsule/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Digital Memory Capsule'), findsOneWidget);
  });
}
