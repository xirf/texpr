---
name: Performance Issue
about: Report performance problems or optimization opportunities
title: "[PERFORMANCE] "
labels: performance
assignees: ""
---

## Performance Issue Description

<!-- Describe the performance problem you're experiencing -->

## Reproduction Steps

1.
2.
3.

## Minimal Code Example

```dart
import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();
  // Code that demonstrates the performance issue
}
```

## Performance Metrics

<!-- Provide any measurements you have -->

- **Execution Time**: <!-- e.g., 500ms for a simple expression -->
- **Memory Usage**: <!-- if applicable -->
- **Expression Complexity**: <!-- e.g., deeply nested, large number of operations -->

## Expected Performance

<!-- What performance would you expect? -->

## Environment

- **Package Version**: <!-- e.g., 0.1.5 -->
- **Dart Version**: <!-- Run `dart --version` -->
- **Platform**: <!-- e.g., macOS, Windows, Linux, Web, iOS, Android -->
- **Cache Configuration**: <!-- e.g., default, disabled, custom -->

## Profiling Data

<!-- If you've done any profiling, include relevant data here -->

```
Paste profiling output here
```

## Suggested Optimization

<!-- If you have ideas for how to improve performance, describe them here -->

## Checklist

- [ ] I have tested with caching enabled
- [ ] I have checked cache statistics (if applicable)
- [ ] I have provided performance measurements
- [ ] I have tested on the latest version
