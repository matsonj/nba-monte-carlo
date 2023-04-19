
    import evidencePreprocess from '@evidence-dev/preprocess'
    import preprocess from "svelte-preprocess";
    import adapter from '@sveltejs/adapter-static';
    
    /** @type {import('@sveltejs/kit').Config} */
    
    const config = {
        extensions: ['.svelte', ".md"], 
        preprocess: [
            ...evidencePreprocess(true),
            preprocess({
              postcss: true,
            }),
        ],
        kit: {
            adapter: adapter({
                strict: false
            }),
            files: {
                routes: 'src/pages',
                lib: 'src/components'
            }
        }
    };
    
    export default config    
    