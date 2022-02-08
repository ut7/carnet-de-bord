<script lang="ts" context="module">
	import { GetManagedStructuresDocument } from '$lib/graphql/_gen/typed-document-nodes';
	import type { Load } from '@sveltejs/kit';
	import { operationStore, query } from '@urql/svelte';
	export type StructureCard = {
		id: string;
		name: string;
		city: string;
		nbAdmin: number;
		nbProfessional: number;
		nbBeneficiary: number;
	};
	export const load: Load = async () => {
		const result = operationStore(GetManagedStructuresDocument, {});

		return {
			props: {
				result,
			},
		};
	};
</script>

<script lang="ts">
	import { account } from '$lib/stores';
	import LoaderIndicator from '$lib/ui/utils/LoaderIndicator.svelte';

	import StructureList from './StructureList.svelte';
	import AdminStructureAccountEdit from '$lib/ui/AdminStructureAccount/AdminStructureAccountEdit.svelte';
	import type { Segment } from '$lib/routes';
	import Breadcrumbs from '$lib/ui/base/Breadcrumbs.svelte';
	import type { ConnectedAdminStructure } from '$lib/stores/account';

	export let structureResult = operationStore(GetManagedStructuresDocument, {});

	query(structureResult);

	$: structures = $structureResult.data?.structures.map((data) => ({
		id: data.id,
		name: data.name,
		city: data.city,
		nbAdmin: data.admins_aggregate.aggregate.count,
		nbBeneficiary: data.beneficiaries_aggregate.aggregate.count,
		nbProfessional: data.professionals_aggregate.aggregate.count,
	}));

	const breadcrumbs: Segment[] = [
		{
			name: 'accueil',
			path: '/admin_structure',
			label: 'Accueil',
		},
	];
	function toConnectedAdminStructure(admin) {
		return admin as ConnectedAdminStructure;
	}
</script>

<svelte:head>
	<title>Gestion des structures - Carnet de bord</title>
</svelte:head>

{#if !$account?.onboardingDone}
	<div class="pt-12">
		<AdminStructureAccountEdit adminStructure={toConnectedAdminStructure($account)} />
	</div>
{:else}
	<Breadcrumbs segments={breadcrumbs} />
	<LoaderIndicator result={structureResult}>
		<h1>Mes structures</h1>
		<StructureList {structures} />
	</LoaderIndicator>
{/if}
