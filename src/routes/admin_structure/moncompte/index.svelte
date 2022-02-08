<script lang="ts">
	import { account, openComponent } from '$lib/stores';
	import AdminStructureAccountEdit from '$lib/ui/AdminStructureAccount/AdminStructureAccountEdit.svelte';
	import AdminStructureView from '$lib/ui/AdminStructureView.svelte';
	import { Button } from '$lib/ui/base';
	import { homeForRole, Segment } from '$lib/routes';
	import Breadcrumbs from '$lib/ui/base/Breadcrumbs.svelte';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import type { ConnectedAdminStructure } from '$lib/stores/account';

	function editAccount() {
		openComponent.open({
			component: AdminStructureAccountEdit,
			props: { adminStructure: $account },
		});
	}

	onMount(() => {
		if (!$account.onboardingDone) {
			goto(homeForRole('admin_structure'));
		}
	});

	const breadcrumbs: Segment[] = [
		{
			name: 'accueil',
			path: '/admin_structure',
			label: 'Accueil',
		},
		{
			name: 'profile',
			path: '/mon compte',
			label: 'Mon compte',
		},
	];
	function toConnectedAdminStructure(admin) {
		return admin as ConnectedAdminStructure;
	}
</script>

<svelte:head>
	<title>Mon compte - Carnet de bord</title>
</svelte:head>

<Breadcrumbs segments={breadcrumbs} />

<h1>Mon compte</h1>
<AdminStructureView adminStructure={toConnectedAdminStructure($account)} />
<div class="pt-8">
	<Button on:click={editAccount} outline={true}>Mettre à jour</Button>
</div>
