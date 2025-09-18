import axios from "axios"

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000"

export const api = axios.create({
	baseURL: `${API_URL}/api/v1`,
	headers: {
		"Content-Type": "application/json",
	},
})

// Interceptor para adicionar token automaticamente
api.interceptors.request.use((config) => {
	const token = localStorage.getItem("auth_token")
	if (token) {
		config.headers.Authorization = `Bearer ${token}`
	}
	return config
})

// Interceptor para tratar respostas e erros
api.interceptors.response.use(
	(response) => response,
	(error) => {
		if (error.response?.status === 401) {
			// Token expirado ou inválido
			localStorage.removeItem("auth_token")
			window.location.href = "/login"
		}
		return Promise.reject(error)
	}
)
