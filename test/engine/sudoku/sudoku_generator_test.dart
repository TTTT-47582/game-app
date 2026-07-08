import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';

void main() {
  group('SudokuGenerator', () {
    for (final size in SudokuSize.values) {
      for (final difficulty in SudokuDifficulty.values) {
        test('generates a unique, solvable ${size.side}x${size.side} '
            '${difficulty.name} puzzle', () {
          final generator = SudokuGenerator(random: Random(123));
          final puzzle = generator.generate(size, difficulty);

          expect(puzzle.solution.isSolved, isTrue);
          expect(
            SudokuSolver.countSolutions(puzzle.givens, limit: 2),
            1,
            reason: 'puzzle must have exactly one solution',
          );

          // Every given clue must match the solution.
          for (var row = 0; row < size.side; row++) {
            for (var col = 0; col < size.side; col++) {
              final given = puzzle.givens.at(row, col);
              if (given != 0) {
                expect(given, puzzle.solution.at(row, col));
              }
            }
          }
        });
      }

      test('${size.side}x${size.side} easy leaves more clues than hard', () {
        final easy = SudokuGenerator(random: Random(5))
            .generate(size, SudokuDifficulty.easy);
        final hard = SudokuGenerator(random: Random(5))
            .generate(size, SudokuDifficulty.hard);

        int clueCount(SudokuBoard b) =>
            b.toFlat().where((v) => v != 0).length;

        expect(clueCount(easy.givens), greaterThanOrEqualTo(clueCount(hard.givens)));
      });
    }
  });
}
