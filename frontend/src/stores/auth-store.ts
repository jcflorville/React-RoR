import { create } from "zustand"
import { persist, createJSONStorage } from "zustand/middleware"
import type { User, AuthState } from "@/types/auth"

interface AuthActions {
	login: (user: User, token: string, refreshToken?: string) => void
	logout: () => void
	setUser: (user: User) => void
	setTokens: (token: string, refreshToken: string) => void
	setLoading: (loading: boolean) => void
	clearAuth: () => void
	setHydrated: () => void
}

type AuthStore = AuthState & AuthActions

export const useAuthStore = create<AuthStore>()(
	persist(
		(set) => ({
			// Estado inicial
			user: null,
			token: null,
			refreshToken: null,
			isAuthenticated: false,
			isLoading: true,
			isHydrated: false,

			// Ações
			login: (user: User, token: string, refreshToken?: string) => {
				localStorage.setItem("auth_token", token)
				if (refreshToken) {
					localStorage.setItem("refresh_token", refreshToken)
				}
				set({
					user,
					token,
					refreshToken: refreshToken || null,
					isAuthenticated: true,
					isLoading: false,
				})
			},

			logout: () => {
				localStorage.removeItem("auth_token")
				localStorage.removeItem("refresh_token")
				set({
					user: null,
					token: null,
					refreshToken: null,
					isAuthenticated: false,
					isLoading: false,
				})
			},

			setUser: (user: User) => {
				set({ user })
			},

			setTokens: (token: string, refreshToken: string) => {
				localStorage.setItem("auth_token", token)
				localStorage.setItem("refresh_token", refreshToken)
				set({ token, refreshToken })
			},

			setLoading: (loading: boolean) => {
				set({ isLoading: loading })
			},

			clearAuth: () => {
				localStorage.removeItem("auth_token")
				localStorage.removeItem("refresh_token")
				set({
					user: null,
					token: null,
					refreshToken: null,
					isAuthenticated: false,
					isLoading: false,
				})
			},

			setHydrated: () => {
				set({ isHydrated: true, isLoading: false })
			},
		}),
		{
			name: "auth-storage",
			storage: createJSONStorage(() => localStorage),
			partialize: (state) => ({
				user: state.user,
				token: state.token,
				refreshToken: state.refreshToken,
				isAuthenticated: state.isAuthenticated,
			}),
			onRehydrateStorage: () => (state) => {
				if (state) {
					state.setHydrated()
				}
			},
		}
	)
)
