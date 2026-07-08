import 'package:flutter/material.dart';

import '../../engine/sudoku/sudoku.dart';
import 'widgets/number_pad.dart';
import 'widgets/sudoku_grid_view.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  SudokuSize _size = SudokuSize.size9;
  SudokuDifficulty _difficulty = SudokuDifficulty.medium;
  late SudokuPuzzle _puzzle;
  late SudokuBoard _board;
  SudokuCell? _selected;

  @override
  void initState() {
    super.initState();
    _puzzle = SudokuGenerator().generate(_size, _difficulty);
    _board = _puzzle.givens.copy();
  }

  bool _isGiven(SudokuCell cell) => _puzzle.givens.at(cell.row, cell.col) != 0;

  void _selectCell(SudokuCell cell) => setState(() => _selected = cell);

  void _enterValue(int value) {
    final cell = _selected;
    if (cell == null || _isGiven(cell)) return;
    setState(() => _board.set(cell.row, cell.col, value));
    if (_board.isSolved) _showWinDialog();
  }

  void _clearSelected() {
    final cell = _selected;
    if (cell == null || _isGiven(cell)) return;
    setState(() => _board.set(cell.row, cell.col, 0));
  }

  void _startNewGame(SudokuSize size, SudokuDifficulty difficulty) {
    setState(() {
      _size = size;
      _difficulty = difficulty;
      _puzzle = SudokuGenerator().generate(size, difficulty);
      _board = _puzzle.givens.copy();
      _selected = null;
    });
  }

  Future<void> _showWinDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クリア！'),
        content: const Text('おめでとうございます。すべてのマスが埋まりました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame(_size, _difficulty);
            },
            child: const Text('もう一度あそぶ'),
          ),
        ],
      ),
    );
  }

  Future<void> _openNewGameSheet() async {
    final result = await showModalBottomSheet<(SudokuSize, SudokuDifficulty)>(
      context: context,
      builder: (context) => _NewGameSheet(
        initialSize: _size,
        initialDifficulty: _difficulty,
      ),
    );
    if (result != null) _startNewGame(result.$1, result.$2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '新しいパズル',
            onPressed: _openNewGameSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: SudokuGridView(
                      board: _board,
                      givens: _puzzle.givens,
                      conflicts: _board.conflicts(),
                      selected: _selected,
                      onCellTap: _selectCell,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NumberPad(
                    size: _size,
                    onNumberSelected: _enterValue,
                    onClear: _clearSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewGameSheet extends StatefulWidget {
  const _NewGameSheet({
    required this.initialSize,
    required this.initialDifficulty,
  });

  final SudokuSize initialSize;
  final SudokuDifficulty initialDifficulty;

  @override
  State<_NewGameSheet> createState() => _NewGameSheetState();
}

class _NewGameSheetState extends State<_NewGameSheet> {
  late SudokuSize _size = widget.initialSize;
  late SudokuDifficulty _difficulty = widget.initialDifficulty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('盤面の大きさ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<SudokuSize>(
            segments: const [
              ButtonSegment(value: SudokuSize.size4, label: Text('4x4')),
              ButtonSegment(value: SudokuSize.size6, label: Text('6x6')),
              ButtonSegment(value: SudokuSize.size9, label: Text('9x9')),
            ],
            selected: {_size},
            onSelectionChanged: (s) => setState(() => _size = s.first),
          ),
          const SizedBox(height: 24),
          Text('難易度', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<SudokuDifficulty>(
            segments: const [
              ButtonSegment(value: SudokuDifficulty.easy, label: Text('やさしい')),
              ButtonSegment(value: SudokuDifficulty.medium, label: Text('ふつう')),
              ButtonSegment(value: SudokuDifficulty.hard, label: Text('むずかしい')),
            ],
            selected: {_difficulty},
            onSelectionChanged: (s) => setState(() => _difficulty = s.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop((_size, _difficulty)),
            child: const Text('この設定で始める'),
          ),
        ],
      ),
    );
  }
}
