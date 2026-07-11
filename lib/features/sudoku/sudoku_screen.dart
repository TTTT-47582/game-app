import 'dart:async';

import 'package:flutter/material.dart';

import '../../engine/sudoku/sudoku.dart';
import 'widgets/number_pad.dart';
import 'widgets/sudoku_grid_view.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> with WidgetsBindingObserver {
  SudokuSize _size = SudokuSize.size9;
  SudokuDifficulty _difficulty = SudokuDifficulty.medium;
  late SudokuPuzzle _puzzle;
  late SudokuBoard _board;
  SudokuCell? _selected;
  Map<SudokuCell, Set<int>> _notes = {};
  bool _notesMode = false;
  int _mistakeCount = 0;
  int _pauseCount = 0;
  int _resumedElapsedSeconds = 0;
  final Stopwatch _stopwatch = Stopwatch();
  bool _loading = true;
  Set<SudokuCell> _celebratingCells = {};
  Timer? _celebrationTimer;

  Duration get _elapsed => Duration(seconds: _resumedElapsedSeconds) + _stopwatch.elapsed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restoreOrStartNewGame());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _celebrationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_loading) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _pauseCount++;
        _persist();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_stopwatch.isRunning && !_board.isSolved) {
        _stopwatch.start();
      }
    }
  }

  Future<void> _restoreOrStartNewGame() async {
    final saved = await SudokuProgressStore.load();
    if (saved != null) {
      _size = saved.size;
      _difficulty = saved.difficulty;
      _puzzle = SudokuPuzzle(
        size: saved.size,
        givens: SudokuBoard.fromFlat(saved.size, saved.givens),
        solution: SudokuBoard.fromFlat(saved.size, saved.solution),
      );
      _board = SudokuBoard.fromFlat(saved.size, saved.board);
      _notes = {
        for (final entry in saved.notes.entries)
          SudokuCell(entry.key ~/ saved.size.side, entry.key % saved.size.side):
              entry.value.toSet(),
      };
      _mistakeCount = saved.mistakeCount;
      _pauseCount = saved.pauseCount;
      _resumedElapsedSeconds = saved.elapsedSeconds;
      _stopwatch.start();
      setState(() => _loading = false);
    } else {
      _generateNewPuzzle(_size, _difficulty);
      setState(() => _loading = false);
    }
  }

  bool _isGiven(SudokuCell cell) => _puzzle.givens.at(cell.row, cell.col) != 0;

  void _selectCell(SudokuCell cell) => setState(() => _selected = cell);

  void _enterValue(int value) {
    final cell = _selected;
    if (cell == null || _isGiven(cell)) return;

    if (_notesMode) {
      setState(() {
        final cellNotes = _notes.putIfAbsent(cell, () => <int>{});
        if (!cellNotes.add(value)) cellNotes.remove(value);
        if (cellNotes.isEmpty) _notes.remove(cell);
      });
      _persist();
      return;
    }

    setState(() {
      _board.set(cell.row, cell.col, value);
      _notes.remove(cell);
      final conflicts = _board.conflicts();
      if (conflicts.contains(cell)) _mistakeCount++;
      _celebrateNewlyCompletedUnits(cell, conflicts);
    });
    _persist();
    if (_board.isSolved) unawaited(_onSolved());
  }

  void _celebrateNewlyCompletedUnits(SudokuCell cell, Set<SudokuCell> conflicts) {
    final rowCells = [for (var c = 0; c < _size.side; c++) SudokuCell(cell.row, c)];
    final colCells = [for (var r = 0; r < _size.side; r++) SudokuCell(r, cell.col)];
    final boxRowStart = _size.boxRowStart(cell.row);
    final boxColStart = _size.boxColStart(cell.col);
    final boxCells = [
      for (var r = boxRowStart; r < boxRowStart + _size.boxRows; r++)
        for (var c = boxColStart; c < boxColStart + _size.boxCols; c++) SudokuCell(r, c),
    ];

    final completed = <SudokuCell>{};
    for (final unit in [rowCells, colCells, boxCells]) {
      if (unit.every((c) => _board.at(c.row, c.col) != 0 && !conflicts.contains(c))) {
        completed.addAll(unit);
      }
    }
    if (completed.isEmpty) return;

    _celebratingCells = completed;
    _celebrationTimer?.cancel();
    _celebrationTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _celebratingCells = {});
    });
  }

  void _clearSelected() {
    final cell = _selected;
    if (cell == null || _isGiven(cell)) return;
    setState(() => _board.set(cell.row, cell.col, 0));
    _persist();
  }

  void _generateNewPuzzle(SudokuSize size, SudokuDifficulty difficulty) {
    _size = size;
    _difficulty = difficulty;
    _puzzle = SudokuGenerator().generate(size, difficulty);
    _board = _puzzle.givens.copy();
    _selected = null;
    _notes = {};
    _mistakeCount = 0;
    _pauseCount = 0;
    _resumedElapsedSeconds = 0;
    _celebrationTimer?.cancel();
    _celebratingCells = {};
    _stopwatch
      ..reset()
      ..start();
  }

  void _startNewGame(SudokuSize size, SudokuDifficulty difficulty) {
    setState(() => _generateNewPuzzle(size, difficulty));
    _persist();
  }

  void _persist() {
    if (_loading) return;
    unawaited(
      SudokuProgressStore.save(
        SudokuSaveState(
          size: _size,
          difficulty: _difficulty,
          givens: _puzzle.givens.toFlat(),
          solution: _puzzle.solution.toFlat(),
          board: _board.toFlat(),
          notes: {
            for (final entry in _notes.entries)
              entry.key.row * _size.side + entry.key.col: entry.value.toList(),
          },
          mistakeCount: _mistakeCount,
          pauseCount: _pauseCount,
          elapsedSeconds: _elapsed.inSeconds,
        ),
      ),
    );
  }

  Future<void> _onSolved() async {
    _stopwatch.stop();
    final elapsed = _elapsed;
    final nextDifficulty = SudokuDifficultyAdjuster.next(
      current: _difficulty,
      size: _size,
      mistakeCount: _mistakeCount,
      pauseCount: _pauseCount,
      elapsed: elapsed,
    );
    await SudokuProgressStore.clear();
    await _showWinDialog(nextDifficulty, elapsed);
  }

  Future<void> _showWinDialog(SudokuDifficulty nextDifficulty, Duration elapsed) async {
    final changed = nextDifficulty != _difficulty;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('クリア！'),
        content: Text(
          'おめでとうございます。${_formatDuration(elapsed)}で解けました。'
          '${changed ? '\n次回は${_difficultyLabel(nextDifficulty)}に挑戦してみましょう。' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame(_size, nextDifficulty);
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        actions: [
          if (_notesMode)
            IconButton.filled(
              icon: const Icon(Icons.edit_note),
              tooltip: 'メモ入力: オン(タップでオフ)',
              onPressed: () => setState(() => _notesMode = false),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'メモ入力: オフ(タップでオン)',
              onPressed: () => setState(() => _notesMode = true),
            ),
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
                      notes: _notes,
                      celebratingCells: _celebratingCells,
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

String _difficultyLabel(SudokuDifficulty difficulty) => switch (difficulty) {
      SudokuDifficulty.easy => 'やさしい',
      SudokuDifficulty.medium => 'ふつう',
      SudokuDifficulty.hard => 'むずかしい',
    };

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return minutes > 0 ? '$minutes分$seconds秒' : '$seconds秒';
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
