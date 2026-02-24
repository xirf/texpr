<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useData, useRouter } from 'vitepress'
import { Copy, File } from 'lucide-vue-next'
import Ray from './Ray.vue'
import {
  nextTick,
  provide,
  computed,
  ref,
} from 'vue'

const router = useRouter()
const { isDark } = useData()
const copied = ref(false)

function enableTransitions() {
  return 'startViewTransition' in document
    && window.matchMedia('(prefers-reduced-motion: no-preference)').matches
}

provide('toggle-appearance', async ({ clientX: x, clientY: y }: MouseEvent) => {
  if (!enableTransitions()) {
    isDark.value = !isDark.value
    return
  }

  const clipPath = [
    `circle(0px at ${x}px ${y}px)`,
    `circle(${Math.hypot(
      Math.max(x, innerWidth - x),
      Math.max(y, innerHeight - y),
    )}px at ${x}px ${y}px)`,
  ]

  await document.startViewTransition(async () => {
    isDark.value = !isDark.value
    await nextTick()
  }).ready

  document.documentElement.animate(
    { clipPath: isDark.value ? clipPath.reverse() : clipPath },
    {
      duration: 300,
      easing: 'ease-in',
      fill: 'forwards',
      pseudoElement: `::view-transition-${isDark.value ? 'old' : 'new'}(root)`,
    },
  )
})

const prompt = computed(() =>
  encodeURI(
    `I'm looking at https://texpr.andka.id${router.route.path}.\n\nWould you kindly explain, summarize the concept, and answer any questions I have about it?`
  )
)

const copyPage = () => {
  // fetcth to /{page}.md
  const url = `${window.location.origin}${router.route.path.replace(/.html$/g, '')}.md`
  console.log(url)
  fetch(url)
    .then(response => response.text())
    .then(text => {
      navigator.clipboard.writeText(text)
      copied.value = true
      setTimeout(() => {
        copied.value = false
      }, 2000)
    })
    .catch(error => {
      console.error('Error copying page:', error)
    })
}


</script>

<template>
  <!-- eslint-disable-next-line vue/component-name-in-template-casing -->
  <DefaultTheme.Layout>

    <template #doc-top>
      <Ray class="h-[220px] top-0 left-0 opacity-25 dark:opacity-[.55] pointer-events-none" static />
    </template>

    <template #doc-before>
      <div class="flex justify-between mb-2">
        <SidebarText />
        <PageActionMenu />
      </div>
    </template>
  </DefaultTheme.Layout>
</template>