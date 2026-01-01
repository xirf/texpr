/**
 * Cross-language benchmark for texpr comparison.
 * 
 * Uses benchmark.js for proper statistical benchmarking.
 * 
 * Usage:
 *   npm install mathjs benchmark
 *   node benchmark_suite.js
 * 
 * Or with Bun:
 *   bun install mathjs benchmark
 *   bun run benchmark_suite.js
 */

const Benchmark = require('benchmark');
const math = require('mathjs');

const suite = new Benchmark.Suite();

// =============================================================================
// Category 1: Basic Algebra
// =============================================================================

suite
  .add('Basic: Simple Arithmetic', function() {
    math.evaluate('1 + 2 + 3 + 4 + 5');
  })
  .add('Basic: Multiplication', function() {
    math.evaluate('x * y * z', { x: 2, y: 3, z: 4 });
  })
  .add('Basic: Trigonometry', function() {
    math.evaluate('sin(x) + cos(x)', { x: 0.5 });
  })
  .add('Basic: Power & Sqrt', function() {
    math.evaluate('sqrt(x^2 + y^2)', { x: 3, y: 4 });
  })

// =============================================================================
// Category 2: Matrix Operations
// =============================================================================

  .add('Matrix: 2x2 Parse', function() {
    math.evaluate('[[1, 2], [3, 4]]');
  })
  .add('Matrix: 3x3 Power', function() {
    math.evaluate('[[0.8, 0.1, 0.1], [0.2, 0.7, 0.1], [0.3, 0.3, 0.4]] ^ 2');
  })

// =============================================================================
// Category 3: Academic/Scientific
// =============================================================================

  .add('Academic: Normal Distribution PDF', function() {
    math.evaluate(
      '(1 / (sigma * sqrt(2 * pi))) * exp(-0.5 * ((x - mu) / sigma)^2)',
      { x: 0.0, mu: 0.0, sigma: 1.0 }
    );
  })
  .add('Academic: Lorentz Factor', function() {
    math.evaluate('1 / sqrt(1 - (v^2 / c^2))', { v: 0.6, c: 1.0 });
  })
  .add('Academic: Euler Polyhedra', function() {
    math.evaluate('V - E + F', { V: 8, E: 12, F: 6 });
  })

// =============================================================================
// Category 4: Complex Expressions
// =============================================================================

  .add('Complex: Nested Functions', function() {
    math.evaluate('sin(cos(tan(x)))', { x: 0.5 });
  })
  .add('Complex: Polynomial', function() {
    math.evaluate('x^5 + 2*x^4 - 3*x^3 + 4*x^2 - 5*x + 6', { x: 2.0 });
  })

// =============================================================================
// Run the suite
// =============================================================================

  .on('cycle', function(event) {
    console.log(String(event.target));
  })
  .on('complete', function() {
    console.log('\n======================================================================');
    console.log('Benchmark complete!');
    console.log('======================================================================');
  })
  .run({ 'async': true });
