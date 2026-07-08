import 'dart:math';

import 'sudoku_board.dart';

/// Backtracking Sudoku solver with a minimum-remaining-values heuristic,
/// used both to solve/validate boards and to check puzzle uniqueness
/// during generation.
class SudokuSolver {
  const SudokuSolver._();

  /// Fills [board] in place with a randomized valid solution. Returns false
  /// (leaving [board] unchanged) if the current givens have no solution.
  static bool fillRandomSolution(SudokuBoard board, Random random) {
    return _solve(board, random: random, limit: 1, keepFirstSolution: true) >
        0;
  }

  /// Solves [board] in place. Returns false (leaving [board] unchanged) if
  /// there is no solution.
  static bool solve(SudokuBoard board) {
    return _solve(board, limit: 1, keepFirstSolution: true) > 0;
  }

  /// Counts distinct solutions for [board], stopping early once [limit] is
  /// reached. Does not mutate [board]. A puzzle is uniquely solvable iff
  /// `countSolutions(board, limit: 2) == 1`.
  static int countSolutions(SudokuBoard board, {int limit = 2}) {
    final working = board.copy();
    return _solve(working, limit: limit, keepFirstSolution: false);
  }

  static int _solve(
    SudokuBoard board, {
    Random? random,
    required int limit,
    required bool keepFirstSolution,
  }) {
    final cell = _findMostConstrainedCell(board);
    if (cell == null) return 1;

    final candidates = [
      for (var v = 1; v <= board.size.side; v++)
        if (board.canPlace(cell.row, cell.col, v)) v,
    ];
    if (random != null) candidates.shuffle(random);

    var total = 0;
    for (final value in candidates) {
      board.set(cell.row, cell.col, value);
      total += _solve(
        board,
        random: random,
        limit: limit - total,
        keepFirstSolution: keepFirstSolution,
      );
      if (total >= limit) {
        if (keepFirstSolution && total == 1) return total;
        board.set(cell.row, cell.col, 0);
        return total;
      }
      board.set(cell.row, cell.col, 0);
    }
    return total;
  }

  /// Finds the empty cell with the fewest legal candidates (most
  /// constrained first), returning immediately on a dead end (0 candidates)
  /// or a forced cell (1 candidate) to prune the search early.
  static SudokuCell? _findMostConstrainedCell(SudokuBoard board) {
    SudokuCell? best;
    var bestCount = board.size.side + 1;
    for (var row = 0; row < board.size.side; row++) {
      for (var col = 0; col < board.size.side; col++) {
        if (board.at(row, col) != 0) continue;
        final count = _candidateCount(board, row, col);
        if (count == 0) return SudokuCell(row, col);
        if (count < bestCount) {
          bestCount = count;
          best = SudokuCell(row, col);
          if (count == 1) return best;
        }
      }
    }
    return best;
  }

  static int _candidateCount(SudokuBoard board, int row, int col) {
    var count = 0;
    for (var v = 1; v <= board.size.side; v++) {
      if (board.canPlace(row, col, v)) count++;
    }
    return count;
  }
}
