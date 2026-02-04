import { defineConfig } from "vitest/config"
import react from "@vitejs/plugin-react-swc"
import { TanStackRouterVite } from "@tanstack/router-plugin/vite"
import path from "path"

export default defineConfig({
	plugins: [
		TanStackRouterVite({
			// Configure for test environment
			routesDirectory: "./src/routes",
			generatedRouteTree: "./src/routeTree.gen.ts",
			disableLogging: true,
		}),
		react(),
	],
	test: {
		globals: true,
		environment: "jsdom",
		setupFiles: ["./src/test/setup.ts"],
		include: ["**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
		coverage: {
			provider: "v8",
			reporter: ["text", "json", "html"],
			exclude: [
				"node_modules/",
				"src/test/",
				"**/*.d.ts",
				"**/*.config.*",
				"**/mockData",
				"**/types",
				"src/routeTree.gen.ts",
			],
		},
		poolOptions: {
			threads: {
				singleThread: true, // Important for TanStack Router state management
			},
		},
	},
	resolve: {
		alias: {
			"@": path.resolve(__dirname, "./src"),
			"@components": path.resolve(__dirname, "./src/components"),
			"@layouts": path.resolve(__dirname, "./src/components/layouts"),
			"@hooks": path.resolve(__dirname, "./src/hooks"),
			"@queries": path.resolve(__dirname, "./src/hooks/queries"),
			"@stores": path.resolve(__dirname, "./src/stores"),
			"@lib": path.resolve(__dirname, "./src/lib"),
			"@types": path.resolve(__dirname, "./src/types"),
			"@routes": path.resolve(__dirname, "./src/routes"),
			"@providers": path.resolve(__dirname, "./src/providers"),
			"@utils": path.resolve(__dirname, "./src/utils"),
			"@assets": path.resolve(__dirname, "./src/assets"),
			"@test": path.resolve(__dirname, "./src/test"),
		},
	},
})
