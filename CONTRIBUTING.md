# Contributing to FinWise

First off, thank you for considering contributing to FinWise! It's people like you that make FinWise a better tool for everyone.

## Code of Conduct

By participating in this project, you are expected to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

- **Check for existing issues.** Someone might have already reported the same bug.
- **Provide a clear description.** What was the expected behavior? What actually happened?
- **Include steps to reproduce.** Help us see the bug in action.

### Suggesting Enhancements

- **Check for existing suggestions.**
- **Explain the "Why".** Why is this feature needed? How does it benefit the users?

### Pull Requests

### Branching Strategy

To keep the project organized, we follow a simple **Feature Branch Workflow**:

1. **Target Branch:** Semua Pull Request harus diarahkan ke branch **`main`**.
2. **Branch Naming:** Gunakan prefix yang jelas untuk branch kamu:
   - `feature/nama-fitur` : Untuk penambahan fitur baru.
   - `fix/nama-bug` : Untuk perbaikan bug.
   - `docs/nama-dokumen` : Untuk pembaruan dokumentasi.
   - `refactor/nama-modul` : Untuk pembersihan kode tanpa mengubah fungsionalitas.

### Workflow Langkah-demi-Langkah

1. **Fork the repository.**
2. **Create a new branch.** Contoh: `git checkout -b feature/ai-grounding-fix`.
3. **Write clean code.** Follow the existing style and include tests if possible.
4. **Update documentation.** If you change how something works, update the README or docs.
5. **Submit the PR.** Provide a clear summary of your changes.

## Development Setup

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone your fork.
3. Run `flutter pub get`.
4. Run the app: `flutter run`.

## Style Guide

- Follow the [official Dart style guide](https://dart.dev/guides/language/analysis-options).
- Keep functions small and focused.
- Use descriptive variable names.

Happy coding!
