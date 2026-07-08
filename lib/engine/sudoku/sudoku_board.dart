import 'sudoku_size.dart';

/// A cell coordinate on a [SudokuBoard].
class SudokuCell {
  const SudokuCell(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is SudokuCell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}

/// Mutable grid of digits (0 = empty) with Sudoku row/column/box validation.
class SudokuBoard {
  SudokuBoard(this.size, {List<List<int>>? cells})
      : cells = cells ??
            List.generate(size.side, (_) => List.filled(size.side, 0));

  factory SudokuBoard.fromFlat(SudokuSize size, List<int> flat) {
    assert(flat.length == size.cellCount);
    return SudokuBoard(
      size,
      cells: List.generate(
        size.side,
        (row) => flat.sublist(row * size.side, (row + 1) * size.side),
      ),
    );
  }

  final SudokuSize size;
  final List<List<int>> cells;

  int at(int row, int col) => cells[row][col];

  void set(int row, int col, int value) => cells[row][col] = value;

  SudokuBoard copy() => SudokuBoard(
        size,
        cells: [for (final row in cells) List<int>.of(row)],
      );

  List<int> toFlat() => [for (final row in cells) ...row];

  bool get isFull => cells.every((row) => row.every((v) => v != 0));

  /// Whether [value] can legally be placed at ([row], [col]) given the rest
  /// of the board — i.e. no other cell in the same row/column/box already
  /// holds [value]. The cell itself is ignored so this can be used to
  /// re-check a cell that already holds [value].
  bool canPlace(int row, int col, int value) {
    if (value == 0) return true;
    for (var c = 0; c < size.side; c++) {
      if (c != col && cells[row][c] == value) return false;
    }
    for (var r = 0; r < size.side; r++) {
      if (r != row && cells[r][col] == value) return false;
    }
    final boxRowStart = size.boxRowStart(row);
    final boxColStart = size.boxColStart(col);
    for (var r = boxRowStart; r < boxRowStart + size.boxRows; r++) {
      for (var c = boxColStart; c < boxColStart + size.boxCols; c++) {
        if ((r != row || c != col) && cells[r][c] == value) return false;
      }
    }
    return true;
  }

  /// All filled cells that conflict with another cell in their row, column,
  /// or box. Used to surface a gentle "these don't agree yet" hint rather
  /// than a harsh per-cell right/wrong marker.
  Set<SudokuCell> conflicts() {
    final result = <SudokuCell>{};
    for (var row = 0; row < size.side; row++) {
      for (var col = 0; col < size.side; col++) {
        final value = cells[row][col];
        if (value != 0 && !canPlace(row, col, value)) {
          result.add(SudokuCell(row, col));
        }
      }
    }
    return result;
  }

  bool get isSolved => isFull && conflicts().isEmpty;
}
