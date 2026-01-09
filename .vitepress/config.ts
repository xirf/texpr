import { defineConfig } from "vitepress";

export default defineConfig({
  title: "TeXpr",
  description: "LaTeX Math Expression Parser & Evaluator for Dart",
  srcDir: "doc",

  head: [['link', { rel: 'icon', href: '/logo.svg', type: 'image/svg+xml' }]],
  sitemap: {
    hostname: 'https://texpr.dev',
  },


  themeConfig: {
    logo: "/logo.svg",

    nav: [
      {
        text: "Guide",
        items: [
          {
            text: "Getting Started",
            items: [
              { text: "Introduction", link: "/guide/" },
              { text: "Installation", link: "/guide/installation" },
              { text: "Quick Start", link: "/guide/quick-start" },
              { text: "Core Concepts", link: "/guide/concepts" },
            ],
          },
          {
            text: "Usage",
            items: [
              { text: "Custom Environments", link: "/guide/environments" },
              { text: "Interval Arithmetic", link: "/guide/intervals" },
              { text: "Playground", link: "/guide/playground" },
            ],
          },
        ],
        activeMatch: "^/guide/",
      },
      {
        text: "How It Works",
        items: [
          { text: "Overview", link: "/how-it-works/" },
          { text: "Tokenizer", link: "/how-it-works/tokenizer" },
          { text: "Parser", link: "/how-it-works/parser" },
          { text: "Evaluator", link: "/how-it-works/evaluator" },
          { text: "Caching", link: "/how-it-works/caching" },
          { text: "Performance", link: "/how-it-works/performance" },
        ],
        activeMatch: "^/how-it-works/",
      },
      {
        text: "Reference",
        items: [
          { text: "Overview", link: "/reference/" },
          {
            text: "Syntax",
            items: [
              { text: "LaTeX Commands", link: "/reference/latex" },
              { text: "Grammar Spec", link: "/reference/grammar" },
              { text: "Functions", link: "/reference/functions" },
              { text: "Constants", link: "/reference/constants" },
            ],
          },
          {
            text: "API",
            items: [
              { text: "Data Types", link: "/reference/data-types" },
              { text: "Exceptions", link: "/reference/exceptions" },
              { text: "Behavior", link: "/reference/behavior" },
              { text: "API Reference", link: "/reference/api" },
            ],
          },
          { text: "Known Issues", link: "/reference/known-issues" },
        ],
        activeMatch: "^/reference/",
      },
      {
        text: "Advanced",
        items: [
          { text: "Overview", link: "/advanced/" },
          { text: "Symbolic Algebra", link: "/advanced/symbolic" },
          { text: "Calculus", link: "/advanced/calculus" },
          { text: "Extensions", link: "/advanced/extensions" },
          { text: "Security", link: "/advanced/security" },
        ],
        activeMatch: "^/advanced/",
      },
      {
        text: 'v0.1.1',
        items: [
          {
            text: "Changelog",
            link: "https://github.com/xirf/texpr/blob/main/CHANGELOG.md",
          },
          {
            text: "Release Notes",
            link: "https://github.com/xirf/texpr/releases",
          },
          {
            text: "Contributing",
            link: "https://github.com/xirf/texpr/blob/main/CONTRIBUTING.md",
          },
          {
            text: "Links",
            items: [
              { text: "pub.dev", link: "https://pub.dev/packages/texpr" },
              { text: "GitHub", link: "https://github.com/xirf/texpr" },
            ],
          },
        ],
      },
    ],

    sidebar: {
      "/guide/": [
        {
          text: "Getting Started",
          items: [
            { text: "Introduction", link: "/guide/" },
            { text: "Installation", link: "/guide/installation" },
            { text: "Quick Start", link: "/guide/quick-start" },
            { text: "Core Concepts", link: "/guide/concepts" },
              { text: "Custom Environments", link: "/guide/environments" },
              { text: "Interval Arithmetic", link: "/guide/intervals" },
              { text: "Interactive Playground", link: "/guide/playground" },
          ],
        },
      ],
      "/how-it-works/": [
        {
          text: "How It Works",
          items: [
            { text: "Overview", link: "/how-it-works/" },
            { text: "Tokenizer", link: "/how-it-works/tokenizer" },
            { text: "Parser", link: "/how-it-works/parser" },
            { text: "Evaluator", link: "/how-it-works/evaluator" },
            { text: "Caching", link: "/how-it-works/caching" },
            { text: "Performance", link: "/how-it-works/performance" },
          ],
        },
      ],
      "/reference/": [
        {
          text: "Reference",
          items: [
            { text: "Overview", link: "/reference/" },
            { text: "LaTeX Commands", link: "/reference/latex" },
            { text: "Grammar Spec", link: "/reference/grammar" },
            { text: "Functions", link: "/reference/functions" },
            { text: "Constants", link: "/reference/constants" },
            { text: "Data Types", link: "/reference/data-types" },
            { text: "Exceptions", link: "/reference/exceptions" },
            { text: "Behavior", link: "/reference/behavior" },
            { text: "Known Issues", link: "/reference/known-issues" },
            { text: "API Reference", link: "/reference/api" },
          ],
        },
      ],
      "/advanced/": [
        {
          text: "Advanced",
          items: [
            { text: "Overview", link: "/advanced/" },
            { text: "Symbolic Algebra", link: "/advanced/symbolic" },
            { text: "Calculus", link: "/advanced/calculus" },
            { text: "Extensions", link: "/advanced/extensions" },
            { text: "Security", link: "/advanced/security" },
          ],
        },
      ],
    },

    socialLinks: [{ icon: "github", link: "https://github.com/xirf/texpr" }],

    search: {
      provider: "local",
    },

    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2024-present TeXpr Contributors",
    },
  },

  markdown: {
    math: true,
  },
});
