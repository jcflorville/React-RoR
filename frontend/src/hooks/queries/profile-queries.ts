// frontend/src/hooks/queries/profile-queries.ts
import { api } from "@lib/api"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import type { User } from "@types/auth"

export const profileKeys = {
	profile: () => ["profile"] as const,
}

// Query para página de Profile (dados completos)
export const useProfileQuery = () => {
	return useQuery({
		queryKey: profileKeys.profile(),
		queryFn: async (): Promise<User> => {
			const response = await api.get("/profiles")
			return response.data.data
		},
		staleTime: 2 * 60 * 1000, // 2 minutos
	})
}

// Mutation para atualizar perfil
export const useUpdateProfileMutation = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: async (profileData: Partial<User>) => {
			const response = await api.put("/profiles", { user: profileData })
			return response.data.data
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: profileKeys.profile() })
		},
	})
}
