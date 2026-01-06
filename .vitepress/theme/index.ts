import DefaultTheme from 'vitepress/theme'
import Playground from '../components/Playground.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }: { app: any }) {
    app.component('Playground', Playground)
  }
}
