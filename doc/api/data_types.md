# Data Types

## Matrix

Represents a matrix of double values.

### Constructors

*   `Matrix(List<List<double>> data)`: Creates a matrix from 2D list. Rows must be equal length.

### Properties

*   `rows`: Number of rows.
*   `cols`: Number of columns.
*   `data`: Raw 2D list access.

### Methods

*   `determinant()`: Calculates determinant (must be square).
*   `inverse()`: Calculates inverse matrix (must be square and non-singular).
*   `transpose()`: Returns the transposed matrix.
*   `trace()`: Returns sum of diagonal elements (must be square).

### Operators

*   `+`, `-`: Matrix addition/subtraction.
*   `*`: Matrix multiplication (if operand is Matrix) or scalar multiplication (if operand is num).
*   `operator []`: Access a row by index.

---

## Vector

Represents a mathematical vector of double values.

### Constructors

*   `Vector(List<double> components)`: Creates a vector from values.
*   `Vector.fromXY(double x, double y)`: Creates a 2D vector.
*   `Vector.fromXYZ(double x, double y, double z)`: Creates a 3D vector.

### Properties

*   `dimension`: Number of components.
*   `magnitude`: Length of the vector (Euclidean norm).
*   `components`: Raw list access.

### Methods

*   `normalize()`: Returns a unit vector in same direction.
*   `dot(Vector other)`: Dot product.
*   `cross(Vector other)`: Cross product (defined for 3D vectors).

### Operators

*   `+`, `-`: Vector addition/subtraction.
*   `*`, `/`: Scalar multiplication/division.
*   `operator []`: Access component by index.
*   Unary `-`: Negates the vector.

---

## Complex

Represents a complex number with real and imaginary parts.

### Constructors

*   `Complex(double real, [double imaginary = 0])`: Regular constructor.
*   `Complex.fromNum(num value)`: Creates from real number.

### Properties

*   `real`: Real part.
*   `imaginary`: Imaginary part.
*   `abs`: Modulus/magnitude.
*   `arg`: Argument/phase angle.
*   `conjugate`: Complex conjugate.
*   `reciprocal`: Multiplicative inverse (1/z).
*   `isReal`: True if imaginary part is 0.
*   `isImaginary`: True if real part is 0 and imaginary is not.
*   `isZero`: True if both real and imaginary parts are 0.

### Methods

*   `exp()`: Complex exponential ($e^z$).
*   `log()`: Principal value of natural logarithm ($\ln(z)$).
*   `pow(Object exponent)`: Complex power ($z^w$).
*   `sqrt()`: Principal square root.
*   `sin()`, `cos()`, `tan()`: Trigonometric functions.
*   `sinh()`, `cosh()`, `tanh()`: Hyperbolic functions.
*   `toPolar()`: Returns string representation in polar form ($r\angle\theta$).

### Operators

*   `+`, `-`, `*`, `/`: Arithmetic with other `Complex` or `num`.
*   Unary `-`: Negation.
