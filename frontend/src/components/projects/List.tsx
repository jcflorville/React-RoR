import { Card, type Project } from "./Card"

interface ListProps {
	projects: Project[]
	loading?: boolean
	onViewProject?: (project: Project) => void
	onEditProject?: (project: Project) => void
	onDeleteProject?: (project: Project) => void
}

export function List({
	projects,
	loading = false,
	onViewProject,
	onEditProject,
	onDeleteProject,
}: ListProps) {
	if (loading) {
		return (
			<div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6'>
				{/* Loading Skeletons */}
				{Array.from({ length: 8 }).map((_, index) => (
					<div
						key={index}
						className='bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm animate-pulse'
					>
						<div className='flex items-start justify-between mb-3'>
							<div className='h-6 bg-gray-200 dark:bg-gray-700 rounded w-3/4'></div>
							<div className='flex gap-2'>
								<div className='h-5 bg-gray-200 dark:bg-gray-700 rounded w-12'></div>
								<div className='h-5 bg-gray-200 dark:bg-gray-700 rounded w-12'></div>
							</div>
						</div>
						<div className='space-y-2 mb-4'>
							<div className='h-4 bg-gray-200 dark:bg-gray-700 rounded'></div>
							<div className='h-4 bg-gray-200 dark:bg-gray-700 rounded w-5/6'></div>
							<div className='h-4 bg-gray-200 dark:bg-gray-700 rounded w-4/6'></div>
						</div>
						<div className='flex gap-2 pt-3 border-t border-gray-200 dark:border-gray-700'>
							<div className='h-8 bg-gray-200 dark:bg-gray-700 rounded flex-1'></div>
							<div className='h-8 bg-gray-200 dark:bg-gray-700 rounded flex-1'></div>
							<div className='h-8 bg-gray-200 dark:bg-gray-700 rounded flex-1'></div>
						</div>
					</div>
				))}
			</div>
		)
	}

	if (projects.length === 0) {
		return (
			<div className='text-center py-12'>
				<div className='text-gray-400 dark:text-gray-500 text-6xl mb-4'>📁</div>
				<h3 className='text-lg font-medium text-gray-900 dark:text-white mb-2'>
					No projects found
				</h3>
				<p className='text-gray-600 dark:text-gray-400 mb-6'>
					Get started by creating your first project
				</p>
			</div>
		)
	}

	return (
		<div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6'>
			{projects.map((project) => (
				<Card
					key={project.id}
					project={project}
					onView={onViewProject}
					onEdit={onEditProject}
					onDelete={onDeleteProject}
				/>
			))}
		</div>
	)
}
