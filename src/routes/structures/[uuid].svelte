<script context="module" lang="ts">
	import type { GetStructureQueryStore } from '$lib/graphql/_gen/typed-document-nodes';
	import { GetStructureDocument } from '$lib/graphql/_gen/typed-document-nodes';
	import { LoaderIndicator } from '$lib/ui/utils';
	import type { Load } from '@sveltejs/kit';
	import { operationStore, query } from '@urql/svelte';

	export const load: Load = ({ params }) => {
		const structureId = params.uuid;
		const getStructure = operationStore(GetStructureDocument, { structureId });

		return {
			props: {
				getStructure,
			},
		};
	};
</script>

<script lang="ts">
	export let getStructure: GetStructureQueryStore;

	query(getStructure);

	$: structure = $getStructure.data?.structure_by_pk;
	$: members = structure?.admins_aggregate?.nodes?.map(({ admin_structure: { id, email } }) => ({
		id,
		email,
	}));
</script>

<svelte:head>
	<title>Structure - Carnet de bord</title>
</svelte:head>

<LoaderIndicator result={getStructure}>
	<div>{structure.name}</div>
	{#each members as member (member.id)}
		<div>Email : {member.email}</div>
	{/each}
</LoaderIndicator>
