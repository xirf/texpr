<template>
    <Ray class="h-[60vh] -top-16 pointer-events-none opacity-[.35] dark:opacity-40" />
    <section
        class="z-10 relative flex w-full pt-6 md:pt-0 mb-16 md:mb-8 px-6 min-h-[80svh] items-center justify-center">
        <div class="flex flex-col text-center">
            <div class="flex flex-col gap-4 max-w-screen-lg items-center">
                <h1 class="text-6xl! xl:!text-9xl !font-black font-mono xl:mb-10!">TeXpr</h1>
                <p class="text-4xl! xl:!text-5xl mb-6! !font-bold">Math, parsed from <span
                        class="bg-gradient-to-r from-purple-400 to-violet-400 bg-clip-text text-transparent">LaTeX
                        syntax.</span></p>
                <p
                    class="text-xl! md:text-2xl text-gray-500 dark:text-gray-400 !leading-normal text-left w-full max-w-2xl md:text-center">
                    A type-safe Dart library that turns <code
                        class="bg-gray-100! font-mono! dark:bg-gray-800! px-2! py-1! rounded! text-gray-300 dark:text-gray-200">\frac{d}{dx}</code>
                    strings into evaluated results. Symbolic calculus, linear algebra, boolean logic, and matrices
                    included.</p>
                <section
                    class="flex flex-col sm:flex-row items-start sm:items-center w-full md:w-auto gap-4 mt-8 mb-12">
                    <a class="text-white! font-semibold text-lg bg-violet-400 dark:bg-violet-500 px-6 py-2.5 rounded-full"
                        id="hero-get-started" href="/guide">
                        Get Started
                    </a>
                    <div class="relative flex flex-1 gap-3 text-violet-500">
                        <code
                            class="text-violet-500 dark:text-violet-400 font-mono font-medium text-lg bg-violet-200/25 dark:bg-violet-500/20 px-6 py-2.5 rounded-full">
                            dart pub add texpr
                        </code>
                    </div>
                    <div class="hidden sm:inline-flex p-3 cursor-pointer  hover:rounded-full dark:hover:bg-violet-500/20 transition-all  relative"
                        @click="copied = true">
                        <Copy class="text-violet-500" />
                        <span class="absolute -top-3 left-0 h-full text-violet-600 transition-all duration-300 ease-out"
                            :style="{ opacity: copied ? 1 : 0, transform: copied ? 'translateY(-20px)' : 'translateY(0px)' }"
                            >Copied</span>
                    </div>
                </section>
            </div>
        </div>
    </section>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'

import Ray from './Ray.vue'
import { Copy } from 'lucide-vue-next'

const copied = ref(false)
watch(copied, (value) => {
    // [INFO] navigator.clipboard available only in secure contexts.
    if (value && window.isSecureContext) {
        navigator.clipboard.writeText('dart pub add texpr')

        setTimeout(() => {
            copied.value = false
        }, 2000)
    }
})
</script>
