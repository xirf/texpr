import 'dart:math' as math;

/// Represents a closed interval [lower, upper] for interval arithmetic.
///
/// Interval arithmetic propagates uncertainty through calculations,
/// providing guaranteed bounds on results.
///
/// Example:
/// ```dart
/// final a = Interval(1.0, 2.0);
/// final b = Interval(3.0, 4.0);
/// final sum = a + b;  // Interval(4.0, 6.0)
/// ```
class Interval {
  /// The lower bound of the interval.
  final double lower;

  /// The upper bound of the interval.
  final double upper;

  /// Creates an interval with the given bounds.
  ///
  /// Throws [ArgumentError] if [lower] > [upper].
  const Interval(this.lower, this.upper);

  /// Creates a point interval [value, value].
  const Interval.point(double value)
      : lower = value,
        upper = value;

  /// Creates an interval from a value with symmetric uncertainty.
  ///
  /// Example: `Interval.withUncertainty(10, 0.5)` creates [9.5, 10.5]
  factory Interval.withUncertainty(double value, double uncertainty) {
    return Interval(value - uncertainty.abs(), value + uncertainty.abs());
  }

  /// Creates the entire real line interval [-∞, +∞].
  static const Interval entire =
      Interval(double.negativeInfinity, double.infinity);

  /// Creates an empty interval (lower > upper by convention).
  static const Interval empty = Interval(1.0, 0.0);

  // ============================================================
  // Properties
  // ============================================================

  /// The width of the interval (upper - lower).
  double get width => upper - lower;

  /// The midpoint of the interval.
  double get midpoint => (lower + upper) / 2;

  /// The radius of the interval (half the width).
  double get radius => (upper - lower) / 2;

  /// Returns true if the interval is empty (lower > upper).
  bool get isEmpty => lower > upper;

  /// Returns true if the interval is a single point (lower == upper).
  bool get isPoint => lower == upper;

  /// Returns true if the interval contains zero.
  bool get containsZero => lower <= 0 && upper >= 0;

  /// Returns true if the interval contains a specific value.
  bool contains(double value) => lower <= value && value <= upper;

  /// Returns true if this interval overlaps with [other].
  bool overlaps(Interval other) =>
      !isEmpty &&
      !other.isEmpty &&
      lower <= other.upper &&
      other.lower <= upper;

  /// Returns the intersection of two intervals.
  ///
  /// Returns [empty] if the intervals don't overlap.
  Interval intersection(Interval other) {
    final lo = math.max(lower, other.lower);
    final hi = math.min(upper, other.upper);
    return lo <= hi ? Interval(lo, hi) : empty;
  }

  /// Returns the hull (smallest interval containing both).
  Interval hull(Interval other) {
    if (isEmpty) return other;
    if (other.isEmpty) return this;
    return Interval(
      math.min(lower, other.lower),
      math.max(upper, other.upper),
    );
  }

  // ============================================================
  // Arithmetic Operations
  // ============================================================

  /// Adds two intervals: [a,b] + [c,d] = [a+c, b+d]
  Interval operator +(Object other) {
    if (other is Interval) {
      return Interval(lower + other.lower, upper + other.upper);
    } else if (other is num) {
      return Interval(lower + other, upper + other);
    }
    throw ArgumentError('Cannot add ${other.runtimeType} to Interval');
  }

  /// Subtracts intervals: [a,b] - [c,d] = [a-d, b-c]
  Interval operator -(Object other) {
    if (other is Interval) {
      return Interval(lower - other.upper, upper - other.lower);
    } else if (other is num) {
      return Interval(lower - other, upper - other);
    }
    throw ArgumentError('Cannot subtract ${other.runtimeType} from Interval');
  }

  /// Multiplies intervals by considering all combinations.
  ///
  /// [a,b] * [c,d] = [min(ac,ad,bc,bd), max(ac,ad,bc,bd)]
  Interval operator *(Object other) {
    if (other is Interval) {
      final products = [
        lower * other.lower,
        lower * other.upper,
        upper * other.lower,
        upper * other.upper,
      ];
      return Interval(
        products.reduce(math.min),
        products.reduce(math.max),
      );
    } else if (other is num) {
      final a = lower * other;
      final b = upper * other;
      return other >= 0 ? Interval(a, b) : Interval(b, a);
    }
    throw ArgumentError('Cannot multiply Interval by ${other.runtimeType}');
  }

  /// Divides intervals.
  ///
  /// Throws [ArgumentError] if the divisor contains zero.
  Interval operator /(Object other) {
    if (other is Interval) {
      if (other.containsZero) {
        throw ArgumentError(
            'Cannot divide by interval containing zero: $other');
      }
      return this * other.reciprocal;
    } else if (other is num) {
      if (other == 0) {
        throw ArgumentError('Cannot divide interval by zero');
      }
      final a = lower / other;
      final b = upper / other;
      return other > 0 ? Interval(a, b) : Interval(b, a);
    }
    throw ArgumentError('Cannot divide Interval by ${other.runtimeType}');
  }

