import 'package:flutter/material.dart';

import '../../../engine/sudoku/sudoku.dart';

/// Digit input row plus a clear button. Buttons are sized at 56dp — above
/// the 48dp minimum tap-target target for elderly/child-friendly input.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.size,
    required this.onNumberSelected,
    required this.onClear,
  });

  final SudokuSize size;
  final ValueChanged<int> onNumberSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var value = 1; value <= size.side; value++)
          _PadButton(
            label: '$value',
            onPressed: () => onNumberSelected(value),
          ),
        _PadButton(
          label: '消',
          onPressed: onClear,
        ),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
