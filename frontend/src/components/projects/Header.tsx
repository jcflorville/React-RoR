import { Button, TextInput } from "flowbite-react"

interface HeaderProps {
	searchTerm: string
	onSearchChange: (value: string) => void
	onCreateProject: () => void
}

export function Header({
	searchTerm,
	onSearchChange,
	onCreateProject,
}: HeaderProps) {
	return (
		<div className='space-y-4 sm:space-y-0 sm:flex sm:items-center sm:justify-between'>
			{/* Title Section */}
			<div>
				<h1 className='text-2xl font-bold text-gray-900 dark:text-white'>
					Projects
				</h1>
				<p className='text-sm text-gray-500 dark:text-gray-400 mt-1'>
					Manage and track your projects
				</p>
			</div>

			{/* Actions Section */}
			<div className='flex flex-col sm:flex-row gap-3 sm:items-center'>
				{/* Search Input */}
				<div className='relative'>
					<TextInput
						type='text'
						placeholder='Search projects...'
						value={searchTerm}
						onChange={(e) => onSearchChange(e.target.value)}
						className='w-full sm:w-64'
					/>
				</div>

				{/* Create Button */}
				<Button
					onClick={onCreateProject}
					className='whitespace-nowrap'
					size='sm'
				>
					+ New Project
				</Button>
			</div>
		</div>
	)
}
