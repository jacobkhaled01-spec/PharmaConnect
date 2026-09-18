import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_connect_client/main.dart';

void main() {
  testWidgets('PharmaConnectApp smoke test and title verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PharmaConnectApp());

    // Verify that the title PharmaConnect is displayed
    expect(find.text('PharmaConnect'), findsOneWidget);
    expect(find.text('ابحث عن دوائك الآن'), findsOneWidget);
  });
}
