import { sveltekit } from "@sveltejs/kit/vite"
    const strictFs = (process.env.NODE_ENV === 'development') ? false : true;
    /** @type {import('vite').UserConfig} */
     const config = 
    {
        plugins: [sveltekit()],
        optimizeDeps: {
            include: ['echarts-stat', 'echarts'],
            exclude: ['@evidence-dev/components', 'svelte-icons', 'svelte-tiny-linked-charts']
        },
        ssr: {
            external: ['@evidence-dev/db-orchestrator', '@evidence-dev/telemetry', 'blueimp-md5']
        },
        server: {
            fs: {
                strict: strictFs // allow template to get dependencies outside the .evidence folder
            }
        }
    }
    export default config