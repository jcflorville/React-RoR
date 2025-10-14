// Custom Hooks para Categories - TanStack Query
import {
	useQuery,
	useMutation,
	useQueryClient,
	type UseQueryOptions,
} from "@tanstack/react-query"
import { categoriesApi } from "@/lib/api/services/categories"
import { categoriesKeys } from "@/lib/api/keys/categories"
import type {
	CategoryResponse,
	SingleCategoryResponse,
} from "@/lib/api/types/category"

// ================================
// QUERIES (Leitura de dados)
// ================================

/**
 * Hook para buscar lista de categorias
 */
export const useCategories = (
	options?: Partial<UseQueryOptions<CategoryResponse>>
) => {
	return useQuery({
		queryKey: categoriesKeys.list(),
		queryFn: () => categoriesApi.getAll(),
		staleTime: 10 * 60 * 1000, // 10 minutos (categorias mudam pouco)
		...options,
	})
}

/**
 * Hook para buscar categoria específica
 */
export const useCategory = (
	id: number,
	options?: Partial<UseQueryOptions<SingleCategoryResponse>>
) => {
	return useQuery({
		queryKey: categoriesKeys.detail(id),
		queryFn: () => categoriesApi.getById(id),
		enabled: !!id,
		...options,
	})
}

// ================================
// MUTATIONS (Modificação de dados)
// ================================

/**
 * Hook para criar nova categoria
 */
export const useCreateCategory = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: categoriesApi.create,
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: categoriesKeys.lists(),
			})
		},
	})
}

/**
 * Hook para atualizar categoria
 */
export const useUpdateCategory = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: categoriesApi.update,
		onSuccess: (_, variables) => {
			queryClient.invalidateQueries({
				queryKey: categoriesKeys.lists(),
			})
			queryClient.invalidateQueries({
				queryKey: categoriesKeys.detail(variables.id),
			})
		},
	})
}

/**
 * Hook para deletar categoria
 */
export const useDeleteCategory = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: categoriesApi.delete,
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: categoriesKeys.lists(),
			})
		},
	})
}
