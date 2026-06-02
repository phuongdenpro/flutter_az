// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_demo_app/main.dart';

void main() {
  testWidgets('Riverpod example loads greeting and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.textContaining('Riverpod Provider'), findsOneWidget);
    expect(find.text('Tải lại số random'), findsOneWidget);
    expect(find.text('Tăng'), findsOneWidget);
  });
}
