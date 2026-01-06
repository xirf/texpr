<script setup>
import { ref, onMounted } from 'vue'

const input = ref('2 + 3 * 4')
const output = ref('')
const loading = ref(true)
const error = ref('')

let texprApi = null

onMounted(async () => {
  try {
    // Determine base URL (handle production/dev paths if needed)
    // For now assume /wasm/ is available at root or relative
    // VitePress treats public/ assets as root-relative
    const wasmUrl = '/wasm/main.wasm'
    const mjsUrl = '/wasm/main.mjs'

    // Vite workaround: fetch the .mjs file as text, create a Blob, and import it.
    // This avoids "file is in /public and ... should not be imported" errors.
    const mjsResponse = await fetch(mjsUrl)
    if (!mjsResponse.ok) throw new Error(`Failed to fetch runtime: ${mjsResponse.statusText}`)
    const mjsText = await mjsResponse.text()
    const mjsBlob = new Blob([mjsText], { type: 'text/javascript' })
    const mjsBlobUrl = URL.createObjectURL(mjsBlob)

    const dartModulePromise = WebAssembly.compileStreaming(fetch(wasmUrl))
    const dart2wasm_runtime = await import(/* @vite-ignore */ mjsBlobUrl)
    const moduleInstance = await dart2wasm_runtime.instantiate(dartModulePromise, {})
    await dart2wasm_runtime.invoke(moduleInstance)
    
    // Clean up
    URL.revokeObjectURL(mjsBlobUrl)

    // Wait for dart main to attach to window
    // It should happen synchronously after invoke, but let's be safe
    if (window.texpr) {
      texprApi = window.texpr
      loading.value = false
      evaluate()
    } else {
      error.value = 'Failed to initialize Texpr WASM: window.texpr not found'
      loading.value = false
    }
  } catch (e) {
    console.error(e)
    error.value = `Failed to load WASM: ${e.message}`
    loading.value = false
  }
})

function evaluate() {
  if (!texprApi) return
  try {
    const result = texprApi.evaluate(input.value)
    output.value = result
    error.value = ''
  } catch (e) {
    error.value = e.toString()
    output.value = ''
  }
}
</script>

<template>
  <div class="playground">
    <div v-if="loading" class="loading">Loading WASM engine...</div>
    <div v-else-if="error && !texprApi" class="error">
      {{ error }}
    </div>
    
    <div v-else class="interface">
      <div class="input-group">
        <label>Expression:</label>
        <div class="input-wrapper">
          <input 
            v-model="input" 
            @keyup.enter="evaluate"
            placeholder="Enter math expression (e.g. 2 + x)"
          />
          <button @click="evaluate">Evaluate</button>
        </div>
      </div>

      <div class="result-group">
        <label>Result:</label>
        <div class="result-box">
          <span v-if="output">{{ output }}</span>
          <span v-else-if="error" class="error-text">{{ error }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.playground {
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 1.5rem;
  margin: 1rem 0;
  background-color: var(--vp-c-bg-soft);
}

.loading {
  color: var(--vp-c-text-2);
  font-style: italic;
}

.error {
  color: var(--vp-c-danger-1);
}

.error-text {
  color: var(--vp-c-danger-1);
}

.input-group, .result-group {
  margin-bottom: 1rem;
}

.input-group label, .result-group label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-1);
}

.input-wrapper {
  display: flex;
  gap: 0.5rem;
}

input {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

button {
  padding: 0.5rem 1rem;
  background-color: var(--vp-c-brand-1);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
}

button:hover {
  background-color: var(--vp-c-brand-2);
}

.result-box {
  padding: 1rem;
  background-color: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  min-height: 3rem;
  display: flex;
  align-items: center;
  font-family: var(--vp-font-mono);
  font-size: 1.1em;
}
</style>
