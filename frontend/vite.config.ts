import { defineConfig } from "vite"
import react from "@vitejs/plugin-react-swc"
import tailwindcss from "@tailwindcss/vite"
import flowbiteReact from "flowbite-react/plugin/vite";

// https://vite.dev/config/
export default defineConfig({
	plugins: [react(), tailwindcss(), flowbiteReact()],
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