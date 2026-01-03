# Expression Validation

The TeXpr provides a validation API to check expression syntax before evaluation. This is useful for user input validation, form validation, and debugging.

## Overview

Two validation methods are available:

- **`isValid(expression)`** - Quick boolean check
- **`validate(expression)`** - Detailed validation with error information

## Quick Validation with `isValid()`

Use `isValid()` for a simple pass/fail check:

```dart
import 'package:texpr/texpr.dart';

final evaluator = Texpr();

// Valid expressions
print(evaluator.isValid('2 + 3'));           // true
print(evaluator.isValid(r'\sin{0}'));        // true
print(evaluator.isValid(r'x^{2} + 1'));      // true (variables are OK)

// Invalid expressions
print(evaluator.isValid(r'\sin{'));          // false (unclosed brace)
print(evaluator.isValid(r'\unknown{5}'));    // false (unknown command)
print(evaluator.isValid('(2 + 3'));          // false (unclosed parenthesis)
```

### When to Use `isValid()`

- Real-time input validation (e.g., as user types)
- Simple form validation
- Quick syntax checks where details aren't needed
- Performance-critical validation loops

## Detailed Validation with `validate()`

Use `validate()` to get detailed error information:

```dart
final result = evaluator.validate(r'\sin{');

if (!result.isValid) {
  print('Error: ${result.errorMessage}');     // "Expected expression, got: "
  print('Position: ${result.position}');      // Character position
  print('Suggestion: ${result.suggestion}');  // "Check syntax near this position"
  print('Type: ${result.exceptionType}');     // ParserException
}
```

### ValidationResult Properties

| Property        | Type                     | Description                                                   |
| --------------- | ------------------------ | ------------------------------------------------------------- |
| `isValid`       | `bool`                   | Whether the expression is valid                               |
| `errorMessage`  | `String?`                | Error description (null if valid)                             |
| `position`      | `int?`                   | Character position of error (null if unavailable)             |
| `suggestion`    | `String?`                | Suggested fix (null if unavailable)                           |
| `subErrors`     | `List<ValidationResult>` | Additional errors found during validation (since v0.1.6)      |
| `exceptionType` | `Type?`                  | Type of exception (TokenizerException, ParserException, etc.) |

### Multiple Error Reporting

The `validate()` method automatically attempts to recover from syntax errors to find subsequent issues in the expression. This is reported via `subErrors`.

```dart
final result = evaluator.validate(r'2 + ) + }'); 
// Error 1: Unexpected token: )
// Error 2: Unexpected token: }

if (!result.isValid) {
  print('Primary Error: ${result.errorMessage}');
  
  for (final error in result.subErrors) {
    if (error == result) continue; // Skip primary which is also in listing
    print('Also found: ${error.errorMessage} at ${error.position}');
  }
}
```

## Common Validation Scenarios

### Form Validation

```dart
class MathExpressionField extends StatelessWidget {
  final TextEditingController controller;
  final evaluator = Texpr();

  String? validateExpression(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an expression';
    }

    final result = evaluator.validate(value);
    if (!result.isValid) {
      return result.suggestion ?? result.errorMessage;
    }

    return null; // Valid
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validateExpression,
      decoration: InputDecoration(
        labelText: 'Math Expression',
        hintText: r'e.g., \sin{x} + 2',
      ),
    );
  }
}
```

### Real-Time Validation

```dart
class ExpressionValidator extends StatefulWidget {
  @override
  _ExpressionValidatorState createState() => _ExpressionValidatorState();
}

class _ExpressionValidatorState extends State<ExpressionValidator> {
  final evaluator = Texpr();
  final controller = TextEditingController();
  ValidationResult? validationResult;

  void _validateExpression(String expression) {
    setState(() {
      if (expression.isEmpty) {
        validationResult = null;
      } else {
        validationResult = evaluator.validate(expression);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: _validateExpression,
          decoration: InputDecoration(
            labelText: 'LaTeX Expression',
            errorText: validationResult?.isValid == false
                ? validationResult!.errorMessage
                : null,
            suffixIcon: validationResult != null
                ? Icon(
                    validationResult!.isValid ? Icons.check : Icons.error,
                    color: validationResult!.isValid ? Colors.green : Colors.red,
                  )
                : null,
          ),
        ),
        if (validationResult?.suggestion != null)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Suggestion: ${validationResult!.suggestion}',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
```

### Batch Validation

