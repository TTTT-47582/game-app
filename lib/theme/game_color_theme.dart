import 'package:flutter/material.dart';

/// Selectable color palettes shared across every game in the app. Each seed
/// color runs through Material 3's `ColorScheme.fromSeed`, which derives
/// tone pairs that keep WCAG AA contrast automatically — palette choice is
/// purely aesthetic, never a contrast trade-off.
enum GameColorTheme {
  forest(label: '森', seedColor: Color(0xFF2E6F6B)),
  sakura(label: '桜', seedColor: Color(0xFFD8869B)),
  sunset(label: '夕焼け', seedColor: Color(0xFFE07A3F)),
  sky(label: '空', seedColor: Color(0xFF4A7FB5));

  const GameColorTheme({required this.label, required this.seedColor});

  final String label;
  final Color seedColor;

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      visualDensity: VisualDensity.comfortable,
    );
  }
}
