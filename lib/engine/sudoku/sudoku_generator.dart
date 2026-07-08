import 'dart:math';

import 'sudoku_board.dart';
import 'sudoku_size.dart';
import 'sudoku_solver.dart';

enum SudokuDifficulty { easy, medium, hard }

/// A generated puzzle: the clues shown to the player and the full solution
/// used to grade progress.
class SudokuPuzzle {
  const SudokuPuzzle({
    required this.size,
    required this.givens,
    required this.solution,
  });

  final SudokuSize size;
  final SudokuBoard givens;
  final SudokuBoard solution;
}

/// Generates uniquely-solvable Sudoku puzzles by filling a random full
/// solution, then greedily removing clues while a solver confirms the
/// puzzle still has exactly one solution.
class SudokuGenerator {
  SudokuGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  SudokuPuzzle generate(SudokuSize size, SudokuDifficulty difficulty) {
    final solved = SudokuBoard(size);
    final filled = SudokuSolver.fillRandomSolution(solved, _random);
    assert(filled, 'a freshly generated full solution must always exist');
    final solution = solved.copy();

    final puzzle = solved.copy();
    final positions = [
      for (var row = 0; row < size.side; row++)
        for (var col = 0; col < size.side; col++) SudokuCell(row, col),
    ]..shuffle(_random);

    var cluesRemaining = size.cellCount;
    final target = _targetClues(size, difficulty);

    for (final cell in positions) {
      if (cluesRemaining <= target) break;
      final removed = puzzle.at(cell.row, cell.col);
      puzzle.set(cell.row, cell.col, 0);
      final solutionCount = SudokuSolver.countSolutions(puzzle, limit: 2);
      if (solutionCount == 1) {
        cluesRemaining--;
      } else {
        puzzle.set(cell.row, cell.col, removed);
      }
    }

    return SudokuPuzzle(size: size, givens: puzzle, solution: solution);
  }

  int _targetClues(SudokuSize size, SudokuDifficulty difficulty) {
    final ratio = switch (difficulty) {
      SudokuDifficulty.easy => 0.55,
      SudokuDifficulty.medium => 0.42,
      SudokuDifficulty.hard => 0.32,
    };
    // 17 is the proven minimum clue count for a uniquely-solvable 9x9
    // Sudoku; smaller boards get a proportionally scaled floor.
    final minClues = switch (size) {
      SudokuSize.size4 => 4,
      SudokuSize.size6 => 8,
      SudokuSize.size9 => 17,
    };
    return max((size.cellCount * ratio).round(), minClues);
  }
}
