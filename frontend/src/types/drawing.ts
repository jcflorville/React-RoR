export interface Drawing {
	id: number
	title: string
	canvas_data: FabricCanvasData
	lock_version: number
	created_at: string
	updated_at: string
	user?: {
		id: number
		email: string
		name: string
	}
}

export interface FabricCanvasData {
	version: string
	objects: FabricObject[]
	background?: string
	[key: string]: unknown
}

export interface FabricObject {
	type: string
	[key: string]: unknown
}

export interface CreateDrawingPayload {
	title?: string
	canvas_data?: FabricCanvasData
}

export interface UpdateDrawingPayload {
	title?: string
	canvas_data?: FabricCanvasData
	lock_version?: number
}

export interface DrawingResponse {
	data: Drawing
	message: string
	success: boolean
}

export interface DrawingsListResponse {
	data: Drawing[]
	message: string
	success: boolean
}
