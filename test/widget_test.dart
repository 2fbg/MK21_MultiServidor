import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk21_multiservidor/app/mk21_app.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const Mk21App());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
