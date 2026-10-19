import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('VisionLensDemoApp loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionLensDemoApp());
    expect(find.text('Flutter Vision Lens 🔍'), findsOneWidget);
    expect(find.text('Interactive Visual Intelligence'), findsOneWidget);
  });
}
