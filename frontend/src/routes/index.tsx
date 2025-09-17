import { createFileRoute } from "@tanstack/react-router"
import { Button } from "flowbite-react"

export const Route = createFileRoute("/")({
	component: App,
})

function App() {
	return (
		<>
			<h1 className='text-3xl font-bold underline'>Hello world!</h1>
			<Button>Default</Button>
			<Button color='red'>Alternative</Button>
		</>
	)
}
