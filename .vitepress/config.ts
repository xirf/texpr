import { defineConfig } from "vitepress";
import nav from "./config/nav";
import sidebar from "./config/sidebar";
import UnoCSS from 'unocss/vite'
import llmstxt from 'vitepress-plugin-llms'

const description = "LaTeX Math Expression Parser & Evaluator for Dart"

export default defineConfig({
  title: "TeXpr",
  description,
  srcDir: "doc",
  lastUpdated: true,
  head: [
    ['link', { rel: 'icon', href: '/logo.svg', type: 'image/svg+xml' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { href: 'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;700&display=swap', rel: 'stylesheet' }]
  ],
  sitemap: {
    hostname: 'https://texpr.andka.id',
  },
  markdown: {
    math: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    },
  },
  vite: {
    plugins: [
      UnoCSS(),
      process.env.NODE_ENV === 'production'
        ? llmstxt({
          description,
          details: description,
          ignoreFiles: [
            'index.md',
            'table-of-content.md',
            'blog/*',
            'public/*'
          ],
          domain: 'https://texprjs.com'
        })
        : undefined,
    ]
  },
  themeConfig: {
    logo: "/logo.svg",
    nav,
    sidebar,
    search: {
      provider: "local",
    },
    socialLinks: [
      { icon: "github", link: "https://github.com/xirf/texpr" },
      { icon: "dart", link: "https://pub.dev/packages/texpr", ariaLabel: "Pub.dev" }
    ],
    footer: {
      message: "Made with ❤️ by TeXpr, Docs Inspired by ElysiaJS",
    },
    outline: {
      level: [2, 3],
      label: 'On this page'
    },
    editLink: {
      text: 'Edit this page on GitHub',
      pattern:
        'https://github.com/xirf/texpr/edit/main/doc/:path'
    }
  },
});