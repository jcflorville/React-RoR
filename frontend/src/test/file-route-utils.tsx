import React from "react"
import { render, type RenderOptions } from "@testing-library/react"
import {
	createRouter,
	type RouterHistory,
	RouterProvider,
	createMemoryHistory,
} from "@tanstack/react-router"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"

// Import the generated route tree
import { routeTree } from "../routeTree.gen"
import { vi } from "vitest"

/**
 * Creates a test QueryClient with optimized settings for testing
 */
export function createTestQueryClient() {
	return new QueryClient({
		defaultOptions: {
			queries: {
				retry: false,
				gcTime: Infinity,
				staleTime: Infinity,
			},
			mutations: {
				retry: false,
			},
		},
		// logger: {
		// 	log: console.log,
		// 	warn: console.warn,
		// 	error: () => {}, // Silence errors in tests
		// },
	})
}

/**
 * Creates a test router using the real generated route tree
 */
export function createTestRouterFromFiles(options?: {
	initialLocation?: string
	routerContext?: any
	history?: RouterHistory
}) {
	const router = createRouter({
		routeTree,
		history:
			options?.history ||
			createMemoryHistory({
				initialEntries: [options?.initialLocation || "/"],
			}),
		context: options?.routerContext || {
			auth: {
				user: null,
				isAuthenticated: false,
				isLoading: false,
			},
		},
	})

	return router
}

/**
 * Custom render function for testing file-based routes with full providers
 */
interface RenderWithFileRoutesOptions extends Omit<RenderOptions, "wrapper"> {
	initialLocation?: string
	routerContext?: any
	queryClient?: QueryClient
}

export function renderWithFileRoutes(
	ui: React.ReactElement,
	options: RenderWithFileRoutesOptions = {},
) {
	const {
		initialLocation = "/",
		routerContext = {},
		queryClient = createTestQueryClient(),
		...renderOptions
	} = options

	const router = createTestRouterFromFiles({
		initialLocation,
		routerContext,
	})

	function Wrapper({ children }: { children: React.ReactNode }) {
		return (
			<QueryClientProvider client={queryClient}>
				<RouterProvider router={router} />
				{children}
			</QueryClientProvider>
		)
	}

	return {
		...render(ui, { wrapper: Wrapper, ...renderOptions }),
		router,
		queryClient,
	}
}

/**
 * Helper to render a specific route by path
 */
export function renderRoute(
	path: string,
	options?: RenderWithFileRoutesOptions,
) {
	return renderWithFileRoutes(<div />, {
		...options,
		initialLocation: path,
	})
}

/**
 * Mock fetch helper for API tests
 */
export function mockFetchSuccess<T>(data: T) {
	global.fetch = vi.fn().mockResolvedValue({
		ok: true,
		status: 200,
		json: async () => data,
	} as Response)
}

export function mockFetchError(status = 500, message = "Server Error") {
	global.fetch = vi.fn().mockResolvedValue({
		ok: false,
		status,
		statusText: message,
		json: async () => ({ error: message }),
	} as Response)
}
