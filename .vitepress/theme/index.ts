import DefaultTheme from 'vitepress/theme'
import Playground from '../components/Playground.vue'
import Layout from '../components/Layouts.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }: { app: any }) {
    app.component('Playground', Playground)
  }
}
