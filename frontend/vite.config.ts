import tailwindcss from "@tailwindcss/vite"
import { TanStackRouterVite } from "@tanstack/router-plugin/vite"
import { defineConfig } from "vite"
// import tsConfigPaths from "vite-tsconfig-paths"
import react from "@vitejs/plugin-react-swc"
import flowbiteReact from "flowbite-react/plugin/vite"

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
