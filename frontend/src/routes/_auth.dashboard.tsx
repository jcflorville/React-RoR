import { createFileRoute } from "@tanstack/react-router"
import { DashboardLayout } from "@components/layouts/DashboardLayout"
import { Card } from "flowbite-react"

export const Route = createFileRoute("/_auth/dashboard")({
	component: DashboardPage,
})

function DashboardPage() {
	return (
		<DashboardLayout>
			<div className='space-y-6'>
				{/* Welcome Section */}
				<div className='bg-gradient-to-r from-cyan-500 to-blue-600 rounded-lg p-6 text-white'>
					<h1 className='text-3xl font-bold mb-2'>Welcome back, João!</h1>
					<p className='text-cyan-100'>
						Here's what's happening with your account today.
					</p>
				</div>

				{/* Stats Cards */}
				<div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6'>
					<Card>
						<div className='flex items-center'>
							<div className='p-3 bg-cyan-100 rounded-full'>
								<svg
									className='w-6 h-6 text-cyan-600'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path d='M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z' />
								</svg>
							</div>
							<div className='ml-4'>
								<p className='text-sm font-medium text-gray-600 dark:text-gray-400'>
									Total Projects
								</p>
								<p className='text-2xl font-bold text-gray-900 dark:text-white'>
									12
								</p>
							</div>
						</div>
					</Card>

					<Card>
						<div className='flex items-center'>
							<div className='p-3 bg-green-100 rounded-full'>
								<svg
									className='w-6 h-6 text-green-600'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path
										fillRule='evenodd'
										d='M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z'
										clipRule='evenodd'
									/>
								</svg>
							</div>
							<div className='ml-4'>
								<p className='text-sm font-medium text-gray-600 dark:text-gray-400'>
									Completed
								</p>
								<p className='text-2xl font-bold text-gray-900 dark:text-white'>
									8
								</p>
							</div>
						</div>
					</Card>

					<Card>
						<div className='flex items-center'>
							<div className='p-3 bg-yellow-100 rounded-full'>
								<svg
									className='w-6 h-6 text-yellow-600'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path
										fillRule='evenodd'
										d='M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z'
										clipRule='evenodd'
									/>
								</svg>
							</div>
							<div className='ml-4'>
								<p className='text-sm font-medium text-gray-600 dark:text-gray-400'>
									In Progress
								</p>
								<p className='text-2xl font-bold text-gray-900 dark:text-white'>
									3
								</p>
							</div>
						</div>
					</Card>

					<Card>
						<div className='flex items-center'>
							<div className='p-3 bg-red-100 rounded-full'>
								<svg
									className='w-6 h-6 text-red-600'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path
										fillRule='evenodd'
										d='M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z'
										clipRule='evenodd'
									/>
								</svg>
							</div>
							<div className='ml-4'>
								<p className='text-sm font-medium text-gray-600 dark:text-gray-400'>
									Issues
								</p>
								<p className='text-2xl font-bold text-gray-900 dark:text-white'>
									1
								</p>
							</div>
						</div>
					</Card>
				</div>

				{/* Recent Activity */}
				<div className='grid grid-cols-1 lg:grid-cols-2 gap-6'>
					<Card>
						<h3 className='text-lg font-semibold text-gray-900 dark:text-white mb-4'>
							Recent Projects
						</h3>
						<div className='space-y-3'>
							{[
								{
									name: "E-commerce Platform",
									status: "In Progress",
									color: "yellow",
								},
								{
									name: "Mobile App Design",
									status: "Completed",
									color: "green",
								},
								{
									name: "Website Redesign",
									status: "In Progress",
									color: "yellow",
								},
								{
									name: "API Integration",
									status: "Completed",
									color: "green",
								},
							].map((project, index) => (
								<div
									key={index}
									className='flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg'
								>
									<div>
										<p className='font-medium text-gray-900 dark:text-white'>
											{project.name}
										</p>
										<p className={`text-sm text-${project.color}-600`}>
											{project.status}
										</p>
									</div>
									<svg
										className='w-5 h-5 text-gray-400'
										fill='currentColor'
										viewBox='0 0 20 20'
									>
										<path
											fillRule='evenodd'
											d='M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z'
											clipRule='evenodd'
										/>
									</svg>
								</div>
							))}
						</div>
					</Card>

					<Card>
						<h3 className='text-lg font-semibold text-gray-900 dark:text-white mb-4'>
							Quick Actions
						</h3>
						<div className='space-y-3'>
							<button className='w-full flex items-center p-3 bg-cyan-50 dark:bg-cyan-900 text-cyan-700 dark:text-cyan-300 rounded-lg hover:bg-cyan-100 dark:hover:bg-cyan-800 transition-colors'>
								<svg
									className='w-5 h-5 mr-3'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path
										fillRule='evenodd'
										d='M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z'
										clipRule='evenodd'
									/>
								</svg>
								Create New Project
							</button>

							<button className='w-full flex items-center p-3 bg-green-50 dark:bg-green-900 text-green-700 dark:text-green-300 rounded-lg hover:bg-green-100 dark:hover:bg-green-800 transition-colors'>
								<svg
									className='w-5 h-5 mr-3'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path d='M9 2a1 1 0 000 2h2a1 1 0 100-2H9z' />
									<path
										fillRule='evenodd'
										d='M4 5a2 2 0 012-2v1a2 2 0 002 2h6a2 2 0 002-2V3a2 2 0 012 2v6.586A1 1 0 0117.414 13L13 17.414A1 1 0 0111.586 17H5a2 2 0 01-2-2V5zm8 8v2h2l-2-2z'
										clipRule='evenodd'
									/>
								</svg>
								Generate Report
							</button>

							<button className='w-full flex items-center p-3 bg-purple-50 dark:bg-purple-900 text-purple-700 dark:text-purple-300 rounded-lg hover:bg-purple-100 dark:hover:bg-purple-800 transition-colors'>
								<svg
									className='w-5 h-5 mr-3'
									fill='currentColor'
									viewBox='0 0 20 20'
								>
									<path d='M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z' />
								</svg>
								Invite Team Member
							</button>
						</div>
					</Card>
				</div>
			</div>
		</DashboardLayout>
	)
}
