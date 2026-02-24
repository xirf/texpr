import DefaultTheme from 'vitepress/theme'
import 'virtual:uno.css'
import Playground from '../components/Playground.vue'
import Layout from '../components/Layouts.vue'
import Ray from '../components/Ray.vue'
import Hero from '../components/Hero.vue'
import EYN from '../components/EYN.vue'

import './vars.css'
import './override.css'

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
