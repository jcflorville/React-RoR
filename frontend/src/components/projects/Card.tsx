import { Card as FlowbiteCard, Badge, Button } from "flowbite-react"
import { type Project } from "@/lib/api/types/project"

// Re-export para compatibilidade
export type { Project }

interface CardProps {
	project: Project
	onView?: (project: Project) => void
	onEdit?: (project: Project) => void
	onDelete?: (project: Project) => void
}

const statusConfig = {
	draft: { color: "gray", text: "Draft" },
	active: { color: "blue", text: "Active" },
	completed: { color: "green", text: "Completed" },
	archived: { color: "dark", text: "Archived" },
} as const

const priorityConfig = {
	low: { color: "gray", text: "Low" },
	medium: { color: "yellow", text: "Medium" },
	high: { color: "red", text: "High" },
	urgent: { color: "red", text: "Urgent" },
} as const

export function Card({ project, onView, onEdit, onDelete }: CardProps) {
	const formatDate = (dateString: string) => {
		return new Date(dateString).toLocaleDateString("en-US", {
			month: "short",
			day: "numeric",
			year: "numeric",
		})
	}

	const truncateText = (text: string, maxLength: number = 100) => {
		return text.length > maxLength ? `${text.substring(0, maxLength)}...` : text
	}

	return (
		<FlowbiteCard className='h-full hover:shadow-lg transition-shadow duration-200'>
			{/* Header */}
			<div className='flex items-start justify-between mb-3'>
				<h3 className='text-lg font-semibold text-gray-900 dark:text-white truncate pr-2'>
					{project.name}
				</h3>
				<div className='flex gap-2 flex-shrink-0'>
					<Badge color={statusConfig[project.status].color} size='sm'>
						{statusConfig[project.status].text}
					</Badge>
					<Badge color={priorityConfig[project.priority].color} size='sm'>
						{priorityConfig[project.priority].text}
					</Badge>
				</div>
			</div>

			{/* Description */}
			{project.description && (
				<p className='text-sm text-gray-600 dark:text-gray-400 mb-4 leading-relaxed'>
					{truncateText(project.description)}
				</p>
			)}

			{/* Dates */}
			<div className='space-y-2 mb-4 text-xs text-gray-500 dark:text-gray-400'>
				{project.start_date && (
					<div className='flex justify-between'>
						<span>Started:</span>
						<span>{formatDate(project.start_date)}</span>
					</div>
				)}
				{project.end_date && (
					<div className='flex justify-between'>
						<span>Due:</span>
						<span>{formatDate(project.end_date)}</span>
					</div>
				)}
				<div className='flex justify-between'>
					<span>Created:</span>
					<span>{formatDate(project.created_at)}</span>
				</div>
			</div>

			{/* Actions */}
			<div className='flex gap-2 mt-auto pt-3 border-t border-gray-200 dark:border-gray-700'>
				{onView && (
					<Button
						size='xs'
						color='light'
						onClick={() => onView(project)}
						className='flex-1'
					>
						View
					</Button>
				)}
				{onEdit && (
					<Button
						size='xs'
						color='gray'
						onClick={() => onEdit(project)}
						className='flex-1'
					>
						Edit
					</Button>
				)}
				{onDelete && (
					<Button
						size='xs'
						color='red'
						onClick={() => onDelete(project)}
						className='flex-1'
					>
						Delete
					</Button>
				)}
			</div>
		</FlowbiteCard>
	)
}
