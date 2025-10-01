import { create } from "zustand"
import { persist, createJSONStorage } from "zustand/middleware"
import type { User, AuthState } from "@/types/auth"

interface AuthActions {
	login: (user: User, token: string) => void
	logout: () => void
	setUser: (user: User) => void
	setLoading: (loading: boolean) => void
	clearAuth: () => void
}

type AuthStore = AuthState & AuthActions

export const useAuthStore = create<AuthStore>()(
	persist(
		(set) => ({
			// Estado inicial
			user: null,
			token: null,
			isAuthenticated: false,
			isLoading: false,

			// Ações
			login: (user: User, token: string) => {
				localStorage.setItem("auth_token", token)
				set({
					user,
					token,
					isAuthenticated: true,
					isLoading: false,
				})
			},

			logout: () => {
				localStorage.removeItem("auth_token")
				set({
					user: null,
					token: null,
					isAuthenticated: false,
					isLoading: false,
				})
			},

			setUser: (user: User) => {
				set({ user })
			},

			setLoading: (loading: boolean) => {
				set({ isLoading: loading })
			},

			clearAuth: () => {
				localStorage.removeItem("auth_token")
				set({
					user: null,
					token: null,
					isAuthenticated: false,
					isLoading: false,
				})
			},
		}),
		{
			name: "auth-storage",
			storage: createJSONStorage(() => localStorage),
			partialize: (state) => ({
				user: state.user,
				token: state.token,
				isAuthenticated: state.isAuthenticated,
			}),
		}
	)
)
