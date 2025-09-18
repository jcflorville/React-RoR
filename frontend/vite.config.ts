import tailwindcss from "@tailwindcss/vite"
import { TanStackRouterVite } from "@tanstack/router-plugin/vite"
import { defineConfig } from "vite"
// import tsConfigPaths from "vite-tsconfig-paths"
import react from "@vitejs/plugin-react-swc"
import flowbiteReact from "flowbite-react/plugin/vite"
import path from "path"

// https://vite.dev/config/
export default defineConfig({
	plugins: [
		tailwindcss(),
		TanStackRouterVite({
			target: "react",
			autoCodeSplitting: true,
		}),
		// tsConfigPaths(),
		react(),
		flowbiteReact(),
	],
	resolve: {
		alias: {
			"@": path.resolve(__dirname, "./src"),
			"@components": path.resolve(__dirname, "./src/components"),
			"@layouts": path.resolve(__dirname, "./src/components/layouts"),
			"@hooks": path.resolve(__dirname, "./src/hooks"),
			"@stores": path.resolve(__dirname, "./src/stores"),
			"@lib": path.resolve(__dirname, "./src/lib"),
			"@types": path.resolve(__dirname, "./src/types"),
			"@routes": path.resolve(__dirname, "./src/routes"),
			"@providers": path.resolve(__dirname, "./src/providers"),
			"@utils": path.resolve(__dirname, "./src/utils"),
			"@assets": path.resolve(__dirname, "./src/assets"),
		},
	},
	server: {
		host: "0.0.0.0", // Allow external connections
		port: 5173,
		watch: {
			usePolling: true, // Enable polling for file changes in Docker
		},
		hmr: {
			port: 5173, // Hot Module Replacement port
		},
	},
})
