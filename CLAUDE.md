# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Flutter mobile/tablet app (iOS + Android + tablet) bundling two puzzle mini-games on a shared foundation:

- **Sudoku** — 4x4 / 6x6 / 9x9 boards, board size doubles as the difficulty axis.
- **Block puzzle** (Block Blast-style) — drag-and-drop pieces onto an 8x8 grid, clear lines.

Target audience spans generations: young children, elderly players, and everyone in between. Accessibility is a first-class requirement, not an add-on:

- Color is never the only signal (pair color with shape/pattern); aim for WCAG AA contrast or better.
- Tap targets and text sized for elderly users (minimum 48dp, user-scalable up to 1.5x).
- Difficulty auto-adjusts based on clear time, mistake count, and pause frequency — no aggressive telemetry, just enough signal to soften/tighten the next generated board.
- No accounts required; progress is stored locally on-device only.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run                     # run on connected device/simulator
flutter test                    # run all tests
flutter test test/some_test.dart -n "test name"   # run a single test
flutter analyze                 # static analysis / lint (rules in analysis_options.yaml, flutter_lints package)
flutter build apk|ios|web       # platform builds
```

## Architecture direction

The two games are meant to share one puzzle engine rather than being built as independent apps:

- A common package/module holds grid logic, input handling, local progress persistence, and the difficulty-auto-adjustment logic, so Sudoku and Block puzzle consume the same primitives instead of duplicating them.
- Theming (color palettes, including the accessibility-focused high-contrast palette) is abstracted at this shared layer so both games stay visually and behaviorally consistent.
- `lib/engine/sudoku/` — pure Dart, no Flutter UI deps: `SudokuBoard` (grid + row/col/box validation), `SudokuSolver` (backtracking with a minimum-remaining-values heuristic, also used to verify a generated puzzle has a unique solution), `SudokuGenerator` (fills a random solution then greedily removes clues), `SudokuDifficultyAdjuster` (pure function suggesting the next difficulty from mistakes/pauses/elapsed time), `SudokuProgressStore` (`shared_preferences`-backed save/load of the single in-progress game — no accounts, one save slot, overwritten on new game).
- `lib/features/sudoku/` — `SudokuScreen` wires the engine to UI: cell selection, a notes/candidate-number mode (toggled via the AppBar icon, distinguished by filled-vs-outline icon so it's not color-only), gentle conflict indicators (underline + small icon, never color alone), and a new-game bottom sheet for size/difficulty.
- Block puzzle mode has not been implemented yet.

## Secrets

Confidential values (API keys, tokens, etc.) go in `.env`, which is gitignored (see `.gitignore`: `.env`, `.env.*`, with `.env.example` as the checked-in template). Never commit secrets directly into source or into `pubspec.yaml`.
