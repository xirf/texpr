library;

import 'dart:convert';
import 'dart:io';

import 'package:texpr/texpr.dart';

void main(List<String> args) {
  final enforce = args.contains('--enforce');
  final minSpeedup = _readDoubleArg(args, '--min-speedup', 1.02);
  final jsonOut = _readStringArg(args, '--json-out');

  final evaluator = Texpr(cacheConfig: CacheConfig.disabled);

  final parsedAnnotated = evaluator.parse(r'x^2 + y^2 + 1');

  final manualUnannotated = BinaryOp(
    BinaryOp(
      BinaryOp(
          const Variable('x'), BinaryOperator.power, const NumberLiteral(2)),
      BinaryOperator.add,
      BinaryOp(
          const Variable('y'), BinaryOperator.power, const NumberLiteral(2)),
    ),
    BinaryOperator.add,
    const NumberLiteral(1),
  );

  const knownVars = {'x', 'y'};

  const warmupIterations = 20000;
  const benchmarkIterations = 400000;

  for (var i = 0; i < warmupIterations; i++) {
    parsedAnnotated.getEvaluability(knownVars);
    manualUnannotated.getEvaluability(knownVars);
  }

  final annotatedMicros = _timeMicros(benchmarkIterations, () {
    parsedAnnotated.getEvaluability(knownVars);
  });

  final visitorMicros = _timeMicros(benchmarkIterations, () {
    manualUnannotated.getEvaluability(knownVars);
  });

  final speedup = visitorMicros / annotatedMicros;

  final result = {
    'benchmark': 'evaluability_fast_path',
    'iterations': benchmarkIterations,
    'annotated_total_us': annotatedMicros,
    'visitor_total_us': visitorMicros,
    'annotated_avg_us': annotatedMicros / benchmarkIterations,
    'visitor_avg_us': visitorMicros / benchmarkIterations,
    'speedup': speedup,
    'enforced': enforce,
    'min_speedup': minSpeedup,
    'passed': !enforce || speedup >= minSpeedup,
    'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
  };

  print('Evaluability Fast-Path Benchmark');
  print('  iterations: $benchmarkIterations');
  print(
      '  annotated avg: ${(annotatedMicros / benchmarkIterations).toStringAsFixed(6)} µs');
  print(
      '  visitor avg:   ${(visitorMicros / benchmarkIterations).toStringAsFixed(6)} µs');
  print(
      '  speedup:       ${speedup.toStringAsFixed(3)}x (visitor / annotated)');

  if (jsonOut != null && jsonOut.isNotEmpty) {
    final outputFile = File(jsonOut);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(result),
    );
    print('  wrote:         ${outputFile.path}');
  }

  if (enforce && speedup < minSpeedup) {
    stderr.writeln(
      'Guardrail failed: speedup ${speedup.toStringAsFixed(3)}x < required ${minSpeedup.toStringAsFixed(3)}x',
    );
    exitCode = 1;
  }
}

int _timeMicros(int iterations, void Function() fn) {
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    fn();
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}

double _readDoubleArg(List<String> args, String key, double fallback) {
  final prefix = '$key=';
  for (final arg in args) {
    if (arg.startsWith(prefix)) {
      return double.tryParse(arg.substring(prefix.length)) ?? fallback;
    }
  }
  return fallback;
}

String? _readStringArg(List<String> args, String key) {
  final prefix = '$key=';
  for (final arg in args) {
    if (arg.startsWith(prefix)) {
      return arg.substring(prefix.length);
    }
  }
  return null;
}
