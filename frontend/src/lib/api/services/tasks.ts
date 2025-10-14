import { api } from "@/lib/api"
import type {
	CreateTaskRequest,
	UpdateTaskRequest,
	TasksFilters,
	TaskResponse,
	TasksResponse,
} from "../types/task"

const TASKS_BASE_URL = "/projects"

// Get all tasks for a specific project
export const getProjectTasks = async (
	projectId: number,
	filters?: TasksFilters
): Promise<TasksResponse> => {
	const params = new URLSearchParams()

	if (filters?.search) params.append("search", filters.search)
	if (filters?.status) params.append("status", filters.status)
	if (filters?.priority) params.append("priority", filters.priority)
	if (filters?.assignee_id)
		params.append("assignee_id", filters.assignee_id.toString())
	if (filters?.due_date_from)
		params.append("due_date_from", filters.due_date_from)
	if (filters?.due_date_to) params.append("due_date_to", filters.due_date_to)
	if (filters?.overdue !== undefined)
		params.append("overdue", filters.overdue.toString())
	if (filters?.sort) params.append("sort", filters.sort)

	const queryString = params.toString()
	const url = `${TASKS_BASE_URL}/${projectId}/tasks${
		queryString ? `?${queryString}` : ""
	}`

	const response = await api.get<TasksResponse>(url)
	return response.data
}

// Get a single task
export const getTask = async (
	projectId: number,
	taskId: number
): Promise<TaskResponse> => {
	const response = await api.get<TaskResponse>(
		`${TASKS_BASE_URL}/${projectId}/tasks/${taskId}`
	)
	return response.data
}

// Create a new task
export const createTask = async (
	projectId: number,
	data: CreateTaskRequest
): Promise<TaskResponse> => {
	const response = await api.post<TaskResponse>(
		`${TASKS_BASE_URL}/${projectId}/tasks`,
		{ task: data }
	)
	return response.data
}

// Update a task
export const updateTask = async (
	projectId: number,
	taskId: number,
	data: UpdateTaskRequest
): Promise<TaskResponse> => {
	const response = await api.patch<TaskResponse>(
		`${TASKS_BASE_URL}/${projectId}/tasks/${taskId}`,
		{ task: data }
	)
	return response.data
}

// Delete a task
export const deleteTask = async (
	projectId: number,
	taskId: number
): Promise<{ success: boolean; message?: string }> => {
	const response = await api.delete<{ success: boolean; message?: string }>(
		`${TASKS_BASE_URL}/${projectId}/tasks/${taskId}`
	)
	return response.data
}

// Complete a task
export const completeTask = async (
	projectId: number,
	taskId: number
): Promise<TaskResponse> => {
	const response = await api.patch<TaskResponse>(
		`${TASKS_BASE_URL}/${projectId}/tasks/${taskId}/complete`
	)
	return response.data
}

// Reopen a task
export const reopenTask = async (
	projectId: number,
	taskId: number
): Promise<TaskResponse> => {
	const response = await api.patch<TaskResponse>(
		`${TASKS_BASE_URL}/${projectId}/tasks/${taskId}/reopen`
	)
	return response.data
}
