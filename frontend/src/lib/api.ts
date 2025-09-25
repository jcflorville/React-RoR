// frontend/src/lib/api.ts
import axios from "axios"
import { useAuthStore } from "@stores/auth-store"

export const api = axios.create({
	baseURL: "http://localhost:3000/api/v1",
	headers: {
		"Content-Type": "application/json",
	},
})

// ✅ INTERCEPTOR SIMPLES: Só adicionar token
api.interceptors.request.use((config) => {
	const token = useAuthStore.getState().token

	if (token) {
		config.headers.Authorization = `Bearer ${token}`
	}

	return config
})

// ✅ INTERCEPTOR RESPONSE: Só logs (opcional)
api.interceptors.response.use(
	(response) => response,
	(error) => {
		// ✅ Log para debug (opcional)
		console.log(`API Error: ${error.response?.status} - ${error.config?.url}`)

		// ✅ SEMPRE repassar erro sem modificar
		return Promise.reject(error)
	}
)
