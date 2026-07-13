import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';
import 'package:game_app/features/sudoku/sudoku_screen.dart';
import 'package:game_app/features/sudoku/widgets/number_pad.dart';
import 'package:game_app/features/sudoku/widgets/sudoku_grid_view.dart';
import 'package:game_app/theme/game_color_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp() => MaterialApp(
        home: SudokuScreen(
          colorTheme: GameColorTheme.forest,
          onColorThemeChanged: (_) {},
        ),
      );

  Finder cellFinderAt(int row, int col, int side) => find
      .descendant(
        of: find.byType(SudokuGridView),
        matching: find.byType(GestureDetector),
      )
      .at(row * side + col);

  ({int row, int col}) findEmptyCell(SudokuGridView gridView) {
    final board = gridView.board;
    final givens = gridView.givens;
    for (var row = 0; row < board.size.side; row++) {
      for (var col = 0; col < board.size.side; col++) {
        if (givens.at(row, col) == 0) return (row: row, col: col);
      }
    }
    throw StateError('puzzle must have empty cells');
  }

  testWidgets('tapping an empty cell then a digit fills it in', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final gridView = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    final target = findEmptyCell(gridView);

    await tester.tap(cellFinderAt(target.row, target.col, gridView.board.size.side));
    await tester.pump();

    final numberOneFinder = find.descendant(
      of: find.byType(NumberPad),
      matching: find.text('1'),
    );
    await tester.ensureVisible(numberOneFinder);
    await tester.tap(numberOneFinder);
    await tester.pump();

    final updatedGrid = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(updatedGrid.board.at(target.row, target.col), 1);
  });

  testWidgets('new game sheet regenerates the board at the chosen size', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('新しいパズル'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('4x4'));
    await tester.pump();
    await tester.tap(find.text('この設定で始める'));
    await tester.pumpAndSettle();

    final gridView = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(gridView.board.size.side, 4);
  });

  testWidgets('notes mode pencils in a candidate instead of the value', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final gridView = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    final target = findEmptyCell(gridView);
    final side = gridView.board.size.side;

    await tester.tap(find.byTooltip('メモ入力: オフ(タップでオン)'));
    await tester.pump();

    await tester.tap(cellFinderAt(target.row, target.col, side));
    await tester.pump();

    final numberTwoFinder = find.descendant(
      of: find.byType(NumberPad),
      matching: find.text('2'),
    );
    await tester.ensureVisible(numberTwoFinder);
    await tester.tap(numberTwoFinder);
    await tester.pump();

    final afterNote = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(afterNote.board.at(target.row, target.col), 0);
    expect(afterNote.notes[SudokuCell(target.row, target.col)], {2});

    // Tapping the same digit again toggles the note back off.
    await tester.tap(numberTwoFinder);
    await tester.pump();
    final afterToggleOff = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(afterToggleOff.notes[SudokuCell(target.row, target.col)], isNull);
  });

  testWidgets('an in-progress game is restored after the screen is recreated', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final gridView = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    final target = findEmptyCell(gridView);
    final side = gridView.board.size.side;

    await tester.tap(cellFinderAt(target.row, target.col, side));
    await tester.pump();
    final numberFinder = find.descendant(
      of: find.byType(NumberPad),
      matching: find.text('1'),
    );
    await tester.ensureVisible(numberFinder);
    await tester.tap(numberFinder);
    await tester.pump();
    // Let the fire-and-forget save complete.
    await tester.pump(const Duration(milliseconds: 50));

    // Recreate the screen (simulates relaunching the app).
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final restoredGrid = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    expect(restoredGrid.board.at(target.row, target.col), 1);
  });

  testWidgets('completing the puzzle shows the win dialog with a celebration badge', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Switch to a 4x4 easy puzzle so there are few empty cells to fill.
    await tester.tap(find.byTooltip('新しいパズル'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4x4'));
    await tester.pump();
    await tester.tap(find.text('やさしい'));
    await tester.pump();
    await tester.tap(find.text('この設定で始める'));
    await tester.pumpAndSettle();

    final gridView = tester.widget<SudokuGridView>(find.byType(SudokuGridView));
    final side = gridView.board.size.side;
    final solution = gridView.givens.copy();
    expect(SudokuSolver.solve(solution), isTrue);

    for (var row = 0; row < side; row++) {
      for (var col = 0; col < side; col++) {
        if (gridView.givens.at(row, col) != 0) continue;
        final cellFinder = cellFinderAt(row, col, side);
        await tester.ensureVisible(cellFinder);
        await tester.tap(cellFinder);
        await tester.pump();
        final digitFinder = find.descendant(
          of: find.byType(NumberPad),
          matching: find.text('${solution.at(row, col)}'),
        );
        await tester.ensureVisible(digitFinder);
        await tester.tap(digitFinder);
        await tester.pump();
      }
    }
    await tester.pumpAndSettle();

    expect(find.text('クリア！'), findsOneWidget);
    expect(find.text('もう一度あそぶ'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
  });

  testWidgets('picking a swatch in the theme sheet reports the new theme', (
    tester,
  ) async {
    GameColorTheme? reported;
    await tester.pumpWidget(
      MaterialApp(
        home: SudokuScreen(
          colorTheme: GameColorTheme.forest,
          onColorThemeChanged: (theme) => reported = theme,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('配色を変える'));
    await tester.pumpAndSettle();

    expect(find.text('桜'), findsOneWidget);
    await tester.tap(find.text('桜'));
    await tester.pumpAndSettle();

    expect(reported, GameColorTheme.sakura);
  });
}
