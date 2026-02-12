import {
	useQuery,
	useMutation,
	useQueryClient,
	type UseQueryOptions,
	type UseMutationOptions,
} from "@tanstack/react-query"
import { drawingsApi } from "@/lib/api/services/drawings"
import type {
	Drawing,
	CreateDrawingPayload,
	UpdateDrawingPayload,
} from "@/types/drawing"

// Query keys for drawings
export const drawingsKeys = {
	all: ["drawings"] as const,
	lists: () => [...drawingsKeys.all, "list"] as const,
	list: () => [...drawingsKeys.lists()] as const,
	details: () => [...drawingsKeys.all, "detail"] as const,
	detail: (id: number) => [...drawingsKeys.details(), id] as const,
}

export { drawingsApi }

// ================================
// QUERIES (Read operations)
// ================================

/**
 * Hook to fetch all drawings for current user
 */
export const useDrawings = (options?: Partial<UseQueryOptions<Drawing[]>>) => {
	return useQuery({
		queryKey: drawingsKeys.list(),
		queryFn: () => drawingsApi.getAll(),
		staleTime: 5 * 60 * 1000, // 5 minutes
		...options,
	})
}

/**
 * Hook to fetch a specific drawing by ID
 */
export const useDrawing = (
	id: number,
	options?: Partial<UseQueryOptions<Drawing>>,
) => {
	return useQuery({
		queryKey: drawingsKeys.detail(id),
		queryFn: () => drawingsApi.getById(id),
		enabled: !!id,
		staleTime: 2 * 60 * 1000, // 2 minutes (shorter for active editing)
		...options,
	})
}

// ================================
// MUTATIONS (Write operations)
// ================================

/**
 * Hook to create a new drawing
 */
export const useCreateDrawing = (
	options?: UseMutationOptions<Drawing, Error, CreateDrawingPayload>,
) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (payload: CreateDrawingPayload) => drawingsApi.create(payload),
		onSuccess: (data) => {
			// Invalidate list to refetch
			queryClient.invalidateQueries({ queryKey: drawingsKeys.lists() })
			// Set detail in cache
			queryClient.setQueryData(drawingsKeys.detail(data.id), data)
		},
		...options,
	})
}

/**
 * Hook to update an existing drawing
 */
export const useUpdateDrawing = (
	id: number,
	options?: UseMutationOptions<Drawing, Error, UpdateDrawingPayload>,
) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (payload: UpdateDrawingPayload) =>
			drawingsApi.update(id, payload),
		onMutate: async (payload) => {
			// Cancel outgoing refetches
			await queryClient.cancelQueries({ queryKey: drawingsKeys.detail(id) })

			// Snapshot previous value
			const previous = queryClient.getQueryData<Drawing>(
				drawingsKeys.detail(id),
			)

			// DON'T optimistically update canvas_data to avoid reload
			// Only update other fields like title
			if (previous && payload.title) {
				queryClient.setQueryData<Drawing>(drawingsKeys.detail(id), {
					...previous,
					title: payload.title,
				})
			}

			return { previous }
		},
		onError: (err, payload, context) => {
			// Rollback on error
			if (context?.previous) {
				queryClient.setQueryData(drawingsKeys.detail(id), context.previous)
			}
		},
		onSuccess: (data, variables) => {
			// Only update lock_version and other metadata from server
			// Keep current canvas_data to avoid reload during editing
			const currentData = queryClient.getQueryData<Drawing>(
				drawingsKeys.detail(id),
			)
			if (currentData && variables.canvas_data) {
				// If we just saved canvas_data, use it (it's already in the canvas)
				queryClient.setQueryData<Drawing>(drawingsKeys.detail(id), {
					...data,
					canvas_data: currentData.canvas_data,
				})
			} else {
				// For other updates (like title), use server data
				queryClient.setQueryData(drawingsKeys.detail(id), data)
			}
			queryClient.invalidateQueries({ queryKey: drawingsKeys.lists() })
		},
		...options,
	})
}

/**
 * Hook to delete a drawing
 */
export const useDeleteDrawing = (
	options?: UseMutationOptions<void, Error, number>,
) => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (id: number) => drawingsApi.delete(id),
		onSuccess: (_, id) => {
			// Remove from cache
			queryClient.removeQueries({ queryKey: drawingsKeys.detail(id) })
			// Invalidate list
			queryClient.invalidateQueries({ queryKey: drawingsKeys.lists() })
		},
		...options,
	})
}
