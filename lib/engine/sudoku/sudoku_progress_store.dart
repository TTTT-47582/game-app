import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sudoku_generator.dart';
import 'sudoku_size.dart';

/// A snapshot of one in-progress Sudoku game, persisted locally so a player
/// can close the app and pick up exactly where they left off. No account or
/// network sync involved.
class SudokuSaveState {
  const SudokuSaveState({
    required this.size,
    required this.difficulty,
    required this.givens,
    required this.solution,
    required this.board,
    required this.notes,
    required this.mistakeCount,
    required this.pauseCount,
    required this.elapsedSeconds,
  });

  final SudokuSize size;
  final SudokuDifficulty difficulty;
  final List<int> givens;
  final List<int> solution;
  final List<int> board;

  /// Candidate notes per cell, keyed by `row * size.side + col`.
  final Map<int, List<int>> notes;
  final int mistakeCount;
  final int pauseCount;
  final int elapsedSeconds;

  Map<String, dynamic> toJson() => {
        'size': size.side,
        'difficulty': difficulty.name,
        'givens': givens,
        'solution': solution,
        'board': board,
        'notes': notes.map((cell, values) => MapEntry(cell.toString(), values)),
        'mistakeCount': mistakeCount,
        'pauseCount': pauseCount,
        'elapsedSeconds': elapsedSeconds,
      };

  static SudokuSaveState? fromJson(Map<String, dynamic> json) {
    try {
      final size = SudokuSize.values.firstWhere((s) => s.side == json['size']);
      final difficulty =
          SudokuDifficulty.values.firstWhere((d) => d.name == json['difficulty']);
      final notesJson = (json['notes'] as Map).cast<String, dynamic>();
      return SudokuSaveState(
        size: size,
        difficulty: difficulty,
        givens: (json['givens'] as List).cast<int>(),
        solution: (json['solution'] as List).cast<int>(),
        board: (json['board'] as List).cast<int>(),
        notes: notesJson.map(
          (cell, values) => MapEntry(int.parse(cell), (values as List).cast<int>()),
        ),
        mistakeCount: json['mistakeCount'] as int,
        pauseCount: json['pauseCount'] as int,
        elapsedSeconds: json['elapsedSeconds'] as int,
      );
    } on Object {
      // Corrupt or outdated save data — treat as if there is none.
      return null;
    }
  }
}

/// Reads and writes the single in-progress Sudoku save via
/// [SharedPreferences]. There is only ever one saved game: starting a new
/// puzzle overwrites it.
class SudokuProgressStore {
  const SudokuProgressStore._();

  static const _key = 'sudoku_save_v1';

  static Future<void> save(SudokuSaveState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  static Future<SudokuSaveState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return SudokuSaveState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
