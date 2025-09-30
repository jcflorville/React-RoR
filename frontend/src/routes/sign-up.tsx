// frontend/src/routes/sign-up.tsx
import { createFileRoute, Link } from "@tanstack/react-router"
import { AuthLayout } from "../components/layouts/AuthLayout"
import { Button, Label, TextInput, Checkbox } from "flowbite-react"
import { useRegisterForm } from "@hooks/use-auth-form"
import { useFormError } from "@hooks/use-form-error"

export const Route = createFileRoute("/sign-up")({
	component: SignUpPage,
})

function SignUpPage() {
	const {
		register,
		onSubmit,
		formState: { errors },
		isLoading,
		error,
	} = useRegisterForm()
	const { ErrorComponent } = useFormError(error)

	return (
		<AuthLayout>
			<div className='space-y-6'>
				<div>
					<h3 className='text-lg font-medium text-gray-900 dark:text-white'>
						Create your account
					</h3>
					<p className='mt-1 text-sm text-gray-600 dark:text-gray-400'>
						Join us today! Please fill in your information.
					</p>
				</div>

				{ErrorComponent}

				<form className='space-y-6' onSubmit={onSubmit}>
					<div>
						<Label htmlFor='name'>Full name</Label>
						<TextInput
							id='name'
							type='text'
							placeholder='Enter your full name'
							className='mt-1'
							color={errors.name ? "failure" : undefined}
							{...register("name")}
						/>
						{errors.name && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.name.message}
							</p>
						)}
					</div>

					<div>
						<Label htmlFor='email'>Email address</Label>
						<TextInput
							id='email'
							type='email'
							placeholder='Enter your email'
							className='mt-1'
							color={errors.email ? "failure" : undefined}
							{...register("email")}
						/>
						{errors.email && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.email.message}
							</p>
						)}
					</div>

					<div>
						<Label htmlFor='password'>Password</Label>
						<TextInput
							id='password'
							type='password'
							placeholder='Create a password'
							className='mt-1'
							color={errors.password ? "failure" : undefined}
							{...register("password")}
						/>
						{errors.password && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.password.message}
							</p>
						)}
					</div>

					<div>
						<Label htmlFor='password_confirmation'>Confirm password</Label>
						<TextInput
							id='password_confirmation'
							type='password'
							placeholder='Confirm your password'
							className='mt-1'
							color={errors.password_confirmation ? "failure" : undefined}
							{...register("password_confirmation")}
						/>
						{errors.password_confirmation && (
							<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
								{errors.password_confirmation.message}
							</p>
						)}
					</div>

					<div className='flex items-center'>
						<Checkbox id='terms' required />
						<Label htmlFor='terms' className='ml-2 text-sm'>
							I agree to the{" "}
							<a
								href='#'
								className='font-medium text-cyan-600 hover:text-cyan-500 dark:text-cyan-400 dark:hover:text-cyan-300'
							>
								Terms and Conditions
							</a>{" "}
							and{" "}
							<a
								href='#'
								className='font-medium text-cyan-600 hover:text-cyan-500 dark:text-cyan-400 dark:hover:text-cyan-300'
							>
								Privacy Policy
							</a>
						</Label>
					</div>

					<div>
						<Button
							type='submit'
							className='w-full bg-cyan-700 hover:bg-cyan-800'
							size='lg'
							disabled={isLoading}
						>
							{isLoading ? "Creating account..." : "Create account"}
						</Button>
					</div>
				</form>

				<div className='text-center'>
					<p className='text-sm text-gray-600 dark:text-gray-400'>
						Already have an account?{" "}
						<Link
							to='/sign-in'
							className='font-medium text-cyan-600 hover:text-cyan-500 dark:text-cyan-400 dark:hover:text-cyan-300'
						>
							Sign in
						</Link>
					</p>
				</div>
			</div>
		</AuthLayout>
	)
}
