export default [
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
                text: "Features",
                items: [
                    { text: "Boolean Logic", link: "/guide/logic" },
                    { text: "Piecewise Functions", link: "/guide/piecewise" },
                    { text: "Interval Arithmetic", link: "/guide/intervals" },
                    { text: "Custom Environments", link: "/guide/environments" },
                ],
            },
            {
                text: "Tools",
                items: [
                    { text: "Playground", link: "/guide/playground" },
                ],
            },
        ],
        activeMatch: "^/guide/",
    },
    {
        text: "Reference",
        items: [
            { text: "Overview", link: "/reference/" },
            {
                text: "Syntax & Language",
                items: [
                    { text: "LaTeX Commands", link: "/reference/latex" },
                    { text: "Grammar Spec", link: "/reference/grammar" },
                    { text: "Functions", link: "/reference/functions" },
                    { text: "Constants", link: "/reference/constants" },
                ],
            },
            {
                text: "Technical Details",
                items: [
                    { text: "Data Types", link: "/reference/data-types" },
                    { text: "Behavior", link: "/reference/behavior" },
                    { text: "Exceptions", link: "/reference/exceptions" },
                    { text: "API Reference", link: "/reference/api" },
                    { text: "Known Issues", link: "/reference/known-issues" },
                ],
            },
        ],
        activeMatch: "^/reference/",
    },
    {
        text: "How It Works",
        items: [
            { text: "Overview", link: "/how-it-works/" },
            {
                text: "Architecture",
                items: [
                    { text: "Tokenizer", link: "/how-it-works/tokenizer" },
                    { text: "Parser", link: "/how-it-works/parser" },
                    { text: "Evaluator", link: "/how-it-works/evaluator" },
                ],
            },
            {
                text: "Optimization",
                items: [
                    { text: "Caching", link: "/how-it-works/caching" },
                    { text: "Performance", link: "/how-it-works/performance" },
                ],
            },
        ],
        activeMatch: "^/how-it-works/",
    },
    {
        text: "Advanced",
        items: [
            { text: "Overview", link: "/advanced/" },
            {
                text: "Topics",
                items: [
                    { text: "Symbolic Algebra", link: "/advanced/symbolic" },
                    { text: "Calculus", link: "/advanced/calculus" },
                    { text: "Extensions", link: "/advanced/extensions" },
                    { text: "Security", link: "/advanced/security" },
                ],
            },
        ],
        activeMatch: "^/advanced/",
    },
    {
        text: 'v0.1.3',
        items: [
            {
                text: "Project Info",
                items: [
                    { text: "Changelog", link: "https://github.com/xirf/texpr/blob/main/CHANGELOG.md" },
                    { text: "Release Notes", link: "https://github.com/xirf/texpr/releases" },
                    { text: "Contributing", link: "https://github.com/xirf/texpr/blob/main/CONTRIBUTING.md" },
                ],
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
];
