import 'package:flutter/material.dart';

class Mk21Theme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF05070D),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE50914),
        secondary: Color(0xFF00A3FF),
        surface: Color(0xFF101522),
      ),
    );
  }
}
