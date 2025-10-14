import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import {
	getProjectTasks,
	getTask,
	createTask,
	updateTask,
	deleteTask,
	completeTask,
	reopenTask,
} from "@/lib/api/services/tasks"
import type {
	CreateTaskRequest,
	UpdateTaskRequest,
	TasksFilters,
} from "@/lib/api/types/task"
import toast from "react-hot-toast"

// Query Keys
export const tasksKeys = {
	all: ["tasks"] as const,
	lists: () => [...tasksKeys.all, "list"] as const,
	list: (projectId: number, filters?: TasksFilters) =>
		[...tasksKeys.lists(), projectId, filters] as const,
	details: () => [...tasksKeys.all, "detail"] as const,
	detail: (projectId: number, taskId: number) =>
		[...tasksKeys.details(), projectId, taskId] as const,
}

// Hooks

// Get all tasks for a project
export const useProjectTasks = (projectId: number, filters?: TasksFilters) => {
	return useQuery({
		queryKey: tasksKeys.list(projectId, filters),
		queryFn: () => getProjectTasks(projectId, filters),
		enabled: !!projectId,
	})
}

// Get a single task
export const useTask = (projectId: number, taskId: number) => {
	return useQuery({
		queryKey: tasksKeys.detail(projectId, taskId),
		queryFn: () => getTask(projectId, taskId),
		enabled: !!projectId && !!taskId,
	})
}

// Create task mutation
export const useCreateTask = (projectId: number) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (data: CreateTaskRequest) => createTask(projectId, data),
		onSuccess: (response) => {
			// Invalidate project tasks list
			queryClient.invalidateQueries({ queryKey: tasksKeys.lists() })
			// Invalidate project details (to update progress)
			queryClient.invalidateQueries({ queryKey: ["projects", "detail"] })
			toast.success(response.message || "Task created successfully")
		},
		onError: (error: any) => {
			const message = error.response?.data?.message || "Failed to create task"
			toast.error(message)
		},
	})
}

// Update task mutation
export const useUpdateTask = (projectId: number) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: ({
			taskId,
			data,
		}: {
			taskId: number
			data: UpdateTaskRequest
		}) => updateTask(projectId, taskId, data),
		onSuccess: (response, variables) => {
			// Invalidate task detail
			queryClient.invalidateQueries({
				queryKey: tasksKeys.detail(projectId, variables.taskId),
			})
			// Invalidate tasks list
			queryClient.invalidateQueries({ queryKey: tasksKeys.lists() })
			// Invalidate project details
			queryClient.invalidateQueries({ queryKey: ["projects", "detail"] })
			toast.success(response.message || "Task updated successfully")
		},
		onError: (error: any) => {
			const message = error.response?.data?.message || "Failed to update task"
			toast.error(message)
		},
	})
}

// Delete task mutation
export const useDeleteTask = (projectId: number) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (taskId: number) => deleteTask(projectId, taskId),
		onSuccess: (response) => {
			// Invalidate tasks list
			queryClient.invalidateQueries({ queryKey: tasksKeys.lists() })
			// Invalidate project details
			queryClient.invalidateQueries({ queryKey: ["projects", "detail"] })
			toast.success(response.message || "Task deleted successfully")
		},
		onError: (error: any) => {
			const message = error.response?.data?.message || "Failed to delete task"
			toast.error(message)
		},
	})
}

// Complete task mutation
export const useCompleteTask = (projectId: number) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (taskId: number) => completeTask(projectId, taskId),
		onSuccess: (response, taskId) => {
			// Invalidate task detail
			queryClient.invalidateQueries({
				queryKey: tasksKeys.detail(projectId, taskId),
			})
			// Invalidate tasks list
			queryClient.invalidateQueries({ queryKey: tasksKeys.lists() })
			// Invalidate project details
			queryClient.invalidateQueries({ queryKey: ["projects", "detail"] })
			toast.success(response.message || "Task completed!")
		},
		onError: (error: any) => {
			const message = error.response?.data?.message || "Failed to complete task"
			toast.error(message)
		},
	})
}

// Reopen task mutation
export const useReopenTask = (projectId: number) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (taskId: number) => reopenTask(projectId, taskId),
		onSuccess: (response, taskId) => {
			// Invalidate task detail
			queryClient.invalidateQueries({
				queryKey: tasksKeys.detail(projectId, taskId),
			})
			// Invalidate tasks list
			queryClient.invalidateQueries({ queryKey: tasksKeys.lists() })
			// Invalidate project details
			queryClient.invalidateQueries({ queryKey: ["projects", "detail"] })
			toast.success(response.message || "Task reopened")
		},
		onError: (error: any) => {
			const message = error.response?.data?.message || "Failed to reopen task"
			toast.error(message)
		},
	})
}
