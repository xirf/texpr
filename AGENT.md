# AI Agent Guide - Texpr

## Quick Overview

**Purpose**: Parse and evaluate mathematical expressions written in LaTeX format.
**Pipeline**: LaTeX -> Tokens -> AST -> Result (with variables injected during evaluation)
**Capabilities**: Numeric evaluation, symbolic differentiation, symbolic algebra (simplification, expansion, factorization)

```
1. User Input: "\sin{x}" with {x: 0}
2. Tokenizer: [function:'sin', lbrace, variable:'x', rbrace]
3. Parser: FunctionCall('sin', Variable('x'))
4. Evaluator: Looks up 'sin' -> evaluates Variable('x') with vars -> sin(0) -> 0.0
```

**Key Insight**: Variables aren't injected into AST structure. They're passed alongside during evaluation, allowing AST reuse with different variable values.

---

## Adding New Features

### New Function (5 Steps)

1. **Create handler** in category file:

```dart
// lib/src/functions/trigonometric.dart
double handleNewFunc(FunctionCall func, Map<String, double> vars,
                     double Function(Expression) evaluate) {
  return calculation(evaluate(func.argument));
}
```

2. **Register** in `function_registry.dart`:

```dart
register('newfunc', trig.handleNewFunc);
```

3. **Add tokenizer support** in `tokenizer.dart`:

```dart
case 'newfunc':
  return Token(type: TokenType.function, value: 'newfunc', position: startPos);
```

4. **Add tests** in `test/evaluator_test.dart`

5. **Update docs** (see Post-Implementation Checklist)

### New Constant (3 Steps)

1. **Add to category file** (e.g., `lib/src/constants/mathematical.dart`)
2. **Register** in `constant_registry.dart`
3. **Add tests and docs**

### New AST Node (5 Steps)

1. **Define node class** in appropriate `lib/src/ast/` file with:
   - `toLatex()` method for LaTeX regeneration
   - `accept()` method for visitor pattern
   - `toString()`, `==`, `hashCode` for debugging and comparison

```dart
// lib/src/ast/operations.dart
class NewNode extends Expression {
  final Expression child;
  
  const NewNode(this.child);
  
  @override
  String toLatex() => '\\command{${child.toLatex()}}';
  
  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitNewNode(this, context);
  }
  
  @override
  bool operator ==(Object other) => /* ... */;
  
  @override
  int get hashCode => /* ... */;
}
```

2. **Add visit method** to `ExpressionVisitor` interface in `lib/src/ast/visitor.dart`:

```dart
R visitNewNode(NewNode node, C? context);
```

3. **Implement visitor method** in `EvaluationVisitor` (`lib/src/visitors/evaluation_visitor.dart`):

```dart
@override
dynamic visitNewNode(NewNode node, Map<String, double>? context) {
  final variables = context ?? const {};
  // Implementation logic here
  return result;
}
```

4. **Update parser** in `lib/src/parser.dart` to create the node when parsing

5. **Add tests** with visitor pattern usage

---

## Key Design Patterns

**Registry Pattern**: Centralized function/constant registration with singleton `.instance`
**Visitor Pattern**: AST traversal using visitor pattern for node processing
**Expression Builder**: Test pattern for constructing complex expressions
**Extension System**: `ExtensionRegistry` allows custom LaTeX commands with custom evaluators
**Separation of Concerns**: Functions/constants organized by category, each file has single responsibility
**Feature Modules**: Codebase organized into feature-based modules

---

## Variable Resolution Order

1. User-provided variables (from function call)
2. Built-in constants (`ConstantRegistry`)
3. Error if not found

User-provided parameters override built-in constants by default.

---

## Post-Implementation Checklist

**Critical**: Follow this after ANY new feature implementation.

### 1. Tests (FIRST)

```dart
// test/[category]/[test_name]_test.dart
group('New Feature', () {
  test('basic', () => expect(evaluator.evaluate(r'\new{5}'), equals(result)));
  test('edge case: zero', () => expect(evaluator.evaluate(r'\new{0}'), equals(0)));
  test('error', () => expect(() => evaluator.evaluate(r'\new{bad}'),
  throwsA(isA<EvaluatorException>())));
});
```

### 2. CHANGELOG.md

**Use neutral, factual language** - avoid subjective words like "better", "improved", "cleaner", "comprehensive", "advanced"

