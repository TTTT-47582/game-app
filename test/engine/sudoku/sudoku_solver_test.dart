import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';

void main() {
  group('SudokuSolver', () {
    test('fillRandomSolution produces a solved, conflict-free board', () {
      for (final size in SudokuSize.values) {
        final board = SudokuBoard(size);
        final ok = SudokuSolver.fillRandomSolution(board, Random(42));
        expect(ok, isTrue, reason: 'size ${size.side}');
        expect(board.isSolved, isTrue, reason: 'size ${size.side}');
      }
    });

    test('fillRandomSolution is randomized across seeds', () {
      final a = SudokuBoard(SudokuSize.size9);
      final b = SudokuBoard(SudokuSize.size9);
      SudokuSolver.fillRandomSolution(a, Random(1));
      SudokuSolver.fillRandomSolution(b, Random(2));
      expect(a.toFlat(), isNot(equals(b.toFlat())));
    });

    test('solve completes a partially filled board', () {
      final board = SudokuBoard.fromFlat(SudokuSize.size4, const [
        1, 2, 3, 4, //
        3, 4, 1, 2, //
        2, 1, 4, 3, //
        4, 3, 2, 0, //
      ]);
      final ok = SudokuSolver.solve(board);
      expect(ok, isTrue);
      expect(board.at(3, 3), 1);
    });

    test('solve returns false and leaves an unsolvable board unchanged', () {
      final board = SudokuBoard.fromFlat(SudokuSize.size4, const [
        1, 1, 0, 0, //
        0, 0, 0, 0, //
        0, 0, 0, 0, //
        0, 0, 0, 0, //
      ]);
      final before = board.toFlat();
      final ok = SudokuSolver.solve(board);
      expect(ok, isFalse);
      expect(board.toFlat(), before);
    });

    test('countSolutions caps at the given limit', () {
      // Empty 4x4 board has many solutions; should stop counting at limit.
      final board = SudokuBoard(SudokuSize.size4);
      expect(SudokuSolver.countSolutions(board, limit: 2), 2);
    });

    test('countSolutions is 1 for a fully solved board', () {
      final board = SudokuBoard.fromFlat(SudokuSize.size4, const [
        1, 2, 3, 4, //
        3, 4, 1, 2, //
        2, 1, 4, 3, //
        4, 3, 2, 1, //
      ]);
      expect(SudokuSolver.countSolutions(board, limit: 2), 1);
    });

    test('countSolutions does not mutate the input board', () {
      final board = SudokuBoard(SudokuSize.size4);
      SudokuSolver.fillRandomSolution(board, Random(7));
      board.set(0, 0, 0);
      final before = board.toFlat();
      SudokuSolver.countSolutions(board, limit: 2);
      expect(board.toFlat(), before);
    });
  });
}
