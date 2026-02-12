import { createFileRoute, Outlet } from "@tanstack/react-router"

export const Route = createFileRoute("/_auth/dada")({
	component: DadaLayout,
})

function DadaLayout() {
	return (
		<div className='container mx-auto py-8'>
			<Outlet />
		</div>
	)
}
