import { Badge } from "flowbite-react"
import type { Task } from "@/lib/api/types/task"
import {
	HiOutlineDotsVertical,
	HiOutlinePencil,
	HiOutlineTrash,
	HiOutlineCheck,
	HiOutlineRefresh,
	HiOutlineClock,
	HiOutlineExclamation,
} from "react-icons/hi"
import { useState, useRef, useEffect } from "react"

interface TaskCardProps {
	task: Task
	onEdit: (task: Task) => void
	onDelete: (task: Task) => void
	onComplete?: (task: Task) => void
	onReopen?: (task: Task) => void
}

export function TaskCard({
	task,
	onEdit,
	onDelete,
	onComplete,
	onReopen,
}: TaskCardProps) {
	const getStatusColor = (status: string) => {
		switch (status) {
			case "todo":
				return "gray"
			case "in_progress":
				return "info"
			case "completed":
				return "success"
			case "blocked":
				return "failure"
			default:
				return "gray"
		}
	}

	const getPriorityColor = (priority: string) => {
		switch (priority) {
			case "urgent":
				return "failure"
			case "high":
				return "warning"
			case "medium":
				return "info"
			case "low":
				return "gray"
			default:
				return "gray"
		}
	}

	const formatDate = (dateString: string) => {
		const date = new Date(dateString)
		return date.toLocaleDateString("en-US", {
			month: "short",
			day: "numeric",
			year: "numeric",
		})
	}

	const isCompleted = task.status === "completed"
	const showCompleteButton = !isCompleted && task.status !== "blocked"
	const showReopenButton = isCompleted
	const [isMenuOpen, setIsMenuOpen] = useState(false)
	const menuRef = useRef<HTMLDivElement>(null)

	// Close menu when clicking outside
	useEffect(() => {
		const handleClickOutside = (event: MouseEvent) => {
			if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
				setIsMenuOpen(false)
			}
		}

		if (isMenuOpen) {
			document.addEventListener("mousedown", handleClickOutside)
		}

		return () => {
			document.removeEventListener("mousedown", handleClickOutside)
		}
	}, [isMenuOpen])

	return (
		<div className='bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:shadow-md transition-shadow'>
			{/* Header */}
			<div className='flex items-start justify-between gap-3 mb-3'>
				<div className='flex-1 min-w-0'>
					<h3
						className={`text-base font-semibold text-gray-900 dark:text-white mb-2 ${
							isCompleted ? "line-through opacity-60" : ""
						}`}
					>
						{task.title}
					</h3>
					<div className='flex items-center gap-2 flex-wrap'>
						<Badge color={getStatusColor(task.status)} size='sm'>
							{task.status.replace("_", " ")}
						</Badge>
						<Badge color={getPriorityColor(task.priority)} size='sm'>
							{task.priority}
						</Badge>
					</div>
				</div>

				{/* Actions Menu */}
				<div className='relative' ref={menuRef}>
					<button
						type='button'
						onClick={() => setIsMenuOpen(!isMenuOpen)}
						className='text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 p-1'
					>
						<HiOutlineDotsVertical className='w-5 h-5' />
					</button>

					{/* Dropdown Menu */}
					{isMenuOpen && (
						<div className='absolute right-0 mt-2 w-48 bg-white dark:bg-gray-700 rounded-lg shadow-lg border border-gray-200 dark:border-gray-600 z-10'>
							<button
								onClick={() => {
									onEdit(task)
									setIsMenuOpen(false)
								}}
								className='w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-600 rounded-t-lg'
							>
								<HiOutlinePencil className='w-4 h-4' />
								Edit
							</button>
							{showCompleteButton && onComplete && (
								<button
									onClick={() => {
										onComplete(task)
										setIsMenuOpen(false)
									}}
									className='w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-600'
								>
									<HiOutlineCheck className='w-4 h-4' />
									Mark as Complete
								</button>
							)}
							{showReopenButton && onReopen && (
								<button
									onClick={() => {
										onReopen(task)
										setIsMenuOpen(false)
									}}
									className='w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-600'
								>
									<HiOutlineRefresh className='w-4 h-4' />
									Reopen
								</button>
							)}
							<div className='border-t border-gray-200 dark:border-gray-600' />
							<button
								onClick={() => {
									onDelete(task)
									setIsMenuOpen(false)
								}}
								className='w-full flex items-center gap-2 px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-gray-100 dark:hover:bg-gray-600 rounded-b-lg'
							>
								<HiOutlineTrash className='w-4 h-4' />
								Delete
							</button>
						</div>
					)}
				</div>
			</div>

			{/* Description */}
			{task.description && (
				<p className='text-sm text-gray-600 dark:text-gray-400 mb-3 line-clamp-2'>
					{task.description}
				</p>
			)}

			{/* Footer */}
			<div className='flex items-center justify-between text-xs text-gray-500 dark:text-gray-400'>
				{/* Due Date */}
				{task.due_date && (
					<div className='flex items-center gap-1'>
						{task.overdue ? (
							<>
								<HiOutlineExclamation className='w-4 h-4 text-red-500' />
								<span className='text-red-500 font-medium'>
									Overdue: {formatDate(task.due_date)}
								</span>
							</>
						) : (
							<>
								<HiOutlineClock className='w-4 h-4' />
								<span>Due: {formatDate(task.due_date)}</span>
							</>
						)}
					</div>
				)}

				{/* Days Until Due */}
				{task.days_until_due !== null && !task.overdue && (
					<span className='text-xs'>
						{task.days_until_due === 0
							? "Due today"
							: `${task.days_until_due} days left`}
					</span>
				)}
			</div>
		</div>
	)
}
