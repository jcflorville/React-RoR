import { createRootRoute, Link, Outlet } from "@tanstack/react-router"
import { TanStackRouterDevtools } from "@tanstack/react-router-devtools"

import appCss from "../styles/app.css?url"

const RootLayout = () => (
	<>
		<div className='p-2 flex gap-2'>
			<Link to='/' className='[&.active]:font-bold'>
				Home
			</Link>{" "}
			<Link to='/about' className='[&.active]:font-bold'>
				About
			</Link>
		</div>
		<hr />
		<Outlet />
		<TanStackRouterDevtools />
	</>
)

export const Route = createRootRoute({
	head: () => ({
		meta: [
			// your meta tags and site config
		],
		links: [{ rel: "stylesheet", href: appCss }],
		// other head config
	}),
	component: RootLayout,
})
