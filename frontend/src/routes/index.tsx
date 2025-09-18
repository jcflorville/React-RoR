import { createFileRoute } from "@tanstack/react-router"
import { Button } from "flowbite-react"
import { PublicLayout } from "../components"

export const Route = createFileRoute("/")({
	component: HomePage,
})

function HomePage() {
	return (
		<PublicLayout>
			<div className='text-center space-y-8'>
				<div className='space-y-4'>
					<h1 className='text-4xl lg:text-6xl font-bold text-gray-900 dark:text-white'>
						Welcome to <span className='text-cyan-600'>React-RoR</span>
					</h1>
					<p className='text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto'>
						A modern full-stack application built with React, Ruby on Rails,
						Tailwind CSS, and Flowbite components.
					</p>
				</div>

				<div className='flex flex-col sm:flex-row gap-4 justify-center'>
					<Button size='lg' className='bg-cyan-700 hover:bg-cyan-800'>
						Get Started
					</Button>
					<Button size='lg' color='gray' outline>
						Learn More
					</Button>
				</div>

				<div className='grid grid-cols-1 md:grid-cols-3 gap-8 mt-16'>
					<div className='text-center space-y-4'>
						<div className='bg-cyan-100 dark:bg-cyan-900 w-16 h-16 rounded-full flex items-center justify-center mx-auto'>
							<svg
								className='w-8 h-8 text-cyan-600'
								fill='none'
								stroke='currentColor'
								viewBox='0 0 24 24'
							>
								<path
									strokeLinecap='round'
									strokeLinejoin='round'
									strokeWidth={2}
									d='M13 10V3L4 14h7v7l9-11h-7z'
								/>
							</svg>
						</div>
						<h3 className='text-xl font-semibold text-gray-900 dark:text-white'>
							Fast
						</h3>
						<p className='text-gray-600 dark:text-gray-300'>
							Built with modern technologies for optimal performance
						</p>
					</div>

					<div className='text-center space-y-4'>
						<div className='bg-cyan-100 dark:bg-cyan-900 w-16 h-16 rounded-full flex items-center justify-center mx-auto'>
							<svg
								className='w-8 h-8 text-cyan-600'
								fill='none'
								stroke='currentColor'
								viewBox='0 0 24 24'
							>
								<path
									strokeLinecap='round'
									strokeLinejoin='round'
									strokeWidth={2}
									d='M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z'
								/>
							</svg>
						</div>
						<h3 className='text-xl font-semibold text-gray-900 dark:text-white'>
							Secure
						</h3>
						<p className='text-gray-600 dark:text-gray-300'>
							Enterprise-grade security built into every component
						</p>
					</div>

					<div className='text-center space-y-4'>
						<div className='bg-cyan-100 dark:bg-cyan-900 w-16 h-16 rounded-full flex items-center justify-center mx-auto'>
							<svg
								className='w-8 h-8 text-cyan-600'
								fill='none'
								stroke='currentColor'
								viewBox='0 0 24 24'
							>
								<path
									strokeLinecap='round'
									strokeLinejoin='round'
									strokeWidth={2}
									d='M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z'
								/>
							</svg>
						</div>
						<h3 className='text-xl font-semibold text-gray-900 dark:text-white'>
							Scalable
						</h3>
						<p className='text-gray-600 dark:text-gray-300'>
							Designed to grow with your business needs
						</p>
					</div>
				</div>
			</div>
		</PublicLayout>
	)
}
