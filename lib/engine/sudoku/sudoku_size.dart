/// Supported Sudoku board sizes. Board size doubles as the difficulty axis:
/// smaller boards suit children/beginners, 9x9 is the classic full game.
enum SudokuSize {
  size4(side: 4, boxRows: 2, boxCols: 2),
  size6(side: 6, boxRows: 2, boxCols: 3),
  size9(side: 9, boxRows: 3, boxCols: 3);

  const SudokuSize({
    required this.side,
    required this.boxRows,
    required this.boxCols,
  });

  /// Number of cells per row/column.
  final int side;

  /// Height of each sub-box in cells.
  final int boxRows;

  /// Width of each sub-box in cells.
  final int boxCols;

  int get cellCount => side * side;

  int boxRowStart(int row) => (row ~/ boxRows) * boxRows;

  int boxColStart(int col) => (col ~/ boxCols) * boxCols;
}
