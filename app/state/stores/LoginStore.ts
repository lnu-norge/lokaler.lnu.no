import { makeAutoObservable } from 'mobx'
import { AppStateStore } from '../AppState'

/** 
 * LoginStore handles state for logins.
 * 
 * Currently just scaffolding.
 * 
 */
export class LoginStore {
	isLoggedIn: boolean = false

	appState: AppStateStore
	constructor(appState: AppStateStore) {
		makeAutoObservable(this)
		this.appState = appState
	}

	/** Takes a user object and sets the right state for a logged in user */
	onLogin = async (user: any) => {
		this.isLoggedIn = true
	}

	/** Sets the right state for a logged out user */
	onLogout = async () => {
		this.isLoggedIn = false
	}
}
