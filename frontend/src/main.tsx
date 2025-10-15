import { StrictMode } from "react"
import ReactDOM from "react-dom/client"
import { RouterProvider, createRouter } from "@tanstack/react-router"
import { ThemeProvider } from "flowbite-react"
import { Toaster } from "react-hot-toast"
import { AppProviders } from "./providers/app-providers"
import { useAuthStore } from "@stores/auth-store"
import { LoadingScreen } from "@components/LoadingScreen"
import type { RouterContext } from "@/types/router"

import "./styles.css"
// Import the generated route tree
import { routeTree } from "./routeTree.gen"

// Create a new router instance
const router = createRouter({
	routeTree,
	context: undefined!,
	scrollRestoration: true,
})

// Register the router instance for type safety
declare module "@tanstack/react-router" {
	interface Register {
		router: typeof router
	}
}

// ✅ Componente App dentro do main.tsx
function App() {
	const { user, isAuthenticated, isLoading, isHydrated } = useAuthStore()

	// ✅ Só mostra conteúdo quando estiver hidratado
	if (!isHydrated || isLoading) {
		return <LoadingScreen />
	}

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
				<Toaster
					position='top-right'
					toastOptions={{
						duration: 4000,
						style: {
							background: "#333",
							color: "#fff",
						},
						success: {
							iconTheme: {
								primary: "#10b981",
								secondary: "#fff",
							},
						},
						error: {
							iconTheme: {
								primary: "#ef4444",
								secondary: "#fff",
							},
						},
					}}
				/>
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
