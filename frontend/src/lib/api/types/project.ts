// Tipos específicos para Projects API
export interface ProjectResponse {
	data: Project[]
	meta?: {
		total: number
		page: number
		per_page: number
		total_pages: number
	}
}

export interface SingleProjectResponse {
	data: Project
}

export interface Project {
	id: number
	name: string
	description?: string
	status: "draft" | "active" | "completed" | "archived"
	priority: "low" | "medium" | "high" | "urgent"
	start_date?: string
	end_date?: string
	created_at: string
	updated_at: string
	// Campos computados
	progress_percentage: number
	overdue: boolean
	status_humanized: string
	priority_humanized: string
	// Relações (quando incluídas via includes)
	tasks?: Task[]
	categories?: Category[]
}

export interface Task {
	id: number
	title: string
	description?: string
	status: "todo" | "in_progress" | "completed" | "blocked"
	priority: "low" | "medium" | "high" | "urgent"
	due_date?: string
	completed_at?: string
	created_at: string
	updated_at: string
}

export interface Category {
	id: number
	name: string
	color: string
	description?: string
}

export interface CreateProjectRequest {
	name: string
	description?: string
	status?: Project["status"]
	priority?: Project["priority"]
	start_date?: string
	end_date?: string
	category_ids?: number[]
}

export interface UpdateProjectRequest extends Partial<CreateProjectRequest> {
	id: number
}

export interface ProjectFilters {
	search?: string
	status?: string
	priority?: string
	category_id?: string
	sort?:
		| "name_asc"
		| "name_desc"
		| "priority_desc"
		| "status"
		| "created_at_desc"
	page?: number
	per_page?: number
}
