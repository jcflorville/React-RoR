export interface User {
	id: number
	email: string
	name: string
	created_at: string
	updated_at: string
}

export interface AuthResponse {
	user: User
	token: string
}

export interface LoginCredentials {
	email: string
	password: string
}

export interface RegisterCredentials {
	name: string
	email: string
	password: string
	password_confirmation: string
}

export interface AuthState {
	user: User | null
	token: string | null
	isAuthenticated: boolean
	isLoading: boolean
}
