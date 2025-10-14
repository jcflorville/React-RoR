import { Button, Spinner } from "flowbite-react"
import { TaskCard } from "./TaskCard"
import type { Task } from "@/lib/api/types/task"
import { HiOutlinePlus } from "react-icons/hi"

interface TasksListProps {
	tasks: Task[]
	isLoading?: boolean
	onAddTask: () => void
	onEditTask: (task: Task) => void
	onDeleteTask: (task: Task) => void
	onCompleteTask?: (task: Task) => void
	onReopenTask?: (task: Task) => void
}

export function TasksList({
	tasks,
	isLoading = false,
	onAddTask,
	onEditTask,
	onDeleteTask,
	onCompleteTask,
	onReopenTask,
}: TasksListProps) {
	if (isLoading) {
		return (
			<div className='flex items-center justify-center py-12'>
				<Spinner size='lg' />
				<span className='ml-3 text-gray-600 dark:text-gray-400'>
					Loading tasks...
				</span>
			</div>
		)
	}

	if (tasks.length === 0) {
		return (
			<div className='text-center py-12 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg'>
				<p className='text-gray-500 dark:text-gray-400 mb-4'>No tasks yet</p>
				<Button size='sm' color='blue' onClick={onAddTask}>
					<HiOutlinePlus className='mr-2 h-4 w-4' />
					Add Your First Task
				</Button>
			</div>
		)
	}

	return (
		<div className='space-y-4'>
			{tasks.map((task) => (
				<TaskCard
					key={task.id}
					task={task}
					onEdit={onEditTask}
					onDelete={onDeleteTask}
					onComplete={onCompleteTask}
					onReopen={onReopenTask}
				/>
			))}
		</div>
	)
}
