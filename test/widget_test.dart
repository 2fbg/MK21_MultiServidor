import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk21_multi_servidor/app/mk21_app.dart';

void main() {
  testWidgets('renderiza Home TV Box premium', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const Mk21App());
    await tester.pumpAndSettle();

    expect(find.text('MK21'), findsOneWidget);
    expect(find.text('MultiServidor'), findsOneWidget);
    expect(find.text('Ao Vivo'), findsWidgets);
    expect(find.text('Filmes'), findsWidgets);
    expect(find.text('Séries'), findsWidgets);
    expect(find.byIcon(Icons.connected_tv), findsOneWidget);
  });
}
