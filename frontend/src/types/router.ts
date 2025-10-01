import type { User } from "@/types/auth"

export interface RouterContext {
	auth: {
		user: User | null
		isAuthenticated: boolean
		isLoading: boolean
	}
}
