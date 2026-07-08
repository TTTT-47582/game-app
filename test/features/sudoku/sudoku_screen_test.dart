import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/features/sudoku/sudoku_screen.dart';
import 'package:game_app/features/sudoku/widgets/number_pad.dart';
import 'package:game_app/features/sudoku/widgets/sudoku_grid_view.dart';

void main() {
  testWidgets('tapping an empty cell then a digit fills it in', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SudokuScreen()),
    );

    final gridView = tester.widget<SudokuGridView>(
      find.byType(SudokuGridView),
    );
    final board = gridView.board;
    final givens = gridView.givens;

    // Find an empty (non-given) cell to type into.
    var targetRow = -1, targetCol = -1;
    outer:
    for (var row = 0; row < board.size.side; row++) {
      for (var col = 0; col < board.size.side; col++) {
        if (givens.at(row, col) == 0) {
          targetRow = row;
          targetCol = col;
          break outer;
        }
      }
    }
    expect(targetRow, greaterThanOrEqualTo(0), reason: 'puzzle must have empty cells');

    final cellFinder = find
        .descendant(
          of: find.byType(SudokuGridView),
          matching: find.byType(GestureDetector),
        )
        .at(targetRow * board.size.side + targetCol);
    await tester.tap(cellFinder);
    await tester.pump();

    final numberOneFinder = find.descendant(
      of: find.byType(NumberPad),
      matching: find.text('1'),
    );
    await tester.ensureVisible(numberOneFinder);
    await tester.tap(numberOneFinder);
    await tester.pump();

    final updatedGrid = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(updatedGrid.board.at(targetRow, targetCol), 1);
  });

  testWidgets('new game sheet regenerates the board at the chosen size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SudokuScreen()),
    );

    await tester.tap(find.byTooltip('新しいパズル'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('4x4'));
    await tester.pump();
    await tester.tap(find.text('この設定で始める'));
    await tester.pumpAndSettle();

    final gridView = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(gridView.board.size.side, 4);
  });
}
