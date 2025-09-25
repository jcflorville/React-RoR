// frontend/src/routes/sign-in.tsx
import { createFileRoute, Link } from "@tanstack/react-router"
import { AuthLayout } from "../components/layouts/AuthLayout"
import { Button, Label, TextInput, Checkbox } from "flowbite-react"
import { useLoginForm } from "@hooks/use-auth-form"
import { useFormError } from "@hooks/use-form-error"

export const Route = createFileRoute("/sign-in")({
	component: SignInPage,
})

function SignInPage() {
	const {
		register,
		onSubmit,
		formState: { errors },
		isLoading,
		error,
	} = useLoginForm()
	const { ErrorComponent } = useFormError(error)

	return (
		<AuthLayout>
			<div className='space-y-6'>
				<div>
					<h3 className='text-lg font-medium text-gray-900 dark:text-white'>
						Sign in to your account
					</h3>
					<p className='mt-1 text-sm text-gray-600 dark:text-gray-400'>
						Welcome back! Please enter your details.
					</p>
				</div>

				{ErrorComponent}

				{/* ✅ CORREÇÃO: onSubmit já tem preventDefault via handleSubmit */}
				<form className='space-y-6' onSubmit={onSubmit}>
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
							placeholder='Enter your password'
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

					<div className='flex items-center justify-between'>
						<div className='flex items-center'>
							<Checkbox id='remember-me' />
							<Label htmlFor='remember-me' className='ml-2 text-sm'>
								Remember me
							</Label>
						</div>

						<div className='text-sm'>
							<a
								href='#'
								className='font-medium text-cyan-600 hover:text-cyan-500 dark:text-cyan-400 dark:hover:text-cyan-300'
							>
								Forgot your password?
							</a>
						</div>
					</div>

					<div>
						<Button
							type='submit'
							className='w-full bg-cyan-700 hover:bg-cyan-800'
							size='lg'
							disabled={isLoading}
						>
							{isLoading ? "Signing in..." : "Sign in"}
						</Button>
					</div>
				</form>

				<div className='text-center'>
					<p className='text-sm text-gray-600 dark:text-gray-400'>
						Don't have an account?{" "}
						<Link
							to='/sign-up'
							className='font-medium text-cyan-600 hover:text-cyan-500 dark:text-cyan-400 dark:hover:text-cyan-300'
						>
							Sign up
						</Link>
					</p>
				</div>
			</div>
		</AuthLayout>
	)
}
