import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { api } from "@lib/api"
import { useAuthStore } from "@stores/auth-store"
import type {
	AuthResponse,
	LoginCredentials,
	RegisterCredentials,
	User,
} from "@types/auth"

// Query Keys
export const authKeys = {
	all: ["auth"] as const,
	me: () => [...authKeys.all, "me"] as const,
}

// Hook para buscar dados do usuário atual
export const useMeQuery = () => {
	const { isAuthenticated } = useAuthStore()

	return useQuery({
		queryKey: authKeys.me(),
		queryFn: async (): Promise<User> => {
			const response = await api.get("/auth/me")
			return response.data.user
		},
		enabled: isAuthenticated,
		staleTime: 5 * 60 * 1000, // 5 minutos
	})
}

// Mutation para login
export const useLoginMutation = () => {
	const queryClient = useQueryClient()
	const { login } = useAuthStore()

	return useMutation({
		mutationFn: async (
			credentials: LoginCredentials
		): Promise<AuthResponse> => {
			const response = await api.post("/auth/login", credentials)
			return response.data
		},
		onSuccess: (data) => {
			login(data.user, data.token)
			queryClient.setQueryData(authKeys.me(), data.user)
		},
		onError: (error) => {
			console.error("Login failed:", error)
		},
	})
}

// Mutation para registro
export const useRegisterMutation = () => {
	const queryClient = useQueryClient()
	const { login } = useAuthStore()

	return useMutation({
		mutationFn: async (
			credentials: RegisterCredentials
		): Promise<AuthResponse> => {
			const response = await api.post("/auth/register", credentials)
			return response.data
		},
		onSuccess: (data) => {
			login(data.user, data.token)
			queryClient.setQueryData(authKeys.me(), data.user)
		},
	})
}

// Mutation para logout
export const useLogoutMutation = () => {
	const queryClient = useQueryClient()
	const { logout } = useAuthStore()

	return useMutation({
		mutationFn: async () => {
			await api.post("/auth/logout")
		},
		onSuccess: () => {
			logout()
			queryClient.clear() // Limpa todo o cache
		},
		onError: () => {
			// Mesmo com erro, fazemos logout local
			logout()
			queryClient.clear()
		},
	})
}
