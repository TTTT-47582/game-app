import 'package:flutter/material.dart';

import '../../../engine/sudoku/sudoku.dart';

/// Renders a [SudokuBoard] as a tappable grid. Box boundaries get a thicker
/// border, the selected cell and its row/column/box peers are shaded, and
/// conflicting cells are marked with both an underline and an icon so the
/// signal never depends on color alone.
class SudokuGridView extends StatelessWidget {
  const SudokuGridView({
    super.key,
    required this.board,
    required this.givens,
    required this.conflicts,
    required this.selected,
    required this.onCellTap,
    this.notes = const {},
  });

  final SudokuBoard board;
  final SudokuBoard givens;
  final Set<SudokuCell> conflicts;
  final SudokuCell? selected;
  final ValueChanged<SudokuCell> onCellTap;

  /// Candidate numbers penciled into empty cells, keyed by cell.
  final Map<SudokuCell, Set<int>> notes;

  @override
  Widget build(BuildContext context) {
    final size = board.size;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < size.side; row++)
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < size.side; col++)
                  Expanded(
                    child: _SudokuCellView(
                      value: board.at(row, col),
                      isGiven: givens.at(row, col) != 0,
                      hasConflict: conflicts.contains(SudokuCell(row, col)),
                      isSelected: selected == SudokuCell(row, col),
                      isPeer: _isPeer(row, col, size),
                      notes: notes[SudokuCell(row, col)],
                      thickRight: _isBoxBoundary(col + 1, size.boxCols, size.side),
                      thickBottom: _isBoxBoundary(row + 1, size.boxRows, size.side),
                      colorScheme: colorScheme,
                      onTap: () => onCellTap(SudokuCell(row, col)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  bool _isPeer(int row, int col, SudokuSize size) {
    final sel = selected;
    if (sel == null || (sel.row == row && sel.col == col)) return false;
    final sameRow = sel.row == row;
    final sameCol = sel.col == col;
    final sameBox = size.boxRowStart(sel.row) == size.boxRowStart(row) &&
        size.boxColStart(sel.col) == size.boxColStart(col);
    return sameRow || sameCol || sameBox;
  }

  bool _isBoxBoundary(int boundary, int boxSpan, int side) =>
      boundary % boxSpan == 0 && boundary != side;
}

class _SudokuCellView extends StatelessWidget {
  const _SudokuCellView({
    required this.value,
    required this.isGiven,
    required this.hasConflict,
    required this.isSelected,
    required this.isPeer,
    required this.notes,
    required this.thickRight,
    required this.thickBottom,
    required this.colorScheme,
    required this.onTap,
  });

  final int value;
  final bool isGiven;
  final bool hasConflict;
  final bool isSelected;
  final bool isPeer;
  final Set<int>? notes;
  final bool thickRight;
  final bool thickBottom;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color background = colorScheme.surface;
    if (isSelected) {
      background = colorScheme.primaryContainer;
    } else if (isPeer) {
      background = colorScheme.surfaceContainerHighest;
    } else if (isGiven) {
      background = colorScheme.surfaceContainerLow;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        decoration: BoxDecoration(
          color: background,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
            left: BorderSide(color: colorScheme.outlineVariant),
            right: BorderSide(
              color: colorScheme.outline,
              width: thickRight ? 2.5 : 0.6,
            ),
            bottom: BorderSide(
              color: colorScheme.outline,
              width: thickBottom ? 2.5 : 0.6,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: value == 0
            ? _buildNotes(context)
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: 22,
                  color: hasConflict ? colorScheme.error : colorScheme.onSurface,
                  decoration: hasConflict ? TextDecoration.underline : null,
                  decorationColor: colorScheme.error,
                  decorationThickness: 2,
                ),
              ),
      ),
    );
  }

  Widget? _buildNotes(BuildContext context) {
    final values = notes;
    if (values == null || values.isEmpty) return null;
    final sorted = values.toList()..sort();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 2,
        children: [
          for (final n in sorted)
            Text(
              '$n',
              style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
