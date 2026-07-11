import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';
import 'package:game_app/features/sudoku/widgets/sudoku_grid_view.dart';

void main() {
  testWidgets('a celebrating cell is highlighted with the tertiary container color', (
    tester,
  ) async {
    final board = SudokuBoard.fromFlat(SudokuSize.size4, const [
      1, 2, 3, 4, //
      3, 4, 1, 2, //
      2, 1, 4, 3, //
      4, 3, 2, 1, //
    ]);
    final theme = ThemeData(colorScheme: const ColorScheme.light());

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SudokuGridView(
            board: board,
            givens: SudokuBoard(SudokuSize.size4),
            conflicts: const {},
            selected: null,
            celebratingCells: {const SudokuCell(0, 0)},
            onCellTap: (_) {},
          ),
        ),
      ),
    );

    final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    final celebratingDecoration = containers.first.decoration as BoxDecoration;
    expect(celebratingDecoration.color, theme.colorScheme.tertiaryContainer);

    // A non-celebrating cell should not pick up the highlight.
    final otherDecoration = containers.elementAt(1).decoration as BoxDecoration;
    expect(otherDecoration.color, isNot(theme.colorScheme.tertiaryContainer));
  });
}
