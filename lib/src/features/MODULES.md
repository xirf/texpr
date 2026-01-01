# Feature Modules

This directory contains high-level mathematical feature modules.

## Module Organization

### Calculus
- `calculus/` - Limits, summation, products, integration, differentiation
- Entry: `calculus.dart`

### Linear Algebra
- `linear_algebra/` - Matrix and vector operations
- Entry: `linear_algebra.dart`

### Symbolic
- `symbolic/` - Symbolic algebra, simplification, substitution
- Entry: `symbolic.dart`

### Logic
- `logic/` - Comparisons, conditionals, boolean operations
- Entry: `logic.dart`

### Extensions
- `extensions/` - Custom function and variable registration
- Entry: `extensions.dart`

## Design Principles

1. **Separation of Concerns**: Each module handles a specific mathematical domain
2. **Clear Dependencies**: Modules have explicit dependencies on core functionality
3. **Independent Testing**: Each module can be tested independently
4. **Easy Discovery**: Users can import only the features they need

## Adding New Features

To add a new feature module:

1. Create a new directory under `features/`
2. Add the implementation files
3. Create a barrel export file (e.g., `my_feature.dart`)
4. Document the module in this file
5. Export from `features.dart` if it should be part of the public API
