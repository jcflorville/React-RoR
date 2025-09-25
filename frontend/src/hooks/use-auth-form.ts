// frontend/src/hooks/use-auth-form.ts
import { useForm, type SubmitHandler } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { useNavigate } from "@tanstack/react-router"
import { useLoginMutation, useRegisterMutation } from "./queries/auth-queries"
import {
	loginSchema,
	registerSchema,
	type LoginFormData,
	type RegisterFormData,
} from "@lib/validations/auth"

// Hook para Login
export const useLoginForm = () => {
	const navigate = useNavigate()
	const loginMutation = useLoginMutation()

	const form = useForm<LoginFormData>({
		resolver: zodResolver(loginSchema),
		defaultValues: {
			email: "",
			password: "",
		},
	})

	// ✅ CORREÇÃO: Usar SubmitHandler
	const onSubmit: SubmitHandler<LoginFormData> = (data) => {
		console.log("🔍 Form submitted with data:", data)

		loginMutation.mutate(data, {
			onSuccess: () => {
				console.log("🔍 Login SUCCESS - navigating to dashboard")
				navigate({ to: "/dashboard" })
			},
			onError: (error) => {
				console.log("🔍 Login ERROR occurred:", error)
				// NÃO redirecionar - deixar erro ser mostrado
			},
		})
	}

	return {
		...form,
		onSubmit: form.handleSubmit(onSubmit), // ✅ handleSubmit já gerencia preventDefault
		isLoading: loginMutation.isPending,
		error: loginMutation.error,
		mutation: loginMutation,
	}
}

// Hook para Register
export const useRegisterForm = () => {
	const navigate = useNavigate()
	const registerMutation = useRegisterMutation()

	const form = useForm<RegisterFormData>({
		resolver: zodResolver(registerSchema),
		defaultValues: {
			name: "",
			email: "",
			password: "",
			password_confirmation: "",
		},
	})

	// ✅ CORREÇÃO: Usar SubmitHandler
	const onSubmit: SubmitHandler<RegisterFormData> = (data) => {
		registerMutation.mutate(data, {
			onSuccess: () => {
				navigate({ to: "/dashboard" })
			},
			onError: (error) => {
				console.error("Registration failed:", error)
			},
		})
	}

	return {
		...form,
		onSubmit: form.handleSubmit(onSubmit),
		isLoading: registerMutation.isPending,
		error: registerMutation.error,
		mutation: registerMutation,
	}
}
