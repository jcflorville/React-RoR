import js from "@eslint/js"
import globals from "globals"
import reactHooks from "eslint-plugin-react-hooks"
import reactRefresh from "eslint-plugin-react-refresh"
import tseslint from "typescript-eslint"

export default tseslint.config(
	// Ignores globais
	{
		ignores: ["dist/**", "**/routeTree.gen.ts", ".flowbite-react/**"],
	},
	// Configuração base JavaScript
	js.configs.recommended,
	// Configurações TypeScript recomendadas
	...tseslint.configs.recommended,
	// Configuração específica para arquivos TS/TSX
	{
		files: ["**/*.{ts,tsx}"],
		languageOptions: {
			ecmaVersion: 2020,
			globals: globals.browser,
			parserOptions: {
				project: ["./tsconfig.app.json", "./tsconfig.node.json"],
				tsconfigRootDir: import.meta.dirname,
			},
		},
		plugins: {
			"react-hooks": reactHooks,
			"react-refresh": reactRefresh,
		},
		rules: {
			...reactHooks.configs.recommended.rules,
			"@typescript-eslint/no-explicit-any": "off",
			"react-refresh/only-export-components": [
				"warn",
				{ allowConstantExport: true },
			],
		},
	}
)
