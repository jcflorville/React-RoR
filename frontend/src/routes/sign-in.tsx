import { createFileRoute, Link } from "@tanstack/react-router"
import { AuthLayout } from "../components/layouts/AuthLayout"
import { Button, Label, TextInput, Checkbox } from "flowbite-react"

export const Route = createFileRoute("/sign-in")({
	component: SignInPage,
})

function SignInPage() {
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

				<form className='space-y-6'>
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
							autoComplete='current-password'
							required
							placeholder='Enter your password'
							className='mt-1'
						/>
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
						>
							Sign in
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
