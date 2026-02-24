import '../ast.dart';

/// A cache key that combines an expression with its variable bindings.
///
/// Two key strategies are available:
/// - **Identity-based** (recommended): Uses object identity for fast lookups.
///   Cache hits occur when the same Map instance is reused.
/// - **Structural** (deprecated): Uses value equality via sorted hashing.
///   More expensive but matches semantically equal Maps.
class EvaluationCacheKey {
  final int _hash;
  final int _exprIdentity;
  final int _varsIdentity;
  final bool _isIdentityBased;
  final List<_NormalizedVariableEntry>? _structuralEntries;

  /// Creates an identity-based cache key.
  ///
  /// This is the recommended constructor for performance-critical code.
  /// Cache hits occur only when the exact same [expr] and [vars] instances
  /// are reused. This aligns with reactive patterns where the same Map
  /// flows through hot loops.
  ///
  /// Cost: Two `identityHashCode` calls, zero allocation, zero traversal.
  EvaluationCacheKey.identity(Expression expr, Map<String, double> vars)
      : _exprIdentity = identityHashCode(expr),
        _varsIdentity = identityHashCode(vars),
        _hash = identityHashCode(expr) ^ identityHashCode(vars),
        _isIdentityBased = true,
        _structuralEntries = null;

  /// Creates a structural cache key using value equality.
  ///
  /// This constructor sorts variable entries to create a stable hash,
  /// allowing cache hits for semantically equal Maps (same key-value pairs).
  ///
  /// **Deprecated**: This incurs allocation and O(n log n) sorting overhead
  /// on every cache lookup. For simple expressions, this overhead exceeds
  /// the evaluation cost. Use [EvaluationCacheKey.identity] instead.
  @Deprecated('Use EvaluationCacheKey.identity for performance. '
      'Structural equality will be removed in 0.3.0')
  EvaluationCacheKey(Expression expression, Map<String, double> variables)
      : _exprIdentity = expression.hashCode,
        _varsIdentity = 0, // Not used for structural comparison
        _structuralEntries = _normalizedEntries(variables),
        _hash = _computeStructuralHash(expression, _normalizedEntries(variables)),
        _isIdentityBased = false;

  static List<_NormalizedVariableEntry> _normalizedEntries(
      Map<String, double> variables) {
    final entries = variables.entries
        .map((entry) =>
            _NormalizedVariableEntry(entry.key, _normalizeDouble(entry.value)))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return List<_NormalizedVariableEntry>.unmodifiable(entries);
  }

  static int _computeStructuralHash(
      Expression expression, List<_NormalizedVariableEntry> entries) {
    // Create a stable hash from expression and sorted normalized entries.
    var hash = expression.hashCode;
    for (final entry in entries) {
      hash = Object.hash(hash, entry.key, _normalizedDoubleHash(entry.value));
    }
    return hash;
  }

  static double _normalizeDouble(double value) {
    if (value.isNaN) {
      return double.nan;
    }
    // Canonicalize signed zero to avoid -0.0/+0.0 cache key divergence.
    if (value == 0.0) {
      return 0.0;
    }
    return value;
  }

  static int _normalizedDoubleHash(double value) {
    if (value.isNaN) {
      return 0x7ff80000;
    }
    if (value == 0.0) {
      return 0;
    }
    return value.hashCode;
  }

  static bool _normalizedDoubleEquals(double left, double right) {
    if (left.isNaN && right.isNaN) {
      return true;
    }
    if (left == 0.0 && right == 0.0) {
      return true;
    }
    return left == right;
  }

  @override
  int get hashCode => _hash;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EvaluationCacheKey) return false;
    if (_hash != other._hash) return false;

    if (_isIdentityBased && other._isIdentityBased) {
      // Fast path: identity comparison
      return _exprIdentity == other._exprIdentity &&
          _varsIdentity == other._varsIdentity;
    }

    if (_isIdentityBased != other._isIdentityBased) {
      return false;
    }

    final leftEntries = _structuralEntries;
    final rightEntries = other._structuralEntries;
    if (leftEntries == null || rightEntries == null) {
      return false;
    }

    if (_exprIdentity != other._exprIdentity ||
        leftEntries.length != rightEntries.length) {
      return false;
    }

    for (var index = 0; index < leftEntries.length; index++) {
      final left = leftEntries[index];
      final right = rightEntries[index];
      if (left.key != right.key ||
          !_normalizedDoubleEquals(left.value, right.value)) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() =>
      'EvaluationCacheKey(hash: $_hash, identity: $_isIdentityBased)';
}

class _NormalizedVariableEntry {
  final String key;
  final double value;

  const _NormalizedVariableEntry(this.key, this.value);
}

/// A cache key for differentiation results.
///
/// Combines expression, variable, and order to uniquely identify a derivative.
class DifferentiationCacheKey {
  final Expression expression;
  final String variable;
  final int order;
  final int _hashCodeCache;

  DifferentiationCacheKey(this.expression, this.variable, this.order)
      : _hashCodeCache = Object.hash(expression.hashCode, variable, order);

  @override
  int get hashCode => _hashCodeCache;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DifferentiationCacheKey) return false;
    return _hashCodeCache == other._hashCodeCache &&
        order == other.order &&
        variable == other.variable &&
        (identical(expression, other.expression) ||
            expression.hashCode == other.expression.hashCode);
  }

  @override
  String toString() =>
      'DifferentiationCacheKey(d^$order/d$variable, expr: $expression)';
}
