# Interactive Playground

Try out TeXpr directly in your browser! This playground uses the WebAssembly (WASM) build of the library.

<Playground />

## How it works
The Dart code is compiled to WebAssembly using `dart compile wasm`. The browser loads the `.wasm` module and executes it roughly at native speed.

> [!NOTE]
> This playground relies on `dart:js_interop` to communicate between JavaScript and the underlying Dart/WASM module.
