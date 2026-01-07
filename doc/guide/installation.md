# Installation

## Prerequisites

- Dart SDK >= 3.0.0
- Flutter (optional, for Flutter projects)

## Add the Dependency

Add TeXpr to your `pubspec.yaml`:

```yaml
dependencies:
  texpr: ^0.0.1
```

Then run:

::: code-group

```bash [Dart]
dart pub get
```

```bash [Flutter]
flutter pub get
```

:::

## Verify Installation

```dart
import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();
  print(evaluator.evaluate(r'2 + 2')); // 4.0
}
```

## Next Steps

Continue to [Quick Start](/guide/quick-start) to learn the basics.
