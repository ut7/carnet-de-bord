<script context="module" lang="ts">
	import type { Professional } from '$lib/graphql/_gen/typed-document-nodes';
	import { GetAccountDocument } from '$lib/graphql/_gen/typed-document-nodes';
	import { LoaderIndicator } from '$lib/ui/utils';
	import type { Load } from '@sveltejs/kit';
	import { operationStore, query } from '@urql/svelte';

	export const load: Load = ({ page }) => {
		const accountId = page.params.uuid;

		return {
			props: {
				accountId,
			},
		};
	};
</script>

<script lang="ts">
	import ProWithStructureView from '$lib/ui/ProNotebookMember/ProWithStructureView.svelte';
	import { post } from '$lib/utils/post';
	import Button from '$lib/ui/base/Button.svelte';
	import { goto } from '$app/navigation';

	export let accountId: string;
	const variables = { accountId };
	const getAccountStore = operationStore(GetAccountDocument, variables);
	query(getAccountStore);
	$: acc = $getAccountStore?.data?.account_by_pk;
	$: professional = acc?.professional as Professional | null;

	let magicLink: string;
	async function impersonate() {
		const response = await post('/auth/login', { impersonate: acc.username });
		console.log({ response });
		if (response.status === 302) {
			const location = response.headers.get('location');
			console.log({ location });
			goto(location);
			return;
		}
		if (response.status === 401) {
		}
		if (response.status === 200) {
			const { accessUrl } = await response.json();
			magicLink = accessUrl;
		} else {
			magicLink = '';
		}
		console.log({ magicLink });
	}
</script>

<svelte:head>
	<title>Fiche professionnel - carnet de bord</title>
</svelte:head>

<div class="flex flex-col gap-8 p-20">
	<LoaderIndicator result={getAccountStore}>
		<div><Button on:click={impersonate}>Impersonate</Button></div>
		{#if acc.professional}
			<ProWithStructureView {professional} proFirst={true} />
		{/if}
	</LoaderIndicator>
</div>
