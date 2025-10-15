import { createFileRoute, useNavigate, useRouter } from "@tanstack/react-router"
import { DashboardLayout } from "@components/layouts/DashboardLayout"
import { useState } from "react"
import { useProject } from "@/hooks/queries/projects-queries"
import {
	useProjectTasks,
	useCreateTask,
	useUpdateTask,
	useDeleteTask,
	useCompleteTask,
	useReopenTask,
} from "@/hooks/queries/tasks-queries"
import { FormModal } from "@/components/projects/modals/FormModal"
import { TaskDrawer } from "@/components/tasks/TaskDrawer"
import { TasksList } from "@/components/tasks/TasksList"
import { Spinner, Button, Badge } from "flowbite-react"
import {
	HiOutlinePencil,
	HiOutlineArrowLeft,
	HiOutlinePlus,
} from "react-icons/hi"
import type { Task } from "@/lib/api/types/task"
import type { TaskFormData } from "@/lib/validations/task"

export const Route = createFileRoute("/_auth/projects/$id/edit")({
	component: ProjectEditPage,
})

function ProjectEditPage() {
	const { id } = Route.useParams()
	const navigate = useNavigate()
	const router = useRouter()
	const projectId = Number(id)

	// Project states
	const [isEditModalOpen, setIsEditModalOpen] = useState(false)

	// Task states
	const [isTaskDrawerOpen, setIsTaskDrawerOpen] = useState(false)
	const [selectedTask, setSelectedTask] = useState<Task | null>(null)
	const [drawerKey, setDrawerKey] = useState(0)

	// Fetch project data with tasks and categories
	const { data: projectResponse, isLoading, error } = useProject(projectId)
	const project = projectResponse?.data

	// Fetch tasks for this project
	const { data: tasksResponse, isLoading: tasksLoading } =
		useProjectTasks(projectId)
	const tasks = tasksResponse?.data || []

	// Task mutations
	const createTaskMutation = useCreateTask(projectId)
	const updateTaskMutation = useUpdateTask(projectId)
	const deleteTaskMutation = useDeleteTask(projectId)
	const completeTaskMutation = useCompleteTask(projectId)
	const reopenTaskMutation = useReopenTask(projectId)

	// Task handlers
	const handleAddTask = () => {
		setSelectedTask(null)
		setDrawerKey((prev) => prev + 1) // Force remount
		setIsTaskDrawerOpen(true)
	}

	const handleEditTask = (task: Task) => {
		setSelectedTask(task)
		setDrawerKey((prev) => prev + 1) // Force remount
		setIsTaskDrawerOpen(true)
	}

	const handleCloseTaskDrawer = () => {
		setIsTaskDrawerOpen(false)
		setSelectedTask(null)
	}

	const handleSubmitTask = async (data: TaskFormData) => {
		try {
			if (selectedTask) {
				// Update existing task
				await updateTaskMutation.mutateAsync({
					taskId: selectedTask.id,
					data,
				})
			} else {
				// Create new task
				await createTaskMutation.mutateAsync(data)
			}
			handleCloseTaskDrawer()
		} catch (error) {
			console.error("Error submitting task:", error)
		}
	}

	const handleDeleteTask = async (task: Task) => {
		if (window.confirm(`Are you sure you want to delete "${task.title}"?`)) {
			try {
				await deleteTaskMutation.mutateAsync(task.id)
			} catch (error) {
				console.error("Error deleting task:", error)
			}
		}
	}

	const handleCompleteTask = async (task: Task) => {
		try {
			await completeTaskMutation.mutateAsync(task.id)
		} catch (error) {
			console.error("Error completing task:", error)
		}
	}

	const handleReopenTask = async (task: Task) => {
		try {
			await reopenTaskMutation.mutateAsync(task.id)
		} catch (error) {
			console.error("Error reopening task:", error)
		}
	}

	if (isLoading) {
		return (
			<DashboardLayout>
				<div className='flex items-center justify-center min-h-[400px]'>
					<Spinner size='xl' />
					<span className='ml-3 text-lg text-gray-900 dark:text-white'>
						Loading project...
					</span>
				</div>
			</DashboardLayout>
		)
	}

	if (error || !project) {
		return (
			<DashboardLayout>
				<div className='text-center py-12'>
					<h3 className='text-lg font-medium text-red-600 dark:text-red-400 mb-2'>
						Error loading project
					</h3>
					<p className='text-gray-600 dark:text-gray-400 mb-4'>
						{error instanceof Error ? error.message : "Project not found"}
					</p>
					<Button onClick={() => navigate({ to: "/projects" })}>
						Back to Projects
					</Button>
				</div>
			</DashboardLayout>
		)
	}

	const getStatusColor = (status: string) => {
		switch (status) {
			case "active":
				return "info"
			case "completed":
				return "success"
			case "draft":
				return "warning"
			case "archived":
				return "gray"
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

	return (
		<DashboardLayout>
			<div className='max-w-7xl mx-auto space-y-6'>
				{/* Header */}
				<div className='flex items-center justify-between'>
					<div className='flex items-center gap-4'>
						<Button
							color='gray'
							size='sm'
							onClick={() => router.history.back()}
						>
							<HiOutlineArrowLeft className='mr-2 h-4 w-4' />
							Back
						</Button>
						<div>
							<h1 className='text-2xl font-bold text-gray-900 dark:text-white'>
								{project.name}
							</h1>
							<p className='text-sm text-gray-500 dark:text-gray-400 mt-1'>
								Manage project details and tasks
							</p>
						</div>
					</div>
					<Button size='sm' onClick={() => setIsEditModalOpen(true)}>
						<HiOutlinePencil className='mr-2 h-4 w-4' />
						Edit Project
					</Button>
				</div>

				{/* Overview Section */}
				<div className='bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm border border-gray-200 dark:border-gray-700'>
					<h2 className='text-lg font-semibold text-gray-900 dark:text-white mb-6'>
						Project Details
					</h2>

					<div className='grid grid-cols-1 md:grid-cols-2 gap-6'>
						{/* Name */}
						<div>
							<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
								Project Name
							</label>
							<p className='text-base text-gray-900 dark:text-white'>
								{project.name}
							</p>
						</div>

						{/* Status */}
						<div>
							<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
								Status
							</label>
							<Badge color={getStatusColor(project.status)}>
								{project.status_humanized || project.status}
							</Badge>
						</div>

						{/* Description */}
						{project.description && (
							<div className='md:col-span-2'>
								<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
									Description
								</label>
								<p className='text-base text-gray-900 dark:text-white whitespace-pre-wrap'>
									{project.description}
								</p>
							</div>
						)}

						{/* Priority */}
						<div>
							<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
								Priority
							</label>
							<Badge color={getPriorityColor(project.priority)}>
								{project.priority_humanized || project.priority}
							</Badge>
						</div>

						{/* Progress */}
						<div>
							<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
								Progress
							</label>
							<p className='text-base text-gray-900 dark:text-white'>
								{project.progress_percentage}%
							</p>
						</div>

						{/* Start Date */}
						{project.start_date && (
							<div>
								<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
									Start Date
								</label>
								<p className='text-base text-gray-900 dark:text-white'>
									{new Date(project.start_date).toLocaleDateString()}
								</p>
							</div>
						)}

						{/* End Date */}
						{project.end_date && (
							<div>
								<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
									End Date
								</label>
								<p className='text-base text-gray-900 dark:text-white'>
									{new Date(project.end_date).toLocaleDateString()}
								</p>
							</div>
						)}

						{/* Categories */}
						{project.categories && project.categories.length > 0 && (
							<div className='md:col-span-2'>
								<label className='block text-sm font-medium text-gray-600 dark:text-gray-300 mb-2'>
									Categories
								</label>
								<div className='flex flex-wrap gap-2'>
									{project.categories.map((category) => (
										<span
											key={category.id}
											className='inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium'
											style={{
												backgroundColor: category.color + "20",
												color: category.color,
											}}
										>
											{category.name}
										</span>
									))}
								</div>
							</div>
						)}
					</div>
				</div>

				{/* Tasks Section */}
				<div className='bg-white dark:bg-gray-800 rounded-lg p-6 shadow-sm border border-gray-200 dark:border-gray-700'>
					<div className='flex items-center justify-between mb-6'>
						<h2 className='text-lg font-semibold text-gray-900 dark:text-white'>
							Tasks
						</h2>
						<Button size='sm' color='blue' onClick={handleAddTask}>
							<HiOutlinePlus className='mr-2 h-4 w-4' />
							Add Task
						</Button>
					</div>

					{/* Tasks List */}
					<TasksList
						tasks={tasks}
						isLoading={tasksLoading}
						onAddTask={handleAddTask}
						onEditTask={handleEditTask}
						onDeleteTask={handleDeleteTask}
						onCompleteTask={handleCompleteTask}
						onReopenTask={handleReopenTask}
					/>
				</div>
			</div>

			{/* Edit Project Modal */}
			<FormModal
				mode='edit'
				isOpen={isEditModalOpen}
				onClose={() => setIsEditModalOpen(false)}
				project={project}
			/>

			{/* Task Drawer */}
			<TaskDrawer
				key={drawerKey}
				isOpen={isTaskDrawerOpen}
				onClose={handleCloseTaskDrawer}
				onSubmit={handleSubmitTask}
				task={selectedTask}
				isLoading={createTaskMutation.isPending || updateTaskMutation.isPending}
			/>
		</DashboardLayout>
	)
}
