import { createFileRoute, Link } from "@tanstack/react-router"
import { AuthLayout } from "../components/layouts/AuthLayout"
import { Button, Label, TextInput, Checkbox } from "flowbite-react"

export const Route = createFileRoute("/sign-up")({
	component: SignUpPage,
})

function SignUpPage() {
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

				<form className='space-y-6'>
					<div className='grid grid-cols-1 gap-6 sm:grid-cols-2'>
						<div>
							<Label htmlFor='firstName'>First name</Label>
							<TextInput
								id='firstName'
								name='firstName'
								type='text'
								autoComplete='given-name'
								required
								placeholder='Enter your first name'
								className='mt-1'
							/>
						</div>

						<div>
							<Label htmlFor='lastName'>Last name</Label>
							<TextInput
								id='lastName'
								name='lastName'
								type='text'
								autoComplete='family-name'
								required
								placeholder='Enter your last name'
								className='mt-1'
							/>
						</div>
					</div>

					<div>
						<Label htmlFor='email'>Email address</Label>
						<TextInput
							id='email'
							name='email'
							type='email'
							autoComplete='email'
							required
							placeholder='Enter your email'
							className='mt-1'
						/>
					</div>

					<div>
						<Label htmlFor='password'>Password</Label>
						<TextInput
							id='password'
							name='password'
							type='password'
							autoComplete='new-password'
							required
							placeholder='Create a password'
							className='mt-1'
						/>
					</div>

					<div>
						<Label htmlFor='confirmPassword'>Confirm password</Label>
						<TextInput
							id='confirmPassword'
							name='confirmPassword'
							type='password'
							autoComplete='new-password'
							required
							placeholder='Confirm your password'
							className='mt-1'
						/>
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
						>
							Create account
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
