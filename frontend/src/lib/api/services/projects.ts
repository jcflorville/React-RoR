import { api } from "@/lib/api"
import type {
	ProjectResponse,
	SingleProjectResponse,
	CreateProjectRequest,
	UpdateProjectRequest,
	ProjectFilters,
} from "../types/project"

export const projectsApi = {
	// GET /api/v1/projects - Listar projetos com filtros
	getAll: async (filters?: ProjectFilters): Promise<ProjectResponse> => {
		const params = new URLSearchParams()

		if (filters?.search) params.append("search", filters.search)
		if (filters?.status) params.append("status", filters.status)
		if (filters?.priority) params.append("priority", filters.priority)
		if (filters?.page) params.append("page", filters.page.toString())
		if (filters?.per_page)
			params.append("per_page", filters.per_page.toString())
		if (filters?.sort) params.append("sort", filters.sort)

		console.log("🔍 Fazendo requisição para:", `/projects?${params.toString()}`)
		const response = await api.get(`/projects?${params.toString()}`)
		return response.data
	},

	// GET /api/v1/projects/:id - Buscar projeto específico
	getById: async (id: number): Promise<SingleProjectResponse> => {
		const response = await api.get(`/projects/${id}?include=tasks,categories`)
		return response.data
	},

	// POST /api/v1/projects - Criar novo projeto
	create: async (
		project: CreateProjectRequest
	): Promise<SingleProjectResponse> => {
		const response = await api.post("/projects", { project })
		return response.data
	},

	// PUT /api/v1/projects/:id - Atualizar projeto
	update: async ({
		id,
		...project
	}: UpdateProjectRequest): Promise<SingleProjectResponse> => {
		const response = await api.put(`/projects/${id}`, { project })
		return response.data
	},

	// DELETE /api/v1/projects/:id - Deletar projeto
	delete: async (id: number): Promise<void> => {
		await api.delete(`/projects/${id}`)
	},
}
