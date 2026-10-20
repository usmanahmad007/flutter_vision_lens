# Contributing to Flutter Vision Lens 🤝

Thank you for your interest in contributing to `flutter_vision_lens`! We welcome contributions, bug fixes, feature suggestions, and documentation improvements.

## Code of Conduct

Please maintain a welcoming, respectful, and collaborative environment for all contributors.

## Development Setup

1. **Fork and Clone the Repository**:
   ```bash
   git clone https://github.com/usmanahmad007/flutter_vision_lens.git
   cd flutter_vision_lens
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   cd example && flutter pub get && cd ..
   ```

3. **Run Static Analysis and Tests**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run the Example App**:
   ```bash
   cd example
   flutter run
   ```

## Pull Request Guidelines

- Ensure `flutter analyze` passes with **0 issues**.
- Add or update unit/widget tests under `test/` for any new logic or bug fixes.
- Verify all tests pass with `flutter test`.
- Ensure `dart pub publish --dry-run` reports **0 warnings**.
- Keep PRs focused, descriptive, and linked to relevant GitHub issues.

## Reporting Issues

If you encounter a bug or have a feature idea, please open an issue on GitHub:
https://github.com/usmanahmad007/flutter_vision_lens/issues
