# WASM Compilation

Compile the `texpr` library to WebAssembly for running in web browsers.

## Quick Start

```bash
# Compile to WASM
dart compile wasm wasm/main.dart -o wasm/build/main.wasm

# Serve (WASM requires HTTP server, file:// won't work)
cd wasm/build && python3 -m http.server 8080

# Open http://localhost:8080/index.html in Chrome/Firefox
```

## Requirements

- Dart SDK 3.10+ (stable)
- WasmGC-compatible browser (Chrome 119+, Firefox 120+)

## Files

| File                      | Description                       |
| ------------------------- | --------------------------------- |
| `wasm/main.dart`          | Entry point with demo expressions |
| `wasm/build/index.html`   | HTML page to load WASM module     |
| `wasm/build/main.dart.js` | JS bootstrap (loads .wasm + .mjs) |

## Build Output

Compilation generates:
- `main.wasm` - Optimized WASM module (~140KB)
- `main.mjs` - Dart runtime for WASM
- `main.unopt.wasm` - Unoptimized version with source maps

## Integration

Use the JS bootstrap pattern in your own project:

```javascript
(async function () {
    const dartModulePromise = WebAssembly.compileStreaming(fetch('main.wasm'));
    const dart2wasm_runtime = await import('./main.mjs');
    const moduleInstance = await dart2wasm_runtime.instantiate(dartModulePromise, {});
    await dart2wasm_runtime.invoke(moduleInstance);
})();
```

## Resources

- [Dart WASM Documentation](https://dart.dev/web/wasm)
- [WasmGC Browser Support](https://webassembly.org/features/)
