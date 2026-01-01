const math = require("mathjs");
const expressions = [
    {desc: "Simple Arithmetic", expr: "1 + 2 + 3 + 4 + 5", vars: {}},
    {desc: "Multiplication", expr: "x * y * z", vars: {"x":2.0,"y":3.0,"z":4.0}},
    {desc: "Trigonometry", expr: "sin(x) + cos(x)", vars: {"x":0.5}},
    {desc: "Power & Sqrt", expr: "sqrt(x^2 + y^2)", vars: {"x":3.0,"y":4.0}},
    {desc: "Matrix", expr: "[[1, 2], [3, 4]]", vars: {}},
];
const iterations = 1000;
expressions.forEach(item => {
    try { math.evaluate(item.expr, item.vars); } catch(e){}
});
expressions.forEach(item => {
    const start = process.hrtime.bigint();
    for(let i=0; i<iterations; i++) {
        math.evaluate(item.expr, item.vars);
    }
    const end = process.hrtime.bigint();
    const avgUs = Number(end - start) / iterations / 1000.0;
    console.log(`  - ${item.desc}: ${avgUs.toFixed(2)} µs/op`);
});
