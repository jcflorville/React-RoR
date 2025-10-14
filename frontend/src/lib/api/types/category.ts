// Tipos específicos para Categories API
export interface CategoryResponse {
	data: Category[]
}

export interface SingleCategoryResponse {
	data: Category
}

export interface Category {
	id: number
	name: string
	color: string
	description?: string
	created_at: string
	updated_at: string
}

export interface CreateCategoryRequest {
	name: string
	color?: string
	description?: string
}

export interface UpdateCategoryRequest extends Partial<CreateCategoryRequest> {
	id: number
}
