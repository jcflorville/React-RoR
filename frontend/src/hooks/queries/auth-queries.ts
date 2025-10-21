// frontend/src/hooks/queries/auth-queries.ts
import { api } from "@lib/api"
import { useMutation } from "@tanstack/react-query"
import { useNavigate } from "@tanstack/react-router"
import { useAuthStore } from "@stores/auth-store"
import type {
	LoginCredentials,
	RegisterCredentials,
	AuthResponse,
} from "@/types/auth"

// Hook genérico para autenticação
const useAuthMutation = (endpoint: string) => {
	const { login } = useAuthStore()

	return useMutation({
		mutationFn: async (
			credentials: LoginCredentials | RegisterCredentials
		): Promise<{ data: AuthResponse; headers: any }> => {
			const response = await api.post(endpoint, {
				user: credentials,
			})
			return {
				data: response.data,
				headers: response.headers,
			}
		},
		onSuccess: ({ data, headers }) => {
			console.log(`🔍 ${endpoint} response:`, data)
			console.log("🔍 Response headers:", headers)

			// Access token vem no header Authorization
			const authHeader = headers["authorization"] || headers["Authorization"]
			const token = authHeader ? authHeader.replace("Bearer ", "") : null

			// Refresh token vem no body da resposta
			const refreshToken = data.refresh_token
			const user = data.data

			console.log("🔍 Extracted:", { token, refreshToken, user })

			if (token && user) {
				login(user, token, refreshToken)
				console.log("✅ Auth set via Zustand store with refresh token")
			} else {
				console.error("❌ Missing token or user in response")
			}
		},
		onError: (error) => {
			console.error(`${endpoint} error:`, error)
		},
	})
}

export const useLoginMutation = () => useAuthMutation("/auth/sign_in")
export const useRegisterMutation = () => useAuthMutation("/auth/sign_up")

export const useLogoutMutation = () => {
	const navigate = useNavigate()
	const { logout } = useAuthStore()

	return useMutation({
		mutationFn: async () => {
			try {
				await api.delete("/auth/sign_out")
			} catch (error) {
				console.warn("Logout request failed, but clearing local auth", error)
			}
		},
		onSuccess: () => {
			logout()
			navigate({ to: "/" })
		},
		onError: () => {
			logout()
			navigate({ to: "/" })
		},
	})
}
