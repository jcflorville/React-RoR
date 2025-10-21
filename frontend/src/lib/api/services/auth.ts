import { api } from "@/lib/api"
import type {
	AuthResponse,
	RefreshTokenResponse,
	LoginCredentials,
	RegisterCredentials,
} from "@/types/auth"

export const authService = {
	login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
		const response = await api.post<AuthResponse>("/auth/sign_in", {
			user: credentials,
		})
		return response.data
	},

	register: async (
		credentials: RegisterCredentials
	): Promise<AuthResponse> => {
		const response = await api.post<AuthResponse>("/auth/sign_up", {
			user: credentials,
		})
		return response.data
	},

	logout: async (): Promise<void> => {
		await api.delete("/auth/sign_out")
	},

	refreshToken: async (
		refreshToken: string
	): Promise<RefreshTokenResponse> => {
		const response = await api.post<RefreshTokenResponse>("/auth/refresh", {
			refresh_token: refreshToken,
		})
		return response.data
	},
}
