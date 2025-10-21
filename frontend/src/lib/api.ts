// frontend/src/lib/api.ts
import axios, { type AxiosError, type InternalAxiosRequestConfig } from "axios"
import { useAuthStore } from "@stores/auth-store"

export const api = axios.create({
	baseURL: "http://localhost:3000/api/v1",
	headers: {
		"Content-Type": "application/json",
	},
})

// Flag para evitar múltiplas tentativas de refresh simultâneas
let isRefreshing = false
let failedQueue: Array<{
	resolve: (token: string) => void
	reject: (error: any) => void
}> = []

const processQueue = (error: any, token: string | null = null) => {
	failedQueue.forEach((prom) => {
		if (error) {
			prom.reject(error)
		} else {
			prom.resolve(token!)
		}
	})

	failedQueue = []
}

// Request interceptor: Adicionar token de autenticação
api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
	// Skip se já tem _skipAuthRefresh (request já processado pelo refresh)
	const skipAuth = (config as any)._skipAuthRefresh
	if (skipAuth) {
		delete (config as any)._skipAuthRefresh
		return config
	}

	const token = useAuthStore.getState().token
	if (token && config.headers) {
		config.headers.Authorization = `Bearer ${token}`
	}

	return config
})

// Response interceptor: Tratar erro 401 e renovar token automaticamente
api.interceptors.response.use(
	(response) => response,
	async (error: AxiosError) => {
		const originalRequest = error.config as InternalAxiosRequestConfig & {
			_retry?: boolean
		}

		console.log("🔍 Interceptor - Error status:", error.response?.status)
		console.log("🔍 Interceptor - URL:", originalRequest.url)
		console.log("🔍 Interceptor - Already retried?", originalRequest._retry)

		// Se erro não for 401 ou já tentou renovar, rejeitar
		if (error.response?.status !== 401 || originalRequest._retry) {
			console.log("❌ Not attempting refresh - status or already retried")
			return Promise.reject(error)
		}

		// Se for endpoint de auth, não tentar renovar
		if (
			originalRequest.url?.includes("/auth/sign_in") ||
			originalRequest.url?.includes("/auth/sign_up") ||
			originalRequest.url?.includes("/auth/refresh")
		) {
			return Promise.reject(error)
		}

		// Se já está renovando, adicionar à fila
		if (isRefreshing) {
			return new Promise((resolve, reject) => {
				failedQueue.push({ resolve, reject })
			})
				.then((token) => {
					if (originalRequest.headers) {
						originalRequest.headers.Authorization = `Bearer ${token}`
					}
					return api(originalRequest)
				})
				.catch((err) => Promise.reject(err))
		}

		originalRequest._retry = true
		isRefreshing = true

		const refreshToken = useAuthStore.getState().refreshToken

		if (!refreshToken) {
			isRefreshing = false
			useAuthStore.getState().clearAuth()
			return Promise.reject(error)
		}

		try {
			// Fazer chamada direta sem usar authService para evitar dependência circular
			const response = await axios.post(
				"http://localhost:3000/api/v1/auth/refresh",
				{
					refresh_token: refreshToken,
				}
			)

			console.log("✅ Refresh response:", response.data)
			console.log("✅ Refresh headers:", response.headers)

			// Extract token from header (priority) or body
			const authHeader =
				response.headers["authorization"] || response.headers["Authorization"]
			const newToken = authHeader
				? authHeader.replace("Bearer ", "")
				: response.data.token
			const newRefreshToken = response.data.refresh_token

			console.log("✅ Extracted tokens:", { newToken, newRefreshToken })

			if (!newToken || !newRefreshToken) {
				console.error("❌ Missing tokens in refresh response")
				throw new Error("Missing tokens in refresh response")
			}

			// Atualizar tokens no store
			useAuthStore.getState().setTokens(newToken, newRefreshToken)
			console.log("✅ Tokens updated in store")

			// Processar fila de requests que falharam
			processQueue(null, newToken)

			// Retentar request original com novo token
			// IMPORTANTE: Marcar para não passar pelo request interceptor novamente
			if (originalRequest.headers) {
				originalRequest.headers.Authorization = `Bearer ${newToken}`
			}
			;(originalRequest as any)._skipAuthRefresh = true

			console.log("✅ Retrying original request:", originalRequest.url)
			console.log("✅ With token:", newToken.substring(0, 20) + "...")
			return api(originalRequest)
		} catch (refreshError) {
			console.error("❌ Refresh error:", refreshError)
			processQueue(refreshError, null)
			useAuthStore.getState().clearAuth()
			return Promise.reject(refreshError)
		} finally {
			isRefreshing = false
		}
	}
)
