import 'package:flutter/material.dart';

import 'features/sudoku/sudoku_screen.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'のんびりパズル',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6F6B)),
        visualDensity: VisualDensity.comfortable,
      ),
      home: const SudokuScreen(),
    );
  }
}
