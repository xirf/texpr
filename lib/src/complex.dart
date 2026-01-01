import 'dart:math' as math;

/// Represents a complex number with real and imaginary parts.
class Complex {
  /// The real part of the complex number.
  final double real;

  /// The imaginary part of the complex number.
  final double imaginary;

  /// Creates a complex number.
  const Complex(this.real, [this.imaginary = 0]);

  /// Creates a complex number from a numeric value (real only).
  factory Complex.fromNum(num value) => Complex(value.toDouble());

  /// Returns true if the imaginary part is zero (effectively a real number).
  bool get isReal => imaginary == 0;

  /// Returns true if the real part is zero (purely imaginary).
  bool get isImaginary => real == 0 && imaginary != 0;

  /// Returns true if the real part is zero and imaginary is non-zero.
  /// Alias for [isImaginary].
  bool get isPureImaginary => isImaginary;

  /// Returns true if both real and imaginary parts are zero.
  bool get isZero => real == 0 && imaginary == 0;

  /// Returns the modulus (magnitude) of the complex number.
  double get abs => math.sqrt(real * real + imaginary * imaginary);

  /// Returns the argument (phase) of the complex number.
  double get arg => math.atan2(imaginary, real);

  /// Returns the conjugate of the complex number.
  Complex get conjugate => Complex(real, -imaginary);

  /// Returns the reciprocal (multiplicative inverse) of this complex number.
  /// Returns 1/z = conjugate(z) / |z|^2
  Complex get reciprocal {
    final denom = real * real + imaginary * imaginary;
    return Complex(real / denom, -imaginary / denom);
  }

  /// Adds this complex number to [other].
  Complex operator +(Object other) {
    if (other is Complex) {
      return Complex(real + other.real, imaginary + other.imaginary);
    } else if (other is num) {
      return Complex(real + other, imaginary);
    }
    throw ArgumentError('Cannot add ${other.runtimeType} to Complex');
  }

  /// Subtracts [other] from this complex number.
  Complex operator -(Object other) {
    if (other is Complex) {
      return Complex(real - other.real, imaginary - other.imaginary);
    } else if (other is num) {
      return Complex(real - other, imaginary);
    }
    throw ArgumentError('Cannot subtract ${other.runtimeType} from Complex');
  }

  /// Multiplies this complex number by [other].
  Complex operator *(Object other) {
    if (other is Complex) {
      return Complex(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );
    } else if (other is num) {
      return Complex(real * other, imaginary * other);
    }
    throw ArgumentError('Cannot multiply Complex by ${other.runtimeType}');
  }

  /// Divides this complex number by [other].
  Complex operator /(Object other) {
    if (other is Complex) {
      final denom = other.real * other.real + other.imaginary * other.imaginary;
      return Complex(
        (real * other.real + imaginary * other.imaginary) / denom,
        (imaginary * other.real - real * other.imaginary) / denom,
      );
    } else if (other is num) {
      return Complex(real / other, imaginary / other);
    }
    throw ArgumentError('Cannot divide Complex by ${other.runtimeType}');
  }

  /// Negates this complex number.
  Complex operator -() => Complex(-real, -imaginary);

  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    final sign = imaginary < 0 ? '-' : '+';
    return '$real $sign ${imaginary.abs()}i';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is num) return real == other && imaginary == 0;
    return other is Complex &&
        real == other.real &&
        imaginary == other.imaginary;
  }

  @override
  int get hashCode => Object.hash(real, imaginary);

  // ============================================================
  // Complex Mathematical Operations
  // ============================================================

  /// Creates a complex number from polar coordinates.
  ///
  /// [r] is the modulus (distance from origin).
  /// [theta] is the argument (angle in radians).
  factory Complex.fromPolar(double r, double theta) =>
      Complex(r * math.cos(theta), r * math.sin(theta));

  /// Returns the complex exponential e^z.
  ///
  /// e^(a+bi) = e^a * (cos(b) + i*sin(b))
  Complex exp() {
    final expReal = math.exp(real);
    return Complex(
        expReal * math.cos(imaginary), expReal * math.sin(imaginary));
  }

  /// Returns the principal value of the natural logarithm ln(z).
  ///
  /// ln(z) = ln|z| + i*arg(z)
  Complex log() {
    return Complex(math.log(abs), arg);
  }

  /// Returns z raised to the power [exponent].
  ///
  /// z^w = exp(w * ln(z))
  Complex pow(Object exponent) {
    if (exponent is num) {
      // Optimization for real exponents
      if (real == 0 && imaginary == 0) {
        return exponent == 0 ? Complex(1.0) : Complex(0.0);
      }
      final r = math.pow(abs, exponent.toDouble());
      final theta = arg * exponent.toDouble();
      return Complex(r * math.cos(theta), r * math.sin(theta));
    } else if (exponent is Complex) {
      if (real == 0 && imaginary == 0) {
        return exponent.real == 0 && exponent.imaginary == 0
            ? Complex(1.0)
            : Complex(0.0);
      }
      // z^w = exp(w * ln(z))
      return (exponent * log()).exp();
    }
    throw ArgumentError(
        'Cannot raise Complex to power of ${exponent.runtimeType}');
  }

  /// Returns the principal square root of this complex number.
  Complex sqrt() => pow(0.5);

  /// Returns the complex sine of this number.
  ///
  /// sin(a+bi) = sin(a)cosh(b) + i*cos(a)sinh(b)
  Complex sin() {
    return Complex(
      math.sin(real) * _cosh(imaginary),
      math.cos(real) * _sinh(imaginary),
    );
  }

  /// Returns the complex cosine of this number.
  ///
  /// cos(a+bi) = cos(a)cosh(b) - i*sin(a)sinh(b)
  Complex cos() {
    return Complex(
      math.cos(real) * _cosh(imaginary),
      -math.sin(real) * _sinh(imaginary),
    );
  }

  /// Returns the complex tangent of this number.
  ///
  /// tan(z) = sin(z) / cos(z)
  Complex tan() => sin() / cos();

  /// Returns the complex hyperbolic sine.
  ///
  /// sinh(z) = (e^z - e^(-z)) / 2
  Complex sinh() {
    return Complex(
      _sinh(real) * math.cos(imaginary),
      _cosh(real) * math.sin(imaginary),
    );
  }

  /// Returns the complex hyperbolic cosine.
  ///
  /// cosh(z) = (e^z + e^(-z)) / 2
  Complex cosh() {
    return Complex(
      _cosh(real) * math.cos(imaginary),
      _sinh(real) * math.sin(imaginary),
    );
  }

  /// Returns the complex hyperbolic tangent.
  ///
  /// tanh(z) = sinh(z) / cosh(z)
  Complex tanh() => sinh() / cosh();

  /// Returns polar form string representation: r∠θ
  String toPolar() {
    return '${abs.toStringAsFixed(4)}∠${arg.toStringAsFixed(4)}';
  }

  // Helper functions for hyperbolic operations
  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
}
