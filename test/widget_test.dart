import 'package:flutter_test/flutter_test.dart';

import 'package:game_app/main.dart';

void main() {
  testWidgets('app launches into the Sudoku screen', (tester) async {
    await tester.pumpWidget(const GameApp());

    expect(find.text('数独'), findsOneWidget);
  });
}
