import { defineConfig } from "vitepress";
import nav from "./config/nav";
import sidebar from "./config/sidebar";

export default defineConfig({
  title: "TeXpr",
  description: "LaTeX Math Expression Parser & Evaluator for Dart",
  srcDir: "doc",

  head: [['link', { rel: 'icon', href: '/logo.svg', type: 'image/svg+xml' }]],

  sitemap: {
    hostname: 'https://texpr.andka.id',
  },

  markdown: {
    math: true,
  },

  themeConfig: {
    logo: "/logo.svg",
    nav,
    sidebar,
    search: {
      provider: "local",
    },
    socialLinks: [
      { icon: "github", link: "https://github.com/xirf/texpr" }
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2024-present TeXpr Contributors",
    },
  },
});