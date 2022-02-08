<script lang="ts">
	import { goto } from '$app/navigation';

	import { Button } from '$lib/ui/base';
	import type { StructureCard } from './index.svelte';

	export let structures: StructureCard[];

	const viewStructure = (id: string) => () => goto(`/admin_structure/structure/${id}`);
</script>

<div>
	{#each structures as structure}
		{structure.name}
		<Button on:click={viewStructure(structure.id)}>Voir</Button>
	{/each}
</div>
