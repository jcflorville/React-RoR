import { api } from "@/lib/api"
import type {
	Drawing,
	DrawingResponse,
	DrawingsListResponse,
	CreateDrawingPayload,
	UpdateDrawingPayload,
} from "@/types/drawing"

export const drawingsApi = {
	// GET /api/v1/drawings - List all drawings
	getAll: async (): Promise<Drawing[]> => {
		const response = await api.get<DrawingsListResponse>("/drawings")
		return response.data.data
	},

	// GET /api/v1/drawings/:id - Get specific drawing
	getById: async (id: number): Promise<Drawing> => {
		const response = await api.get<DrawingResponse>(`/drawings/${id}`)
		return response.data.data
	},

	// POST /api/v1/drawings - Create new drawing
	create: async (payload: CreateDrawingPayload): Promise<Drawing> => {
		const response = await api.post<DrawingResponse>("/drawings", {
			drawing: payload,
		})
		return response.data.data
	},

	// PATCH /api/v1/drawings/:id - Update drawing
	update: async (
		id: number,
		payload: UpdateDrawingPayload,
	): Promise<Drawing> => {
		const response = await api.patch<DrawingResponse>(`/drawings/${id}`, {
			drawing: payload,
		})
		return response.data.data
	},

	// DELETE /api/v1/drawings/:id - Delete drawing
	delete: async (id: number): Promise<void> => {
		await api.delete(`/drawings/${id}`)
	},
}