  /// Negates the interval: -[a,b] = [-b, -a]
  Interval operator -() => Interval(-upper, -lower);

  /// Returns the reciprocal interval: 1/[a,b] = [1/b, 1/a]
  ///
  /// Throws [ArgumentError] if the interval contains zero.
  Interval get reciprocal {
    if (containsZero) {
      throw ArgumentError(
          'Cannot compute reciprocal of interval containing zero: $this');
    }
    return Interval(1.0 / upper, 1.0 / lower);
  }

  /// Returns the absolute value interval.
  ///
  /// Handles the case where the interval spans zero.
  Interval abs() {
    if (lower >= 0) {
      return this;
    } else if (upper <= 0) {
      return -this;
    } else {
      // Interval spans zero
      return Interval(0, math.max(-lower, upper));
    }
  }

  /// Returns the square of the interval.
  ///
  /// Handles sign changes correctly.
  Interval square() {
    if (lower >= 0) {
      return Interval(lower * lower, upper * upper);
    } else if (upper <= 0) {
      return Interval(upper * upper, lower * lower);
    } else {
      // Spans zero: minimum is 0
      final maxAbs = math.max(-lower, upper);
      return Interval(0, maxAbs * maxAbs);
    }
  }

  /// Returns the square root interval.
  ///
  /// Throws [ArgumentError] if the interval contains negative values.
  Interval sqrt() {
    if (lower < 0) {
      throw ArgumentError(
          'Cannot compute sqrt of interval with negative values: $this');
    }
    return Interval(math.sqrt(lower), math.sqrt(upper));
  }

  /// Raises the interval to an integer power.
  Interval pow(int n) {
    if (n == 0) return const Interval.point(1.0);
    if (n == 1) return this;
    if (n == 2) return square();

    if (n < 0) {
      return reciprocal.pow(-n);
    }

    // For odd powers, monotonicity is preserved
    if (n.isOdd) {
      return Interval(
          math.pow(lower, n).toDouble(), math.pow(upper, n).toDouble());
    }

    // For even powers, need to handle sign changes
    if (lower >= 0) {
      return Interval(
          math.pow(lower, n).toDouble(), math.pow(upper, n).toDouble());
    } else if (upper <= 0) {
      return Interval(
          math.pow(upper, n).toDouble(), math.pow(lower, n).toDouble());
    } else {
      // Spans zero for even power
      final maxAbs = math.max(-lower, upper);
      return Interval(0, math.pow(maxAbs, n).toDouble());
    }
  }

  // ============================================================
  // Transcendental Functions
  // ============================================================

  /// Returns the exponential of the interval.
  ///
  /// exp is monotonically increasing, so exp([a,b]) = [exp(a), exp(b)]
  Interval exp() => Interval(math.exp(lower), math.exp(upper));

  /// Returns the natural logarithm of the interval.
  ///
  /// Throws [ArgumentError] if the interval contains non-positive values.
  Interval log() {
    if (lower <= 0) {
      throw ArgumentError(
          'Cannot compute log of interval with non-positive values: $this');
    }
    return Interval(math.log(lower), math.log(upper));
  }

  /// Returns the sine of the interval.
  Interval sin() {
    if (isEmpty) return Interval.empty;
    if (width >= 2 * math.pi) return const Interval(-1.0, 1.0);

    final lo = math.sin(lower);
    final hi = math.sin(upper);
    var min = math.min(lo, hi);
    var max = math.max(lo, hi);

    // Check for peaks (π/2 + 2kπ)
    // We want integer k such that lower <= π/2 + 2kπ <= upper
    // (lower - π/2) / 2π <= k <= (upper - π/2) / 2π
    final k1 = ((lower - math.pi / 2) / (2 * math.pi)).ceil();
    final peak = math.pi / 2 + 2 * math.pi * k1;
    if (peak <= upper) max = 1.0;

    // Check for valleys (3π/2 + 2kπ) -> same as -π/2 + 2kπ
    // (lower + π/2) / 2π <= k <= (upper + π/2) / 2π
    final k2 = ((lower + math.pi / 2) / (2 * math.pi)).ceil();
    final valley = -math.pi / 2 + 2 * math.pi * k2;
    if (valley <= upper) min = -1.0;

    return Interval(min, max);
  }

