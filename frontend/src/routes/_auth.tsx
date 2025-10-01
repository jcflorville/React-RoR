import { createFileRoute } from "@tanstack/react-router"
import { redirect } from "@tanstack/react-router"

export const Route = createFileRoute("/_auth")({
	beforeLoad: ({ context }) => {
		const { isAuthenticated, isLoading } = context.auth
		if (!isLoading && !isAuthenticated) {
			throw redirect({
				to: "/sign-in",
				search: {
					redirect: "/dashboard",
				},
			})
		}
	},
})
