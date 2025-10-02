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
}

export interface CreateProjectRequest {
	name: string
	description?: string
	status?: Project["status"]
	priority?: Project["priority"]
	start_date?: string
	end_date?: string
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
