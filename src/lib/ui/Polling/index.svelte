<script lang="ts" context="module">
	let counter = 1;
</script>

<script lang="ts">
	import { Button } from '$lib/ui/base';

	type Question = {
		title: string;
		subtitle: string;
		lowerBound: string;
		upperBound: string;
		answer?: string;
	};
	let satisfactionQuestion: Question = {
		title: 'Êtes-vous satisfait(e) de Carnet de bord ?',
		subtitle: "Est-ce que l'outil répond à vos attentes ?",
		lowerBound: 'Pas du tout',
		upperBound: 'Complètement',
	};
	let recommendQuestion: Question = {
		title: 'Recommanderiez-vous Carnet de bord ?',
		subtitle: 'À des collègues, des partenaires, etc.',
		lowerBound: 'Pas du tout',
		upperBound: 'Complètement',
	};
	let questions = [satisfactionQuestion, recommendQuestion];
	let currentIndex = 0;
	let currentQuestion: Question = questions[currentIndex];
	let currentGrade: string;
	let collapsed = true;
	let onClose: () => void;

	function move(forward: boolean) {
		if (currentQuestion) {
			currentQuestion.answer = currentGrade;
		}

		if (forward) {
			currentIndex = currentIndex + 1;
		} else {
			currentIndex = currentIndex > 0 ? currentIndex - 1 : currentIndex;
		}

		currentQuestion = questions[currentIndex];
		if (currentQuestion) {
			currentGrade = currentQuestion.answer;
		}
	}

	function save() {
		console.log('saving', { questions });
	}

	function close(neverAgain: boolean) {
		console.log('closing widget', { neverAgain });
	}

	const validate = (): void => {
		save();
		close(true);
	};

	let name = `radio-group`;

	$: groupId = `${name}-${counter}`;
</script>

<div class="shadow-md">
	<div class="bg-france-blue text-white p-4 flex flex-row justify-between">
		<div>Nous avons besoin de vous !</div>
		<div class="cursor-pointer" on:click={() => (collapsed = !collapsed)}>
			{#if collapsed}
				&#x25BC;
			{:else}
				&#x25B2;
			{/if}
		</div>
	</div>
	{#if !collapsed}
		{#if currentQuestion}
			<div class="p-4">
				Répondez à ces trois questions (moins d'une minute) pour nous aider à améliorer Carnet de
				bord.
			</div>
			<div class="fr-form-group p-4 !mb-0 relative">
				<div class="absolute right-0 top-0 p-4 text-france-blue">
					{currentIndex + 1}/{questions.length}
				</div>
				<fieldset class="fr-fieldset fr-fieldset--inline">
					<legend class="fr-fieldset__legend fr-text--regular" id="radio-legend">
						{currentQuestion.title}
						<span class="fr-hint-text">{currentQuestion.subtitle}</span>
					</legend>
					<div class="fr-fieldset__content my-4 flex flex-row !justify-between">
						<div>{currentQuestion.lowerBound}</div>
						{#key currentQuestion.title}
							<div>
								{#each ['1', '2', '3', '4', '5'] as option}
									<div class="fr-radio-group">
										<input
											type="radio"
											id="radio-{option}"
											name={groupId}
											value={option}
											bind:group={currentGrade}
										/>
										<label class="fr-label" for="radio-{option}">{option}</label>
									</div>
								{/each}
							</div>
						{/key}
						<div>{currentQuestion.upperBound}</div>
					</div>
				</fieldset>
			</div>
			<div class="flex flex-row p-4 gap-1">
				<div class="flex-grow-1 w-full flex gap-2">
					<div
						class="underline flex-shrink self-center cursor-pointer"
						on:click={() => close(false)}
					>
						Plus tard
					</div>
					<div
						class="underline flex-shrink self-center cursor-pointer"
						on:click={() => close(true)}
					>
						Ne plus me demander
					</div>
				</div>
				<Button on:click={() => move(false)} disabled={currentIndex === 0}>&lt;</Button>
				<Button on:click={() => move(true)}>&gt;</Button>
			</div>
		{:else}
			<div class="flex flex-col items-center">
				<div class="p-4 pb-0">Merci, c'est terminé !</div>
				<div class="w-full flex flex-row justify-between p-4">
					<span class="cursor-pointer underline" on:click={() => move(false)}>
						Modifier mes réponses
					</span>
					<Button on:click={validate}>Enregistrer mes réponses</Button>
				</div>
			</div>
		{/if}
	{/if}
</div>
