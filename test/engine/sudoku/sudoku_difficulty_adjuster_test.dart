import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';

void main() {
  group('SudokuDifficultyAdjuster', () {
    test('steps up a level after a clean, fast, unpaused solve', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.easy,
        size: SudokuSize.size9,
        mistakeCount: 0,
        pauseCount: 0,
        elapsed: const Duration(seconds: 60),
      );
      expect(next, SudokuDifficulty.medium);
    });

    test('does not exceed hard', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.hard,
        size: SudokuSize.size9,
        mistakeCount: 0,
        pauseCount: 0,
        elapsed: const Duration(seconds: 60),
      );
      expect(next, SudokuDifficulty.hard);
    });

    test('steps down a level after several mistakes', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.hard,
        size: SudokuSize.size9,
        mistakeCount: 3,
        pauseCount: 0,
        elapsed: const Duration(seconds: 300),
      );
      expect(next, SudokuDifficulty.medium);
    });

    test('steps down a level after taking too long', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.medium,
        size: SudokuSize.size9,
        mistakeCount: 0,
        pauseCount: 0,
        elapsed: const Duration(seconds: 700),
      );
      expect(next, SudokuDifficulty.easy);
    });

    test('steps down a level after multiple pauses', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.medium,
        size: SudokuSize.size9,
        mistakeCount: 0,
        pauseCount: 2,
        elapsed: const Duration(seconds: 200),
      );
      expect(next, SudokuDifficulty.easy);
    });

    test('does not go below easy', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.easy,
        size: SudokuSize.size9,
        mistakeCount: 5,
        pauseCount: 0,
        elapsed: const Duration(seconds: 700),
      );
      expect(next, SudokuDifficulty.easy);
    });

    test('stays the same for an unremarkable solve', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.medium,
        size: SudokuSize.size9,
        mistakeCount: 1,
        pauseCount: 0,
        elapsed: const Duration(seconds: 300),
      );
      expect(next, SudokuDifficulty.medium);
    });

    test('thresholds scale down for smaller boards', () {
      final next = SudokuDifficultyAdjuster.next(
        current: SudokuDifficulty.easy,
        size: SudokuSize.size4,
        mistakeCount: 0,
        pauseCount: 0,
        elapsed: const Duration(seconds: 30),
      );
      expect(next, SudokuDifficulty.medium);
    });
  });
}
