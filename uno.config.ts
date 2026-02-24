import { defineConfig, presetWind4, presetIcons, transformerDirectives } from 'unocss'

export default defineConfig({
  presets: [
    presetWind4(),
    presetIcons({
      collections: {
        solar: () => import('@iconify-json/solar/icons.json').then(i => i.default as any)
      }
    })
  ],
  transformers: [
    transformerDirectives(),
  ],
})
