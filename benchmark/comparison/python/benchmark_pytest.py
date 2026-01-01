"""
Cross-language benchmark for texpr comparison.
Uses pytest-benchmark for proper statistical benchmarking.

Note: Uses SymPy native syntax, not LaTeX parsing, since SymPy's LaTeX parser
has limited support compared to the actual mathematical capabilities.

Usage:
    pip install pytest pytest-benchmark sympy
    pytest benchmark_pytest.py --benchmark-only -v
"""

import pytest
from sympy import symbols, sqrt, sin, cos, tan, exp, pi, Matrix, Integral, Rational
from sympy import oo  # infinity

# Define symbols
x, y, z = symbols('x y z')
v, c = symbols('v c')
sigma, mu = symbols('sigma mu')
V, E, F = symbols('V E F')
P, L, E_, I_ = symbols('P L E_ I_')


# =============================================================================
# Category 1: Basic Algebra
# =============================================================================

class TestBasicAlgebra:
    """Basic algebra benchmarks (baseline)."""

    def test_simple_arithmetic(self, benchmark):
        """Simple addition: 1 + 2 + 3 + 4 + 5"""
        def run():
            expr = 1 + 2 + 3 + 4 + 5
            return expr
        benchmark(run)

    def test_multiplication(self, benchmark):
        """Multiplication with variables: x * y * z"""
        def run():
            expr = x * y * z
            return expr.evalf(subs={x: 2, y: 3, z: 4})
        benchmark(run)

    def test_trigonometry(self, benchmark):
        """Trigonometric functions: sin(x) + cos(x)"""
        def run():
            expr = sin(x) + cos(x)
            return expr.evalf(subs={x: 0.5})
        benchmark(run)

    def test_power_and_sqrt(self, benchmark):
        """Power and square root: sqrt(x^2 + y^2)"""
        def run():
            expr = sqrt(x**2 + y**2)
            return expr.evalf(subs={x: 3, y: 4})
        benchmark(run)


# =============================================================================
# Category 2: Calculus
# =============================================================================

class TestCalculus:
    """Calculus benchmarks (integrals, derivatives)."""

    def test_definite_integral(self, benchmark):
        """Definite integral: integral of x^2 from 0 to 1"""
        def run():
            expr = Integral(x**2, (x, 0, 1))
            return expr.doit()
        benchmark(run)


# =============================================================================
# Category 3: Matrix Operations
# =============================================================================

class TestMatrix:
    """Matrix operation benchmarks."""

    def test_matrix_2x2(self, benchmark):
        """2x2 matrix creation."""
        def run():
            m = Matrix([[1, 2], [3, 4]])
            return m
        benchmark(run)

    def test_matrix_3x3_power(self, benchmark):
        """3x3 matrix power operation."""
        def run():
            m = Matrix([
                [Rational(8, 10), Rational(1, 10), Rational(1, 10)],
                [Rational(2, 10), Rational(7, 10), Rational(1, 10)],
                [Rational(3, 10), Rational(3, 10), Rational(4, 10)]
            ])
            return m ** 2
        benchmark(run)


# =============================================================================
# Category 4: Academic/Scientific
# =============================================================================

class TestAcademic:
    """Academic and scientific expression benchmarks."""

    def test_normal_distribution_pdf(self, benchmark):
        """Normal distribution PDF."""
        def run():
            expr = (1 / (sigma * sqrt(2 * pi))) * exp(-Rational(1, 2) * ((x - mu) / sigma)**2)
            return expr.evalf(subs={x: 0.0, mu: 0.0, sigma: 1.0})
        benchmark(run)

    def test_lorentz_factor(self, benchmark):
        """Lorentz factor from special relativity."""
        def run():
            expr = 1 / sqrt(1 - v**2 / c**2)
            return expr.evalf(subs={v: 0.6, c: 1.0})
        benchmark(run)

    def test_euler_polyhedra(self, benchmark):
        """Euler's polyhedra formula: V - E + F."""
        def run():
            expr = V - E + F
            return expr.evalf(subs={V: 8, E: 12, F: 6})
        benchmark(run)


# =============================================================================
# Category 5: Complex Expressions
# =============================================================================

class TestComplex:
    """Complex expression stress tests."""

    def test_nested_functions(self, benchmark):
        """Nested trigonometric functions: sin(cos(tan(x)))"""
        def run():
            expr = sin(cos(tan(x)))
            return expr.evalf(subs={x: 0.5})
        benchmark(run)

    def test_polynomial(self, benchmark):
        """5th degree polynomial."""
        def run():
            expr = x**5 + 2*x**4 - 3*x**3 + 4*x**2 - 5*x + 6
            return expr.evalf(subs={x: 2.0})
        benchmark(run)


if __name__ == '__main__':
    pytest.main([__file__, '--benchmark-only', '-v'])
