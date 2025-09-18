import { useEffect } from "react"
import { useAuthStore } from "@stores/auth-store"
import { useMeQuery } from "./queries/auth-queries"

export const useAuth = () => {
	const authStore = useAuthStore()
	const { data: user, isLoading, error } = useMeQuery()

	// Sincroniza o usuário do servidor com o store local
	useEffect(() => {
		if (user) {
			authStore.setUser(user)
		}
	}, [user, authStore])

	// Se houver erro na busca do usuário, limpa a autenticação
	useEffect(() => {
		if (error) {
			authStore.clearAuth()
		}
	}, [error, authStore])

	return {
		...authStore,
		isLoading: isLoading || authStore.isLoading,
		user: user || authStore.user,
	}
}
