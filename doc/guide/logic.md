# Boolean Logic

TeXpr supports set of boolean algebra operators, allowing for logical comparisons, conditions, and bitwise-like logic within expressions.

## Comparison Operators

These operators compare two values and **always produce a boolean result** (True/False).

### Strict Type Safety
In a **Numeric Context** (e.g. `1 + (x > 0)`), utilizing a boolean result will **throw an error**. Unlike some languages that implicitly convert `true` to `1.0`, TeXpr enforces strict separation between numbers and booleans to prevent logical ambiguities.

| Operator          | Syntax | Alias  | Description                           |
| :---------------- | :----- | :----- | :------------------------------------ |
| **Greater Than**  | `>`    |        | Returns true if left > right.         |
| **Less Than**     | `<`    |        | Returns true if left < right.         |
| **Greater/Equal** | `\ge`  | `\geq` | Returns true if left ≥ right.         |
| **Less/Equal**    | `\le`  | `\leq` | Returns true if left ≤ right.         |
| **Equal**         | `=`    | `==`   | Returns true if values are equal.     |
| **Not Equal**     | `\ne`  | `\neq` | Returns true if values are not equal. |

### Examples
```latex
x > 0        % True if x is positive
\pi \ge 3.14 % True
2 * x = y    % True if equation holds
```

## Boolean Operators

Combine boolean comparisons using standard logical connectives.

| Operator          | Syntax            | Alias         | Description                                    |
| :---------------- | :---------------- | :------------ | :--------------------------------------------- |
| **AND**           | `\land`           | `\wedge`, `&` | True if **both** operands are true.            |
| **OR**            | `\lor`            | `\vee`, `\|`  | True if **either** operand is true.            |
| **NOT**           | `\neg`            | `\lnot`, `!`  | Inverts the truth value.                       |
| **XOR**           | `\oplus`          |               | True if **exactly one** operand is true.       |
| **Implication**   | `\Rightarrow`     | `\implies`    | True unless Left is true and Right is false.   |
| **Biconditional** | `\Leftrightarrow` | `\iff`        | True if both operands have the **same** value. |

### Logic Examples
```latex
% Range check
(x > 0) \land (x < 10)   % True if x is between 0 and 10

% Complex condition
(x = 0) \lor (y = 0)     % True if either x or y is zero

% De Morgan's Law
\neg(A \land B) \iff (\neg A \lor \neg B)  % Always True
```

## Precedence

Operators are evaluated in the order below. Precedence matters for usage without parentheses:

```latex
x > 0 \land y < 10
% Parsed as: (x > 0) \land (y < 10) -> Correct
```

1.  **Groups**: `(...)`
2.  **Arithmetic**: `^`, `*`, `/`, `+`, `-`
3.  **Comparisons**: `>`, `<`, `=`, etc.
4.  **NOT**: `\neg`
5.  **AND**: `\land`
6.  **XOR**: `\oplus`
7.  **OR**: `\lor`
8.  **Implication**: `\Rightarrow`
9.  **Biconditional**: `\Leftrightarrow`

## Type Behavior

*   **Numeric Context**: Booleans cannot be used directly in arithmetic. `1 + true` throws an `EvaluatorException`.
*   **Boolean Context**: Comparison results are preserved as boolean types and can be used in logical operations (`\land`, `\lor`).

## See Also

- [Piecewise Functions](piecewise.md) - Using logic for conditional function definitions.

