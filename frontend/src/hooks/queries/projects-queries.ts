// Custom Hooks para Projects - Toda lógica do TanStack Query centralizada
import {
	useQuery,
	useMutation,
	useQueryClient,
	useInfiniteQuery,
	type UseQueryOptions,
} from "@tanstack/react-query"
import { projectsApi } from "@/lib/api/services/projects"
import { projectsKeys } from "@/lib/api/keys/projects"
import type {
	ProjectFilters,
	ProjectResponse,
	SingleProjectResponse,
} from "@/lib/api/types/project"

export { projectsKeys, projectsApi }

// ================================
// QUERIES (Leitura de dados)
// ================================

/**
 * Hook para buscar lista de projetos com filtros
 * Automatically caches and manages loading/error states
 */
export const useProjects = (
	filters?: ProjectFilters,
	options?: Partial<UseQueryOptions<ProjectResponse>>
) => {
	return useQuery({
		queryKey: projectsKeys.list(filters),
		queryFn: () => projectsApi.getAll(filters),
		staleTime: 5 * 60 * 1000, // 5 minutos
		retry: (failureCount, error) => {
			// Não tentar novamente em erros 4xx (exceto 401)
			if (error instanceof Error && "status" in error) {
				const status = (error as any).response?.status
				if (status >= 400 && status < 500 && status !== 401) {
					return false
				}
			}
			return failureCount < 2
		},
		...options,
	})
}

/**
 * Hook para buscar projeto específico
 */
export const useProject = (
	id: number,
	options?: Partial<UseQueryOptions<SingleProjectResponse>>
) => {
	return useQuery({
		queryKey: projectsKeys.detail(id),
		queryFn: () => projectsApi.getById(id),
		enabled: !!id, // Só executa se id existir
		...options,
	})
}

/**
 * Hook para buscar projeto específico no modal
 * Separado do useProject para diferentes necessidades de cache e otimização
 */
export const useModalProject = (
	id: number | null,
	options?: Partial<UseQueryOptions<SingleProjectResponse>>
) => {
	return useQuery({
		queryKey: [...projectsKeys.detail(id!), "modal"], // Cache separado com suffix 'modal'
		queryFn: () => projectsApi.getById(id!),
		enabled: !!id, // Só executa se id existir
		staleTime: 2 * 60 * 1000, // 2 minutos (mais agressivo que useProject)
		retry: 1, // Menos retry para modal (UX mais rápida)
		...options,
	})
}

// ================================
// MUTATIONS (Modificação de dados)
// ================================

/**
 * Hook para criar novo projeto
 * Automatically invalidates cache após sucesso
 */
export const useCreateProject = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: projectsApi.create,
		onSuccess: (newProject) => {
			// Invalida cache da lista para refetch
			queryClient.invalidateQueries({
				queryKey: projectsKeys.lists(),
			})

			// Opcional: Adiciona o novo projeto ao cache
			queryClient.setQueryData(
				projectsKeys.detail(newProject.data.id),
				newProject
			)

			console.log("✅ Projeto criado com sucesso:", newProject.data.name)
		},
		onError: (error) => {
			console.error("❌ Erro ao criar projeto:", error)
		},
	})
}

/**
 * Hook para atualizar projeto existente
 */
export const useUpdateProject = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: projectsApi.update,
		onSuccess: (updatedProject) => {
			// Atualiza cache do projeto específico
			queryClient.setQueryData(
				projectsKeys.detail(updatedProject.data.id),
				updatedProject
			)

			// Invalida lista para garantir consistência
			queryClient.invalidateQueries({
				queryKey: projectsKeys.lists(),
			})

			console.log(
				"✅ Projeto atualizado com sucesso:",
				updatedProject.data.name
			)
		},
		onError: (error) => {
			console.error("❌ Erro ao atualizar projeto:", error)
		},
	})
}

/**
 * Hook para deletar projeto
 */
export const useDeleteProject = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: projectsApi.delete,
		onSuccess: (_, deletedId) => {
			// Remove do cache
			queryClient.removeQueries({
				queryKey: projectsKeys.detail(deletedId),
			})

			// Invalida lista
			queryClient.invalidateQueries({
				queryKey: projectsKeys.lists(),
			})

			console.log("✅ Projeto deletado com sucesso")
		},
		onError: (error) => {
			console.error("❌ Erro ao deletar projeto:", error)
		},
	})
}

export const useInfiniteProjects = (
	filters?: Omit<ProjectFilters, "page">,
	perPage: number = 10
) => {
	return useInfiniteQuery({
		queryKey: projectsKeys.list(filters),
		queryFn: ({ pageParam }) =>
			projectsApi.getAll({ ...filters, page: pageParam, per_page: perPage }),

		initialPageParam: 1,
		getNextPageParam: (lastPage) => lastPage.meta?.next_page ?? undefined,

		staleTime: 10 * 60 * 1000,
		gcTime: 15 * 60 * 1000,

		// Keep data while navigating away
		placeholderData: (previousData) => previousData,
	})
}
