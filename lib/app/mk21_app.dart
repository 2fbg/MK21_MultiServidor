import 'package:flutter/material.dart';

import '../core/theme/mk21_theme.dart';
import 'startup_gate.dart';

class Mk21App extends StatelessWidget {
  const Mk21App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MK21 MultiServidor',
      debugShowCheckedModeBanner: false,
      theme: Mk21Theme.dark(),
      home: const StartupGate(),
    );
  }
}
