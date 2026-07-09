import 'sudoku_generator.dart';
import 'sudoku_size.dart';

/// Suggests the next puzzle's difficulty from how the player did on the one
/// they just solved. Deliberately coarse — one step up or down per game,
/// based only on mistakes, pauses, and time spent, never shown as a score.
class SudokuDifficultyAdjuster {
  const SudokuDifficultyAdjuster._();

  static SudokuDifficulty next({
    required SudokuDifficulty current,
    required SudokuSize size,
    required int mistakeCount,
    required int pauseCount,
    required Duration elapsed,
  }) {
    final thresholds = _Thresholds.forSize(size);
    final struggled = mistakeCount >= 3 || pauseCount >= 2 || elapsed > thresholds.slow;
    if (struggled) return _oneStepEasier(current);

    final breezed = mistakeCount == 0 && pauseCount == 0 && elapsed < thresholds.fast;
    if (breezed) return _oneStepHarder(current);

    return current;
  }

  static SudokuDifficulty _oneStepEasier(SudokuDifficulty difficulty) => switch (difficulty) {
        SudokuDifficulty.hard => SudokuDifficulty.medium,
        SudokuDifficulty.medium => SudokuDifficulty.easy,
        SudokuDifficulty.easy => SudokuDifficulty.easy,
      };

  static SudokuDifficulty _oneStepHarder(SudokuDifficulty difficulty) => switch (difficulty) {
        SudokuDifficulty.easy => SudokuDifficulty.medium,
        SudokuDifficulty.medium => SudokuDifficulty.hard,
        SudokuDifficulty.hard => SudokuDifficulty.hard,
      };
}

class _Thresholds {
  const _Thresholds(this.fast, this.slow);

  final Duration fast;
  final Duration slow;

  static _Thresholds forSize(SudokuSize size) => switch (size) {
        SudokuSize.size4 => const _Thresholds(Duration(seconds: 40), Duration(seconds: 150)),
        SudokuSize.size6 => const _Thresholds(Duration(seconds: 90), Duration(seconds: 300)),
        SudokuSize.size9 => const _Thresholds(Duration(seconds: 180), Duration(seconds: 600)),
      };
}
