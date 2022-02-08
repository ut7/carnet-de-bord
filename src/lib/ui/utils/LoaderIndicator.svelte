<script lang="ts">
	import type { OperationStore } from '@urql/svelte';

	type Data = $$Generic;

	interface $$Slots {
		default: {};
		data: { data: Data };
	}

	export let result: OperationStore<Data>;
</script>

{#if $result.data}
	{#if $$slots.data}
		<slot name="data" data={$result.data} />
	{:else}
		<slot />
	{/if}
{:else if $result.fetching}
	<div class="flex items-center justify-center">
		<p>Chargement en cours...</p>
	</div>
{:else if $result.error}
	<div class="flex items-center justify-center">
		<p>Une erreur s'est produite. Si le problème persiste, veuillez nous contacter.</p>
	</div>
{/if}
