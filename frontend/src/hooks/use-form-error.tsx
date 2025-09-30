// frontend/src/hooks/use-form-error.tsx
import { Alert } from "flowbite-react"

export const useFormError = (error: any) => {
	const getErrorMessage = () => {
		if (!error) return null

		if (error.isAxiosError && error.response) {
			const responseData = error.response.data

			if (responseData?.errors && Array.isArray(responseData.errors)) {
				return responseData.errors[0]
			}

			if (responseData?.message) {
				return responseData.message
			}
		}

		return error.message || "Something went wrong. Please try again."
	}

	const errorMessage = getErrorMessage()

	const ErrorComponent = error ? (
		<Alert color='failure'>{errorMessage}</Alert>
	) : null

	return {
		hasError: !!error,
		errorMessage,
		ErrorComponent,
	}
}
