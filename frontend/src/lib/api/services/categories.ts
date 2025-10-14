// API Service para Categories
import { api } from "@/lib/api"
import type {
	CategoryResponse,
	SingleCategoryResponse,
	CreateCategoryRequest,
	UpdateCategoryRequest,
} from "../types/category"

export const categoriesApi = {
	// GET /api/v1/categories - Listar todas categorias
	getAll: async (): Promise<CategoryResponse> => {
		const response = await api.get("/categories")
		return response.data
	},

	// GET /api/v1/categories/:id - Buscar categoria específica
	getById: async (id: number): Promise<SingleCategoryResponse> => {
		const response = await api.get(`/categories/${id}`)
		return response.data
	},

	// POST /api/v1/categories - Criar nova categoria
	create: async (
		category: CreateCategoryRequest
	): Promise<SingleCategoryResponse> => {
		const response = await api.post("/categories", { category })
		return response.data
	},

	// PUT /api/v1/categories/:id - Atualizar categoria
	update: async ({
		id,
		...category
	}: UpdateCategoryRequest): Promise<SingleCategoryResponse> => {
		const response = await api.put(`/categories/${id}`, { category })
		return response.data
	},

	// DELETE /api/v1/categories/:id - Deletar categoria
	delete: async (id: number): Promise<void> => {
		await api.delete(`/categories/${id}`)
	},
}
