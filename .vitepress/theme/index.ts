import DefaultTheme from 'vitepress/theme'
import Playground from '../components/Playground.vue'
import Layout from '../components/Layouts.vue'
import Ray from '../components/Ray.vue'
import Hero from '../components/Hero.vue'
import EYN from '../components/EYN.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }: { app: any }) {
    app.component('Playground', Playground)
    app.component('Ray', Ray)
    app.component('Hero', Hero)
    app.component('EYN', EYN)
  }
}
