
    import evidencePreprocess from '@evidence-dev/preprocess'
    import adapter from '@sveltejs/adapter-static';
    
    /** @type {import('@sveltejs/kit').Config} */
    
    const config = {
        extensions: ['.svelte', ".md"],
        preprocess: evidencePreprocess(),
        kit: {
            adapter: adapter(),
            files: {
                routes: 'src/pages',
                lib: 'src/components'
            },
            vite: {
                optimizeDeps: {
                    include: ['echarts-stat', 'export-to-csv', 'ssf', 'downloadjs'],
                    exclude: ['@evidence-dev/components']
                },
                ssr: {
                    external: ['@evidence-dev/db-orchestrator', 'git-remote-origin-url', '@evidence-dev/telemetry']
                }
            }
        }
    };
    
    export default config    
    