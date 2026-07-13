import 'dart:async';

import 'package:flutter/material.dart';

import 'features/sudoku/sudoku_screen.dart';
import 'theme/game_color_theme.dart';
import 'theme/theme_store.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  GameColorTheme _colorTheme = GameColorTheme.forest;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreTheme());
  }

  Future<void> _restoreTheme() async {
    final saved = await ThemeStore.load();
    if (saved != null && mounted) setState(() => _colorTheme = saved);
  }

  void _changeColorTheme(GameColorTheme theme) {
    setState(() => _colorTheme = theme);
    unawaited(ThemeStore.save(theme));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'のんびりパズル',
      debugShowCheckedModeBanner: false,
      theme: _colorTheme.toThemeData(),
      home: SudokuScreen(
        colorTheme: _colorTheme,
        onColorThemeChanged: _changeColorTheme,
      ),
    );
  }
}
