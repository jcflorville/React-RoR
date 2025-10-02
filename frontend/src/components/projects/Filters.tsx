import { Select } from "flowbite-react"

interface FiltersProps {
	status: string
	priority: string
	sortBy: string
	onStatusChange: (status: string) => void
	onPriorityChange: (priority: string) => void
	onSortChange: (sortBy: string) => void
}

export function Filters({
	status,
	priority,
	sortBy,
	onStatusChange,
	onPriorityChange,
	onSortChange,
}: FiltersProps) {
	return (
		<div className='flex flex-col sm:flex-row gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg'>
			<div className='flex-1'>
				<label className='block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'>
					Status
				</label>
				<Select value={status} onChange={(e) => onStatusChange(e.target.value)}>
					<option value=''>All Status</option>
					<option value='draft'>Draft</option>
					<option value='active'>Active</option>
					<option value='completed'>Completed</option>
					<option value='archived'>Archived</option>
				</Select>
			</div>

			<div className='flex-1'>
				<label className='block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'>
					Priority
				</label>
				<Select
					value={priority}
					onChange={(e) => onPriorityChange(e.target.value)}
				>
					<option value=''>All Priorities</option>
					<option value='low'>Low</option>
					<option value='medium'>Medium</option>
					<option value='high'>High</option>
					<option value='urgent'>Urgent</option>
				</Select>
			</div>

			<div className='flex-1'>
				<label className='block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'>
					Sort by
				</label>
				<Select value={sortBy} onChange={(e) => onSortChange(e.target.value)}>
					<option value='created_at_desc'>Newest First</option>
					<option value='created_at_asc'>Oldest First</option>
					<option value='name_asc'>Name A-Z</option>
					<option value='name_desc'>Name Z-A</option>
					<option value='updated_at_desc'>Recently Updated</option>
					<option value='priority_desc'>High Priority</option>
				</Select>
			</div>
		</div>
	)
}