```markdown
## [Version] - YYYY-MM-DD

### Added

- **Feature** support: `\command{args}` - description

### Changed

- Modified `function()` to support new parameter
- Reorganized code structure

### Fixed

- Fixed bug where X failed on edge case Y

### Breaking Changes

- **BREAKING**: Changed return type from X to Y
```

### 3. Documentation

**README.md** (if user-facing):

- Add to Supported Functions table
- Add quick example

**Detailed docs** (`doc/[category]/[newcategory].md`):

```markdown
# Category Functions

## `\functionname{arg}`

**Description**: What it does

**Syntax**:
\`\`\`latex
\functionname{argument}
\`\`\`

**Parameters**: `argument` - description (type)

**Returns**: Description

**Examples**:
\`\`\`dart
evaluator.evaluate(r'\functionname{5}'); // Result
evaluator.evaluate(r'\functionname{x}', {'x': 10}); // Result
\`\`\`

**Edge Cases**:

- Zero: returns X
- Negative: returns Y
- Undefined: Throws exception when...

**Notes**: Implementation details, complexity, related functions
```

### 4. Examples

```dart
// example/[category]/[newfeature_demo].dart
void main() {
  final evaluator = Texpr();

  // Basic usage
  print(evaluator.evaluate(r'\newfeature{5}'));

  // Real-world use case
  print(evaluator.evaluate(r'\newfeature{x^2}', {'x': 3}));
}
```

### 5. API Documentation (dartdoc)

````dart
/// Brief one-line description.
///
/// Detailed explanation of behavior and usage.
///
/// **Parameters**:
/// - [param]: Description
///
/// **Returns**: Description
///
/// **Throws**:
/// - [Exception]: When this occurs
///
/// **Example**:
/// ```dart
/// final result = function(arg);
/// ```
double function(double param) { }
````

### 6. Final Verification

- [ ] All tests pass: `dart test`
- [ ] Code formatted: `dart format .`
- [ ] No warnings: `dart analyze`
- [ ] CHANGELOG updated
- [ ] Docs added/updated
- [ ] Examples added
- [ ] README updated (if user-facing)
- [ ] Dartdoc comments added

### 7. Commit

```bash
git add .
git commit -m "feat(scope): brief description

Detailed explanation if needed

Closes #123"
```

**Commit types**: feat, fix, docs, test, refactor, perf, chore

---

## Quick Reference

### File Locations

| Update        | Location            | When                 |
| ------------- | ------------------- | -------------------- |
| Tests         | `test/**/*.dart`    | Typically (first)    |
| Changelog     | `CHANGELOG.md`      | Typically            |
| Function docs | `doc/**/*.md`       | New functions        |
| Examples      | `example/**/*.dart` | Typically            |
| README        | `README.md`         | User-facing features |
| API docs      | Inline dartdoc      | All public APIs      |

### Naming Conventions

- Handler functions: `handleFunctionName`
- Private methods: `_prefixWithUnderscore`
- Constants: `camelCase` for multi-word

### Error Handling

- Use custom exceptions with position info
- Provide clear error messages
- Include context when possible

### Testing

- All features must have tests
- All test should cover edge cases if applicable
- Group related tests
- Descriptive test names

---

## Common Tasks

```bash
# Run tests
dart test
dart test test/evaluator_test.dart  # Specific file

# Format code
dart format .

# Analyze
dart analyze

# Run examples
dart run example/main.dart
```

---

## Priority Documentation Order

1. **Critical**: Tests, CHANGELOG, basic example
2. **Important**: Detailed docs, dartdoc comments
3. **Nice to have**: Advanced examples, edge case docs

## Implementation Guidelines

### Before Starting

1. Understand scope and dependencies
2. Review existing code
3. Plan architecture

### During Implementation

1. Write tests first (TDD)
2. Implement incrementally
3. Run tests frequently
4. Keep commits small

### After Implementation

**Follow the Post-Implementation Checklist** (above)

### **IMPORTANT**

- One task at a time with complete workflow
- Don't skip documentation steps
- Update roadmap status indicators
- Use conventional commits
- Quality over speed

---

## Semantic Versioning

- **Patch** (0.0.X): Bug fixes, docs
- **Minor** (0.X.0): New features, backward compatible
- **Major** (X.0.0): Breaking changes

**For Nightly**: Keep `X.Y.Z-nightly` in pubspec, use `## X.Y.Z Nightly` in CHANGELOG

**For Release**: Update version, date CHANGELOG, create git tag, publish
