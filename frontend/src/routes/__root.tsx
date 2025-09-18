import { createRootRoute, Outlet } from "@tanstack/react-router"
import { TanStackRouterDevtools } from "@tanstack/react-router-devtools"

// import appCss from "../styles/app.css?url"

const RootLayout = () => (
	<>
		<Outlet />
		<TanStackRouterDevtools />
	</>
)

export const Route = createRootRoute({
	head: () => ({
		meta: [
			// your meta tags and site config
		],
		// links: [{ rel: "stylesheet", href: appCss }],
		// other head config
	}),
	component: RootLayout,
})
