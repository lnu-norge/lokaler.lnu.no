# AppState folder

App state is managed by `mobx` and `mobx-react-lite`

## How to use it

### In React Components

Import the [useAppState](./AppStateProvider.tsx) hook into your file, and use like this:

```jsx

import { useAppState } from './AppStateProvider'
import { observer } from 'mobx-react-lite'

const LogoutButton = observer(() => {
	const { login } = useAppState()

	return <>
		{ login.isLoggedIn ? "User is logged in" : "User is logged out" }
		<button onClick={() => login.logout()}>Log me out</button>
	</>
})

```

`useAppState` gives you access to the global state and all functions in it.

The global state is described by `AppState` exported from [AppState.ts](./AppState.ts)

`AppState` contains several _Stores_ defined in their own files. One such Store might be the login Store, defined in: [stores/LoginStore.ts](./stores/LoginStore.ts)

Both are described in more detail in the files mentioned above.

`observer()` is used around the Component to make it automatically react to state changes from anywhere in the app. It's only needed if the Component needs to react to state changes from somewhere else. Here it reacts to `login.isLoggedIn` which might change somewhere else, so therefore we have to add observer() around the Component. 

### Outside React Components

To manipulate state outside a React component (for example in a function), you can manipulate the AppState object exported from AppState.ts directly, by importing it. That will also update the state in React. 

For example like this dummy function:

```typescript

import AppState from './AppState'

const toggleLogin = () => {
	if (AppState.login.isLoggedIn) {
		return AppState.login.logout()
	}
	return AppState.login.login()
}	

```