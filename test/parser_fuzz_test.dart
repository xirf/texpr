import 'dart:math';

import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Parser Fuzz Testing', () {
    final texpr = Texpr();
    final random = Random(42); // Fixed seed for reproducibility

    test('Random ASCII garbage should not crash parser', () {
      for (var i = 0; i < 1000; i++) {
        final len = random.nextInt(50) + 1;
        final buffer = StringBuffer();
        for (var j = 0; j < len; j++) {
          // Generate printable ASCII characters
          buffer.writeCharCode(random.nextInt(95) + 32);
        }
        final input = buffer.toString();

        try {
          texpr.parse(input);
        } on TexprException {
          // Expected behavior for invalid input
        } catch (e, stack) {
          fail('Parser crashed on input "$input": $e\n$stack');
        }
      }
    });

    test('Structure-aware fuzzing should not crash parser', () {
      final tokens = [
        '\\sin',
        '\\cos',
        '\\frac',
        '{',
        '}',
        '(',
        ')',
        '^',
        '_',
        '+',
        '-',
        '*',
        '/',
        'x',
        'y',
        '1',
        '2',
        '3.14',
        '\\alpha',
        '\\int',
        '\\sum',
        '=',
        '\\sqrt'
      ];

      for (var i = 0; i < 1000; i++) {
        final len = random.nextInt(20) + 1;
        final buffer = StringBuffer();
        for (var j = 0; j < len; j++) {
          buffer.write(tokens[random.nextInt(tokens.length)]);
          if (random.nextBool()) buffer.write(' '); // Random spacing
        }
        final input = buffer.toString();

        try {
          texpr.parse(input);
        } on TexprException {
          // Expected
        } catch (e, stack) {
          fail('Parser crashed on semi-valid input "$input": $e\n$stack');
        }
      }
    });

    // Known crasher regression tests (empty for now)
    test('Known crashers check', () {
      final inputs = <String>[];
      for (final input in inputs) {
        try {
          texpr.parse(input);
        } on TexprException {
          // ok
        } catch (e) {
          fail('Regression: Parser crashed on known input "$input": $e');
        }
      }
    });
  });
}
