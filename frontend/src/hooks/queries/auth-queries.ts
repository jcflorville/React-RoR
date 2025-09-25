// frontend/src/hooks/queries/auth-queries.ts
import { api } from "@lib/api"
import { useMutation } from "@tanstack/react-query"
import { useNavigate } from "@tanstack/react-router"
import { useAuthStore } from "@stores/auth-store"
import type {
	LoginCredentials,
	RegisterCredentials,
	AuthResponse,
} from "@types/auth"

// Mutation para login
export const useLoginMutation = () => {
	const { login } = useAuthStore()

	return useMutation({
		mutationFn: async (
			credentials: LoginCredentials
		): Promise<{ data: AuthResponse; headers: any }> => {
			const response = await api.post("/auth/sign_in", {
				user: credentials,
			})
			return {
				data: response.data,
				headers: response.headers,
			}
		},
		onSuccess: ({ data, headers }) => {
			console.log("🔍 Login response:", data)
			console.log("🔍 Response headers:", headers)

			const authHeader = headers["authorization"] || headers["Authorization"]
			const token = authHeader ? authHeader.replace("Bearer ", "") : null
			const user = data.data || data.user

			console.log("🔍 Extracted:", { token, user })

			if (token && user) {
				login(user, token)
				console.log("✅ Auth set via Zustand store")
			} else {
				console.error("❌ Missing token or user in response")
			}
		},
		onError: (error) => {
			console.error("Login error:", error)
		},
	})
}

// Mutation para register
export const useRegisterMutation = () => {
	const { login } = useAuthStore()

	return useMutation({
		mutationFn: async (
			userData: RegisterCredentials
		): Promise<{ data: AuthResponse; headers: any }> => {
			const response = await api.post("/auth/sign_up", {
				user: userData,
			})
			return {
				data: response.data,
				headers: response.headers,
			}
		},
		onSuccess: ({ data, headers }) => {
			console.log("🔍 Register response:", data)
			console.log("🔍 Response headers:", headers)

			const authHeader = headers["authorization"] || headers["Authorization"]
			const token = authHeader ? authHeader.replace("Bearer ", "") : null
			const user = data.data || data.user

			console.log("🔍 Extracted:", { token, user })

			if (token && user) {
				login(user, token)
				console.log("✅ Auth set via Zustand store")
			} else {
				console.error("❌ Missing token or user in response")
			}
		},
		onError: (error) => {
			console.error("Register error:", error)
		},
	})
}

// Mutation para logout
export const useLogoutMutation = () => {
	const navigate = useNavigate()
	const { logout } = useAuthStore()

	return useMutation({
		mutationFn: async () => {
			try {
				await api.delete("/auth/sign_out")
			} catch (error) {
				console.warn("Logout request failed, but clearing local auth")
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