```dart
void validateExpressions(List<String> expressions) {
  final evaluator = Texpr();
  final invalid = <String, ValidationResult>{};

  for (final expr in expressions) {
    final result = evaluator.validate(expr);
    if (!result.isValid) {
      invalid[expr] = result;
    }
  }

  if (invalid.isEmpty) {
    print('All expressions are valid!');
  } else {
    print('Found ${invalid.length} invalid expressions:');
    invalid.forEach((expr, result) {
      print('\n"$expr"');
      print('  Error: ${result.errorMessage}');
      if (result.suggestion != null) {
        print('  Suggestion: ${result.suggestion}');
      }
    });
  }
}
```

## Important Notes

### Variables Are Valid

Validation checks syntax only. Undefined variables do not cause validation to fail:

```dart
// These are all valid - variables don't need to be defined for validation
evaluator.isValid('x');                    // true
evaluator.isValid('x + y');                // true
evaluator.isValid(r'\sin{x}');             // true
```

To check for undefined variables, you need to evaluate with an empty variable map and catch evaluation errors.

### Validation vs Evaluation

| Aspect            | Validation                  | Evaluation                  |
| ----------------- | --------------------------- | --------------------------- |
| **Purpose**       | Check syntax                | Compute result              |
| **Speed**         | Fast (stops at first error) | Slower (full computation)   |
| **Variables**     | Not required                | Required for undefined vars |
| **Errors caught** | Syntax errors (reports all) | Syntax + runtime errors     |
| **Returns**       | bool or ValidationResult    | double or Matrix            |

### Error Suggestions

The validator provides helpful suggestions for common errors:

| Error Type                     | Suggestion                                                        |
| ------------------------------ | ----------------------------------------------------------------- |
| Unclosed braces (`\sin{`)      | "Missing closing brace } - check for unmatched {"                 |
| Unclosed parentheses           | "Missing closing parenthesis ) - check for unmatched ("           |
| Unknown function (`\sinn{5}`)  | "Did you mean 'sin'?" (did-you-mean suggestion)                   |
| Unknown command                | "Check that the function name is spelled correctly"               |
| Undefined variable             | "Provide a value for 'x' in the variables map"                    |
| Division by zero               | "Ensure the denominator is not zero"                              |
| Domain error (log, asin, etc.) | "Input value is outside the valid domain for this function"       |
| Invalid log base               | "Logarithm base must be positive and not equal to 1"              |
| Missing expression             | "Check for missing operands or invalid syntax near this position" |
| `\frac12` syntax               | "Use \\frac{numerator}{denominator} with braces, not \\frac12"    |

#### Did-You-Mean Suggestions

When an unknown function is called, the library uses Levenshtein distance to suggest similar function names:

```dart
try {
  evaluator.evaluate(r'\sinn{x}');
} on EvaluatorException catch (e) {
  print(e.suggestion); // "Did you mean 'sin'?"
}
```

#### Common Mistake Detection

The library can detect common LaTeX syntax mistakes:

- **Missing braces**: `\frac12` should be `\frac{1}{2}`
- **Missing backslash**: `sin(x)` should be `\sin{x}`
- **Unmatched delimiters**: Missing `}` or `)` are detected with counts

## Performance Considerations

- **`isValid()`** is slightly faster than `validate()` as it doesn't construct detailed error info or attempt error recovery
- Both methods parse the expression (tokenize + parse), but don't evaluate it
- For real-time validation, consider debouncing to avoid validating on every keystroke

```dart
// Debounced validation example
Timer? _debounceTimer;

void _onTextChanged(String text) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    // Validate after user stops typing for 300ms
    final result = evaluator.validate(text);
    // Update UI with result
  });
}
```

## Validation with Custom Extensions

Validation works with custom extensions registered via `ExtensionRegistry`:

```dart
final registry = ExtensionRegistry();
registry.registerCommand('custom', (cmd, pos) =>
  Token(type: TokenType.function, value: 'custom', position: pos));

final evaluator = Texpr(extensions: registry);

// Now custom commands are valid
print(evaluator.isValid(r'\custom{5}'));  // true
```

## Best Practices

1. **Validate user input** before evaluation to provide better error messages
2. **Use `isValid()` for simple checks**, `validate()` when you need details
3. **Display suggestions** to help users fix errors
4. **Debounce real-time validation** to avoid excessive parsing
5. **Combine with evaluation errors** for better error handling
6. **Cache validation results** if validating the same expression multiple times
