// frontend/src/hooks/use-form-input.ts
import type { UseFormRegister, FieldErrors } from "react-hook-form"

interface UseFormInputProps {
	name: string
	register: UseFormRegister<any>
	errors: FieldErrors
}

export const useFormInput = ({ name, register, errors }: UseFormInputProps) => {
	const error = errors[name]

	return {
		...register(name),
		color: error ? "failure" : undefined,
		helperText: error?.message as string,
		hasError: !!error,
	}
}
