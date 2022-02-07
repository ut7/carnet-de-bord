import { writable } from 'svelte/store';
import type { Writable } from 'svelte/store';

export type ConnectedUser =
	| ConnectedPro
	| ConnectedAdminStructure
	| ConnectedManager
	| ConnectedBeneficiary;

type BaseConnectedUser = {
	id: string;
	accountId: string;
	onboardingDone: boolean;
	confirmed: boolean;
	username: string;
	firstname: string;
	lastname: string;
};

export type ConnectedPro = BaseConnectedUser & {
	email: string;
	position: string;
	mobileNumber: string;
};

export type ConnectedAdminStructure = BaseConnectedUser & {
	email: string;
	phoneNumbers: string;
};

export type ConnectedManager = BaseConnectedUser & {
	email: string;
};

export type ConnectedBeneficiary = BaseConnectedUser & {
	email: string;
	mobileNumber: string;
};

export const account: Writable<null | ConnectedUser> = writable(null);
