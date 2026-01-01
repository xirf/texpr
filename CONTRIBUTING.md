# Contributing to Texpr

Thank you for your interest in contributing! We welcome contributions from the community.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/texpr.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `dart test`
6. Commit with clear messages (see below)
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

```bash
# Install dependencies
dart pub get

# Run tests
dart test

# Run specific test file
dart test test/evaluator_test.dart
```

## Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format .` before committing
- Use meaningful variable and function names
- Add documentation comments for public APIs

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions or changes
- `refactor:` - Code refactoring
- `chore:` - Maintenance tasks

Example:
```
feat: add support for hyperbolic functions

- Add sinh, cosh, tanh handlers
- Update tokenizer to recognize \sinh, \cosh, \tanh
- Add tests for hyperbolic functions
```

## Testing

- All new features must include tests
- Maintain or improve code coverage
- Tests should be clear and focused
- Use descriptive test names

## Adding New Functions

1. Add a handler in the appropriate category file (e.g., `lib/src/functions/trigonometric.dart`); include even small handlers so the function can be found easily.
2. Register in `function_registry.dart`
3. Add LaTeX command to tokenizer if needed
4. Add tests in `test/evaluator_test.dart`
5. Update documentation in `docs/functions/`

## Pull Request Process

1. Update documentation for any new features
2. Add tests for new functionality
3. Ensure all tests pass
4. Update README.md if needed
5. Reference any related issues

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Questions about the codebase
- Suggestions for improvements

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).
