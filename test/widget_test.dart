import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luma_sub/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('LumaSub HomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify presence of title and key action cards
    expect(find.text('LumaSub'), findsOneWidget);
    expect(find.text('فتح فيديو'), findsOneWidget);
    expect(find.text('استوديو التنسيق'), findsOneWidget);
  });
}