  /// Returns the cosine of the interval.
  Interval cos() {
    if (isEmpty) return Interval.empty;
    if (width >= 2 * math.pi) return const Interval(-1.0, 1.0);

    final lo = math.cos(lower);
    final hi = math.cos(upper);
    var min = math.min(lo, hi);
    var max = math.max(lo, hi);

    // Check for peaks (2kπ)
    final k1 = (lower / (2 * math.pi)).ceil();
    final peak = 2 * math.pi * k1;
    if (peak <= upper) max = 1.0;

    // Check for valleys (π + 2kπ)
    final k2 = ((lower - math.pi) / (2 * math.pi)).ceil();
    final valley = math.pi + 2 * math.pi * k2;
    if (valley <= upper) min = -1.0;

    return Interval(min, max);
  }

  /// Returns the tangent of the interval.
  ///
  /// If the interval contains a singularity (odd multiples of π/2),
  /// returns [Interval.entire].
  Interval tan() {
    if (isEmpty) return Interval.empty;

    // Check for singularities: kπ + π/2
    // k = floor(lower / π - 0.5)
    // singularity = (k + 1) * π + π/2? No.
    // simpler: check if floor((lower - pi/2)/pi) != floor((upper - pi/2)/pi)

    final k1 = ((lower - math.pi / 2) / math.pi).floor();
    final k2 = ((upper - math.pi / 2) / math.pi).floor();

    if (k1 != k2) {
      return Interval.entire;
    }

    return Interval(math.tan(lower), math.tan(upper));
  }

  /// Returns the arcsine of the interval.
  ///
  /// Throws [ArgumentError] if the interval is not within [-1, 1].
  Interval asin() {
    if (lower < -1.0 || upper > 1.0) {
      throw ArgumentError('Domain of asin is [-1, 1], got $this');
    }
    // asin is monotonic increasing
    return Interval(math.asin(lower), math.asin(upper));
  }

  /// Returns the arccosine of the interval.
  ///
  /// Throws [ArgumentError] if the interval is not within [-1, 1].
  Interval acos() {
    if (lower < -1.0 || upper > 1.0) {
      throw ArgumentError('Domain of acos is [-1, 1], got $this');
    }
    // acos is monotonic decreasing
    return Interval(math.acos(upper), math.acos(lower));
  }

  /// Returns the arctangent of the interval.
  Interval atan() {
    // atan is monotonic increasing
    return Interval(math.atan(lower), math.atan(upper));
  }

  /// Returns the hyperbolic sine of the interval.
  Interval sinh() {
    // sinh is monotonic increasing
    return Interval(_sinh(lower), _sinh(upper));
  }

  /// Returns the hyperbolic cosine of the interval.
  Interval cosh() {
    if (containsZero) {
      return Interval(1.0, math.max(_cosh(lower), _cosh(upper)));
    }
    if (upper < 0) {
      // Decreasing on negative domain
      return Interval(_cosh(upper), _cosh(lower));
    }
    // Increasing on positive domain
    return Interval(_cosh(lower), _cosh(upper));
  }

  /// Returns the hyperbolic tangent of the interval.
  Interval tanh() {
    // tanh is monotonic increasing
    return Interval(_tanh(lower), _tanh(upper));
  }

  // Helper functions
  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  static double _tanh(double x) {
    if (x > 20) return 1.0;
    if (x < -20) return -1.0;
    final e2x = math.exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }

  static double _asinh(double x) => math.log(x + math.sqrt(x * x + 1));

  static double _acosh(double x) => math.log(x + math.sqrt(x * x - 1));

  static double _atanh(double x) => 0.5 * math.log((1 + x) / (1 - x));

  /// Returns the inverse hyperbolic sine of the interval.
  Interval asinh() {
    return Interval(_asinh(lower), _asinh(upper));
  }

  /// Returns the inverse hyperbolic cosine of the interval.
  Interval acosh() {
    if (lower < 1.0) {
      throw ArgumentError(
          'Cannot compute acosh of interval with values < 1: $this');
    }
    return Interval(_acosh(lower), _acosh(upper));
  }

  /// Returns the inverse hyperbolic tangent of the interval.
  Interval atanh() {
    if (lower <= -1.0 || upper >= 1.0) {
      throw ArgumentError(
          'Cannot compute atanh of interval with values outside (-1, 1): $this');
    }
    return Interval(_atanh(lower), _atanh(upper));
  }

  // ============================================================
  // String and Equality
  // ============================================================

  @override
  String toString() {
    if (isEmpty) return 'Interval.empty';
    if (isPoint) return 'Interval.point($lower)';
    return '[$lower, $upper]';
  }

  /// Returns a string with fixed precision.
  String toStringAsFixed(int fractionDigits) {
    if (isEmpty) return 'Interval.empty';
    if (isPoint) {
      return 'Interval.point(${lower.toStringAsFixed(fractionDigits)})';
    }
    return '[${lower.toStringAsFixed(fractionDigits)}, ${upper.toStringAsFixed(fractionDigits)}]';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is num) return isPoint && lower == other;
    return other is Interval && lower == other.lower && upper == other.upper;
  }

  @override
  int get hashCode => Object.hash(lower, upper);
}
