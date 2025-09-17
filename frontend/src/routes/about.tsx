import { createFileRoute } from "@tanstack/react-router"

export const Route = createFileRoute("/about")({
	component: About,
})

function About() {
	return <div className='p-2 text-4xl'>Hello from About!</div>
}
