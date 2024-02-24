<script context="module">
	export const evidenceInclude = true;
</script>

<script>
	import { INPUTS_CONTEXT_KEY } from '@evidence-dev/component-utilities/globalContexts';
	import { getContext } from 'svelte';

	const inputs = getContext(INPUTS_CONTEXT_KEY);

	export let name;
    export let min = -100;
    export let max = 100;

    let current = Math.round((min + max) / 2);
	$: $inputs[name] = current;
</script>

<input type="range" bind:value={current} {min} {max} />