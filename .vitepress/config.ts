import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'TeXpr',
  description: 'LaTeX Math Expression Parser & Evaluator for Dart',
  srcDir: 'doc',
  
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
  ],

  themeConfig: {
    logo: '/logo.svg',
    
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'How It Works', link: '/how-it-works/' },
      { text: 'Reference', link: '/reference/' },
      { text: 'Advanced', link: '/advanced/' },
      {
        text: 'Links',
        items: [
          { text: 'pub.dev', link: 'https://pub.dev/packages/texpr' },
          { text: 'GitHub', link: 'https://github.com/xirf/texpr' },
        ],
      },
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/guide/' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Quick Start', link: '/guide/quick-start' },
            { text: 'Core Concepts', link: '/guide/concepts' },
          ],
        },
      ],
      '/how-it-works/': [
        {
          text: 'How It Works',
          items: [
            { text: 'Overview', link: '/how-it-works/' },
            { text: 'Tokenizer', link: '/how-it-works/tokenizer' },
            { text: 'Parser', link: '/how-it-works/parser' },
            { text: 'Evaluator', link: '/how-it-works/evaluator' },
            { text: 'Caching', link: '/how-it-works/caching' },
          ],
        },
      ],
      '/reference/': [
        {
          text: 'Reference',
          items: [
            { text: 'Overview', link: '/reference/' },
            { text: 'LaTeX Commands', link: '/reference/latex' },
            { text: 'Functions', link: '/reference/functions' },
            { text: 'Constants', link: '/reference/constants' },
            { text: 'Data Types', link: '/reference/data-types' },
            { text: 'Exceptions', link: '/reference/exceptions' },
            { text: 'API Reference', link: '/reference/api' },
          ],
        },
      ],
      '/advanced/': [
        {
          text: 'Advanced',
          items: [
            { text: 'Overview', link: '/advanced/' },
            { text: 'Symbolic Algebra', link: '/advanced/symbolic' },
            { text: 'Calculus', link: '/advanced/calculus' },
            { text: 'Extensions', link: '/advanced/extensions' },
            { text: 'Security', link: '/advanced/security' },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/xirf/texpr' },
    ],

    search: {
      provider: 'local',
    },

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present TeXpr Contributors',
    },
  },

  markdown: {
    math: true,
  },
})
