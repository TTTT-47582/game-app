import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';

void main() {
  group('SudokuBoard', () {
    test('canPlace rejects duplicate in same row', () {
      final board = SudokuBoard(SudokuSize.size4);
      board.set(0, 0, 1);
      expect(board.canPlace(0, 3, 1), isFalse);
    });

    test('canPlace rejects duplicate in same column', () {
      final board = SudokuBoard(SudokuSize.size4);
      board.set(0, 0, 1);
      expect(board.canPlace(3, 0, 1), isFalse);
    });

    test('canPlace rejects duplicate in same box', () {
      final board = SudokuBoard(SudokuSize.size4);
      board.set(0, 0, 1);
      expect(board.canPlace(1, 1, 1), isFalse);
    });

    test('canPlace allows a value that appears elsewhere but not in scope',
        () {
      final board = SudokuBoard(SudokuSize.size4);
      board.set(0, 0, 1);
      expect(board.canPlace(3, 3, 1), isTrue);
    });

    test('canPlace ignores the cell being re-checked', () {
      final board = SudokuBoard(SudokuSize.size4);
      board.set(0, 0, 1);
      expect(board.canPlace(0, 0, 1), isTrue);
    });

    test('conflicts finds both cells sharing a duplicate value', () {
      final board = SudokuBoard(SudokuSize.size4);
      board.set(0, 0, 1);
      board.set(0, 1, 1);
      expect(board.conflicts(), {const SudokuCell(0, 0), const SudokuCell(0, 1)});
    });

    test('isSolved is false while cells remain empty', () {
      final board = SudokuBoard(SudokuSize.size4);
      expect(board.isSolved, isFalse);
    });

    test('isSolved is true for a full, conflict-free grid', () {
      final board = SudokuBoard.fromFlat(SudokuSize.size4, const [
        1, 2, 3, 4, //
        3, 4, 1, 2, //
        2, 1, 4, 3, //
        4, 3, 2, 1, //
      ]);
      expect(board.isSolved, isTrue);
    });

    test('copy is independent of the original', () {
      final board = SudokuBoard(SudokuSize.size4);
      final copy = board.copy();
      copy.set(0, 0, 1);
      expect(board.at(0, 0), 0);
      expect(copy.at(0, 0), 1);
    });
  });
}
