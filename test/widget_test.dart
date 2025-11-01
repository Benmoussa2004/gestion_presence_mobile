// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gestion_presence_2/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    // Build the app with ProviderScope (required by Riverpod).
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Minimal smoke assertion: the default landing shows the app title
    // when Firebase isn't initialized in tests.
    expect(find.text('Gestion Présence'), findsOneWidget);
  });
}
