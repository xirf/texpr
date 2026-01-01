import time, json, gc
from sympy import Symbol, symbols
from sympy.parsing.latex import parse_latex
expressions = [
    ("Simple Arithmetic", "1 + 2 + 3 + 4 + 5", {}),
    ("Multiplication", "x * y * z", {"x":2.0,"y":3.0,"z":4.0}),
    ("Trigonometry", "\\sin(x) + \\cos(x)", {"x":0.5}),
    ("Power & Sqrt", "\\sqrt{x^2 + y^2}", {"x":3.0,"y":4.0}),
    ("Definite Integral", "\\int_{0}^{1} x^2 dx", {}),
]
iterations = 50
x, y, z = symbols("x y z")
for _, l, _ in expressions:
    try: parse_latex(l)
    except: pass
for desc, latex, vars in expressions:
    gc.collect(); gc.disable()
    start = time.perf_counter_ns()
    for _ in range(iterations):
        expr = parse_latex(latex)
        if vars: expr.evalf(subs=vars)
        else: expr.evalf()
    end = time.perf_counter_ns()
    gc.enable()
    print(f"  - {desc}: {(end-start)/iterations/1000.0:.2f} µs/op")
