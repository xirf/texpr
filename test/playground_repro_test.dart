import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Playground Examples Repro', () {
    late Texpr texpr;

    setUp(() {
      texpr = Texpr();
    });

    final examples = [
      '2 + 3 * 4',
      r'\sin(\pi) + \cos(0)',
      r'\det \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
      '(1 + 2i) * (3 - 4i)',
      r'\int_0^1 x^2 dx',
      'let x = 10'
    ];

    for (final code in examples) {
      test('evaluateNumeric("$code")', () {
        try {
          final result = texpr.evaluateNumeric(code);
          print('Success: "$code" -> $result');
        } catch (e) {
          print('Failed: "$code" -> $e');
          // We expect some might fail if evaluateNumeric is strict,
          // but user said ALL fail. If 2+3*4 fails, that's critical.
          if (code == '2 + 3 * 4') {
            fail('Basic arithmetic failed: $e');
          }
          // Rethrow to fail test if needed, or just log
          rethrow;
        }
      });
    }
  });
}
