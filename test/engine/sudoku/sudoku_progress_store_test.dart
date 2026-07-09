import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/engine/sudoku/sudoku.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SudokuProgressStore', () {
    test('load returns null when nothing has been saved', () async {
      expect(await SudokuProgressStore.load(), isNull);
    });

    test('save then load round-trips every field', () async {
      final state = SudokuSaveState(
        size: SudokuSize.size6,
        difficulty: SudokuDifficulty.hard,
        givens: List.generate(36, (i) => i % 7),
        solution: List.generate(36, (i) => (i % 6) + 1),
        board: List.generate(36, (i) => i % 7),
        notes: {
          0: [1, 2],
          5: [3],
        },
        mistakeCount: 2,
        pauseCount: 1,
        elapsedSeconds: 123,
      );

      await SudokuProgressStore.save(state);
      final loaded = await SudokuProgressStore.load();

      expect(loaded, isNotNull);
      expect(loaded!.size, SudokuSize.size6);
      expect(loaded.difficulty, SudokuDifficulty.hard);
      expect(loaded.givens, state.givens);
      expect(loaded.solution, state.solution);
      expect(loaded.board, state.board);
      expect(loaded.notes, state.notes);
      expect(loaded.mistakeCount, 2);
      expect(loaded.pauseCount, 1);
      expect(loaded.elapsedSeconds, 123);
    });

    test('clear removes the saved game', () async {
      final state = SudokuSaveState(
        size: SudokuSize.size4,
        difficulty: SudokuDifficulty.easy,
        givens: List.filled(16, 0),
        solution: List.filled(16, 1),
        board: List.filled(16, 0),
        notes: const {},
        mistakeCount: 0,
        pauseCount: 0,
        elapsedSeconds: 0,
      );
      await SudokuProgressStore.save(state);
      await SudokuProgressStore.clear();

      expect(await SudokuProgressStore.load(), isNull);
    });
  });
}
