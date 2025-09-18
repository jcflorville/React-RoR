import { createFileRoute } from "@tanstack/react-router"
import { PublicLayout } from "../components"

export const Route = createFileRoute("/about")({
	component: AboutPage,
})

function AboutPage() {
	return (
		<PublicLayout>
			<div className='max-w-4xl mx-auto space-y-8'>
				<h1 className='text-4xl font-bold text-gray-900 dark:text-white'>
					About React-RoR
				</h1>
				<p className='text-xl text-gray-600 dark:text-gray-300'>
					Building the future of web applications with React and Ruby on Rails.
				</p>
			</div>
		</PublicLayout>
	)
}
