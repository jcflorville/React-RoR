// Task types matching backend structure

export type TaskStatus = "todo" | "in_progress" | "completed" | "blocked"
export type TaskPriority = "low" | "medium" | "high" | "urgent"

export interface Task {
	id: number
	title: string
	description: string | null
	status: TaskStatus
	priority: TaskPriority
	due_date: string | null
	completed_at: string | null
	overdue: boolean
	days_until_due: number | null
	created_at: string
	updated_at: string
	project_id: number
	user_id: number
}

// API Response types
export interface TasksResponse {
	success: boolean
	data: Task[]
	message?: string
}

export interface TaskResponse {
	success: boolean
	data: Task
	message?: string
}

export interface CreateTaskRequest {
	title: string
	description?: string
	status?: TaskStatus
	priority?: TaskPriority
	due_date?: string
	user_id?: number
}

export interface UpdateTaskRequest {
	title?: string
	description?: string
	status?: TaskStatus
	priority?: TaskPriority
	due_date?: string
	user_id?: number
}

export interface TasksFilters {
	search?: string
	status?: TaskStatus
	priority?: TaskPriority
	assignee_id?: number
	due_date_from?: string
	due_date_to?: string
	overdue?: boolean
	sort?: string
}
