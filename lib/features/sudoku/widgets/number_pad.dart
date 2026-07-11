import 'package:flutter/material.dart';

import '../../../engine/sudoku/sudoku.dart';

/// A row of evenly-spaced digit buttons plus a separate, visually distinct
/// clear button below. Splitting clear onto its own row (rather than
/// wrapping it in with the digits) keeps the digit row evenly filled
/// regardless of board size, and its icon+label shape sets it apart from
/// the digits so it isn't mistaken for one.
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
    return Column(
      children: [
        Row(
          children: [
            for (var value = 1; value <= size.side; value++) ...[
              if (value > 1) const SizedBox(width: 8),
              Expanded(
                child: _DigitButton(
                  label: '$value',
                  onPressed: () => onNumberSelected(value),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.backspace_outlined),
            label: const Text('消す'),
          ),
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(label),
      ),
    );
  }
}
