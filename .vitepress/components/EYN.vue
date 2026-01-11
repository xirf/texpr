<script setup lang="ts">
import { ChartSpline, Code2, Flag, Shield, Triangle, X } from 'lucide-vue-next';

</script>

<template>
    <!-- Features Grid (Bento) -->
    <section id="features" class="py-20 px-6 relative">
        <div class="max-w-7xl mx-auto">
            <div class="text-center mb-16 flex flex-col items-center">
                <h2 class="text-3xl! md:text-5xl! font-bold! dark:text-white mb-4!">Everything you need</h2>
                <p class="text-lg! max-w-2xl text-slate-400 mx-auto">From basic arithmetic to symbolic differentiation, texpr
                    handles the heavy lifting of mathematical parsing.</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 auto-rows-[minmax(180px,auto)]">

                <!-- Main Feature: LaTeX Parsing -->
                <div class="glass-card rounded-2xl p-8 lg:col-span-2 row-span-2 relative overflow-hidden group">
                    <div
                        class="absolute top-0 right-0 w-64 h-64 bg-pink-500/20 rounded-full blur-3xl -mr-16 -mt-16 transition-opacity group-hover:opacity-100 opacity-50">
                    </div>
                    <div class="w-12 h-12 rounded-lg bg-slate-800 flex items-center justify-center mb-6 text-violet-500">
                        <Code2 />
                    </div>
                    <h3 class="text-2xl! font-bold! text-white! mb-2!">Native LaTeX Evaluation</h3>
                    <p class="text-slate-400! mb-6!">Don't convert LaTeX to Dart by hand. Write standard LaTeX notation and let the
                        texpr evaluate the expression tree for you. Supports unicode symbols like <span
                            class="font-mono! text-white!">∑</span>, <span class="font-mono! text-white!">∫</span>, and
                        <span class="font-mono! text-white!">√</span>.</p>
                    <div class="bg-slate-800/50 rounded-lg p-3 font-mono text-xs text-slate-300 border border-slate-700/50">
                        <span class="text-yellow-500">Texpr<span class="text-white">.evaluate</span><span class="text-blue-400">(</span><span class="text-green-400">r"\sum_{i=0}^{n} i^2"</span><span class="text-blue-400"><span class="text-white">, {<span class="text-green-400">"n"</span>: <span class="text-yellow-400">10</span>}</span>)</span></span>
                    </div>
                </div>

                <!-- Feature: Type Safety -->
                <div class="glass-card rounded-2xl p-6 lg:col-span-1">
                    <div
                        class="w-10 h-10 rounded-lg bg-slate-800 flex items-center justify-center mb-4 text-emerald-400">
                        <Shield />
                    </div>
                    <h3 class="text-xl! font-bold! text-white! mb-2!">Dart 3 Type Safety</h3>
                    <p class="text-sm! text-slate-400!">Returns <code
                            class="text-emerald-400! bg-emerald-400/10! px-1! rounded!">sealed</code> classes. Handle <code
                            class="text-white!">Numeric</code>, <code class="text-white!">Complex</code>, or <code
                            class="text-white!">Matrix</code> results safely.</p>
                </div>

                <!-- Feature: Calculus -->
                <div class="glass-card rounded-2xl p-6 lg:col-span-1">
                    <div
                        class="w-10 h-10 rounded-lg bg-slate-800 flex items-center justify-center mb-4 text-purple-400">
                        <Triangle class="rotate-180" />
                    </div>
                    <h3 class="text-xl! font-bold! text-white! mb-2!">Symbolic Calculus</h3>
                    <p class="text-sm! text-slate-400!">Compute derivatives and gradients <code
                            class="font-mono! text-purple-300!">(\nabla)</code> automatically using built-in algebraic
                        rules.</p>
                </div>

                <!-- Feature: Linear Algebra -->
                <div class="glass-card rounded-2xl p-6 lg:col-span-1">
                    <div class="w-10 h-10 rounded-lg bg-slate-800 flex items-center justify-center mb-4 text-sky-400">
                        <ChartSpline />
                    </div>
                    <h3 class="text-xl! font-bold! text-white! mb-2!">Linear Algebra</h3>
                    <p class="text-sm! text-slate-400!">Determinants, inverses, and matrix arithmetic. Just type <code
                            class="font-mono! text-sky-300!">\begin{pmatrix}...</code></p>
                </div>

                <!-- Feature: Implicit Mult -->
                <div class="glass-card rounded-2xl p-6 lg:col-span-1">
                    <div class="w-10 h-10 rounded-lg bg-slate-800 flex items-center justify-center mb-4 text-amber-400">
                        <X />
                    </div>
                    <h3 class="text-xl! font-bold! text-white! mb-2!">Implicit Syntax</h3>
                    <p class="text-sm! text-slate-400!">Understands human math like <span
                            class="math-font! text-amber-200!">2πr²</span> or <span class="math-font! text-amber-200!">sin
                            2x</span> without needing explicit <code class="font-mono! text-xs!">*</code> symbols.</p>
                </div>

                <!-- Feature: Logic & Piecewise -->
                <div class="glass-card rounded-2xl p-8 lg:col-span-4 bg-gradient-to-br from-slate-900 to-indigo-950/30">
                    <div class="flex flex-col md:flex-row gap-6 items-center">
                        <div>
                            <div
                                class="w-12 h-12 rounded-lg bg-slate-800 flex items-center justify-center mb-6 text-indigo-400">
                                <Flag />
                            </div>
                            <h3 class="text-2xl! font-bold! text-white! mb-2!">Logic & Conditions</h3>
                            <p class="text-slate-400! max-w-xl!">Boolean algebra support (<code
                                    class="font-mono! bg-slate-500! dark:bg-slate-800! px-1! rounded!">\land \lor \neg</code>) and comparisons. Perfect for evaluating
                                piecewise functions or domain constraints like <span
                                    class="math-font! text-white! bg-slate-500! dark:bg-slate-800! px-1! rounded!">x >
                                    0</span>.</p>
                        </div>
                        <div
                            class="flex-1 w-full bg-[#0d1117] rounded-lg p-4 border border-slate-800 font-mono text-xs text-slate-300">
                            <div class="mb-2 text-slate-500">// Example: Piecewise logic</div>
                            <div class="text-indigo-300">f(x) = \begin{cases} x^2 & x < 0 \\ x & x \ge 0
                                    \end{cases}</div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
    </section>
</template>

<style>
    @reference "../theme/custom.css";
</style>