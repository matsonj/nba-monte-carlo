<script>
	import '@evidence-dev/tailwind/fonts.css';
	import './app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	export let data;
</script>

<EvidenceDefaultLayout {data} 
	xProfile="https://www.x.com/matsonj"
	blueskyProfile="https://bsky.app/profile/matsonj.com"
	githubRepo="https://www.github.com/matsonj/nba-monte-carlo"
	title="mdsinabox"
	builtWithEvidence=true>
	<slot slot="content" />
</EvidenceDefaultLayout>
