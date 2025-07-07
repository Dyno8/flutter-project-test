// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_injection_container.dart';
import 'helpers/test_app_wrapper.dart';

void main() {
  setUpAll(() async {
    // Initialize test dependencies
    await initTestDependencies();
  });

  tearDownAll(() async {
    // Clean up test dependencies
    await cleanupTestDependencies();
  });

  testWidgets('CareNow app smoke test', (WidgetTester tester) async {
    // Build our test app and trigger a frame.
    await tester.pumpWidget(const TestAppWrapper(child: TestSplashScreen()));

    // Verify that our app loads correctly.
    expect(find.text('CareNow MVP\nComing Soon...'), findsOneWidget);
  });
}
