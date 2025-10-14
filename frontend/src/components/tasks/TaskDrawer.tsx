import { Drawer, Button, Textarea, Select } from "flowbite-react"
import { useForm, Controller } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { taskSchema, type TaskFormData } from "@/lib/validations/task"
import type { Task } from "@/lib/api/types/task"
import { HiX } from "react-icons/hi"

interface TaskDrawerProps {
	isOpen: boolean
	onClose: () => void
	onSubmit: (data: TaskFormData) => void
	task?: Task | null
	isLoading?: boolean
}

export function TaskDrawer({
	isOpen,
	onClose,
	onSubmit,
	task,
	isLoading = false,
}: TaskDrawerProps) {
	const isEditMode = !!task

	// Format due_date to YYYY-MM-DD for input[type="date"]
	const formatDateForInput = (dateString: string | null) => {
		if (!dateString) return ""
		// Extract just the date part (YYYY-MM-DD) from ISO string
		return dateString.split("T")[0]
	}

	const {
		register,
		handleSubmit,
		control,
		formState: { errors },
		reset,
	} = useForm<TaskFormData>({
		resolver: zodResolver(taskSchema),
		defaultValues: {
			title: task?.title || "",
			description: task?.description || "",
			status: task?.status || "todo",
			priority: task?.priority || "medium",
			due_date: formatDateForInput(task?.due_date || null),
		},
	})

	const handleFormSubmit = (data: TaskFormData) => {
		onSubmit(data)
	}

	const handleClose = () => {
		reset()
		onClose()
	}

	return (
		<Drawer open={isOpen} onClose={handleClose} position='right'>
			<div className='p-6 space-y-6'>
				{/* Header */}
				<div className='flex items-center justify-between pb-4 border-b border-gray-200 dark:border-gray-700'>
					<h3 className='text-xl font-semibold text-gray-900 dark:text-white'>
						{isEditMode ? "Edit Task" : "New Task"}
					</h3>
					<button
						type='button'
						onClick={handleClose}
						className='text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 inline-flex items-center dark:hover:bg-gray-600 dark:hover:text-white'
					>
						<HiX className='w-5 h-5' />
						<span className='sr-only'>Close</span>
					</button>
				</div>

				{/* Form */}
				<form onSubmit={handleSubmit(handleFormSubmit)} className='space-y-6'>
					{/* Title */}
					<div>
						<label
							htmlFor='title'
							className='block mb-2 text-sm font-medium text-gray-900 dark:text-white'
						>
							Title
						</label>
						<input
							id='title'
							type='text'
							placeholder='Enter task title'
							{...register("title")}
							className='bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white'
						/>
						{errors.title && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.title.message}
							</p>
						)}
					</div>

					{/* Description */}
					<div>
						<label
							htmlFor='description'
							className='block mb-2 text-sm font-medium text-gray-900 dark:text-white'
						>
							Description
						</label>
						<Textarea
							id='description'
							placeholder='Enter task description'
							rows={4}
							{...register("description")}
							className='resize-none'
						/>
						{errors.description && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.description.message}
							</p>
						)}
					</div>

					{/* Status */}
					<div>
						<label
							htmlFor='status'
							className='block mb-2 text-sm font-medium text-gray-900 dark:text-white'
						>
							Status
						</label>
						<Controller
							name='status'
							control={control}
							render={({ field }) => (
								<Select id='status' {...field}>
									<option value='todo'>To Do</option>
									<option value='in_progress'>In Progress</option>
									<option value='completed'>Completed</option>
									<option value='blocked'>Blocked</option>
								</Select>
							)}
						/>
						{errors.status && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.status.message}
							</p>
						)}
					</div>

					{/* Priority */}
					<div>
						<label
							htmlFor='priority'
							className='block mb-2 text-sm font-medium text-gray-900 dark:text-white'
						>
							Priority
						</label>
						<Controller
							name='priority'
							control={control}
							render={({ field }) => (
								<Select id='priority' {...field}>
									<option value='low'>Low</option>
									<option value='medium'>Medium</option>
									<option value='high'>High</option>
									<option value='urgent'>Urgent</option>
								</Select>
							)}
						/>
						{errors.priority && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.priority.message}
							</p>
						)}
					</div>

					{/* Due Date */}
					<div>
						<label
							htmlFor='due_date'
							className='block mb-2 text-sm font-medium text-gray-900 dark:text-white'
						>
							Due Date
						</label>
						<input
							id='due_date'
							type='date'
							{...register("due_date")}
							className='bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white'
						/>
						{errors.due_date && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.due_date.message}
							</p>
						)}
					</div>

					{/* Actions */}
					<div className='flex gap-3 pt-4 border-t border-gray-200 dark:border-gray-700'>
						<Button
							type='submit'
							color='blue'
							className='flex-1'
							disabled={isLoading}
						>
							{isEditMode ? "Update Task" : "Create Task"}
						</Button>
						<Button
							type='button'
							color='gray'
							onClick={handleClose}
							disabled={isLoading}
						>
							Cancel
						</Button>
					</div>
				</form>
			</div>
		</Drawer>
	)
}
