// svelte.config.js
import adapter from '@sveltejs/adapter-static';

export default {
  kit: {
    adapter: adapter({
      strict: false
  }),
    prerender: {
      handleHttpError: ({ status, path, referrer, referenceType }) => {
        if (status === 404) {
          console.warn(`404 error encountered. Path: ${path}, Referrer: ${referrer}, ReferenceType: ${referenceType}`);
          // Customize your handling logic here
        }
      }
    }
  }
};