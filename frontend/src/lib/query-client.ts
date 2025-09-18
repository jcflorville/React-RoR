import { QueryClient } from "@tanstack/react-query"

export const queryClient = new QueryClient({
	defaultOptions: {
		queries: {
			staleTime: 5 * 60 * 1000, // 5 minutos
			gcTime: 10 * 60 * 1000, // 10 minutos (antes era cacheTime)
			retry: (failureCount, error) => {
				// Não tentar novamente em erros 4xx
				if (error instanceof Error && "status" in error) {
					const status = (error as any).status
					if (status >= 400 && status < 500) {
						return false
					}
				}
				return failureCount < 3
			},
		},
		mutations: {
			retry: false,
		},
	},
})
