import { LoginStore } from './stores/LoginStore'

// State store
/**
 * You usually want to import AppState, not the AppStateStore class.
 * 
 * AppState is created using this AppStateStore class.
 * 
 * An AppStateStore collects all AppState Mobx objects, and makes them easily available
 * and sharing access to the other AppState Mobx objects in bteween them.
 * 
 * Different domains of the app state gets its own store.
 * For example the login domain might have a state store 
 * named LoginStore that handles state for the users login, including
 * functions for changing state when logging out and in.
 * 
 * Each domain store also is aware of the other domain stores, by
 * being passed this AppStateStore object on creation. 
 */
export class AppStateStore {
	login!: LoginStore

	/** Clears all states, and sets default state content pre app load */
	resetState = () => {
		this.login = new LoginStore(this)
	}

	constructor() {
		this.resetState()
	}
}

// We only ever want one store, so we create it here and export for use:

/**
 * The global state for the app. In react used through useAppState(), 
 * but accessible here for any other use.
 */
const AppState = new AppStateStore()
export default AppState