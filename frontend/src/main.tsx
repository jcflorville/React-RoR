import { StrictMode } from "react"
import ReactDOM from "react-dom/client"
import { RouterProvider, createRouter } from "@tanstack/react-router"
import { ThemeProvider } from "flowbite-react"
import { AppProviders } from "./providers/app-providers"
import { useAuthStore } from "@stores/auth-store"
import type { RouterContext } from "@/types/router"

import "./styles.css"
// Import the generated route tree
import { routeTree } from "./routeTree.gen"

// Create a new router instance
const router = createRouter({
	routeTree,
	context: undefined!,
})

// Register the router instance for type safety
declare module "@tanstack/react-router" {
	interface Register {
		router: typeof router
	}
}

// ✅ Componente App dentro do main.tsx
function App() {
	const { user, isAuthenticated, isLoading } = useAuthStore()

	const routerContext: RouterContext = {
		auth: {
			user,
			isAuthenticated,
			isLoading,
		},
	}

	return (
		<AppProviders>
			<ThemeProvider>
				<RouterProvider router={router} context={routerContext} />
			</ThemeProvider>
		</AppProviders>
	)
}

// Render the app
const rootElement = document.getElementById("root")!
if (!rootElement.innerHTML) {
	const root = ReactDOM.createRoot(rootElement)
	root.render(
		<StrictMode>
			<App />
		</StrictMode>
	)
}
