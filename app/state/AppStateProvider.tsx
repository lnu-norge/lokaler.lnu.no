import { createContext, useContext } from "react"
import AppState, { AppStateStore } from "./AppState"


const AppStateContext = createContext<AppStateStore>(AppState)

/** Gives access to the entire app state, and autoupdates 
 * that information through mobx. 
 * 
 * Depends on AppStateProvider being somewhere up the tree
 * for the context to know what to refer to.
 */
export const useAppState = () => {
	return useContext(AppStateContext)
}

/** 
 * Needs to be wrapped around the base component 
 * of the app to give access to the AppStateContext 
 * through useAppState
 */
const AppStateProvider = ({ children }: any) => {
	const store = AppState

	return (
		<AppStateContext.Provider value={store}>
			{children}
		</AppStateContext.Provider>
	)
}

export default AppStateProvider
