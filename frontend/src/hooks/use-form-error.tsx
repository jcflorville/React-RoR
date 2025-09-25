// frontend/src/hooks/use-form-error.tsx
import { Alert } from "flowbite-react"

export const useFormError = (error: any) => {
	const getErrorMessage = () => {
		if (!error) return null

		if (error.isAxiosError && error.response) {
			const responseData = error.response.data

			console.log("🔍 Backend response data:", responseData)

			if (responseData?.message) {
				return responseData.message
			}
		}

		return error.message || "Something went wrong. Please try again."
	}

	const errorMessage = getErrorMessage()
	console.log("🔍 Final error message:", errorMessage)

	const ErrorComponent = error ? (
		<Alert color='failure'>{errorMessage}</Alert>
	) : null

	return {
		hasError: !!error,
		errorMessage,
		ErrorComponent,
	}
}
