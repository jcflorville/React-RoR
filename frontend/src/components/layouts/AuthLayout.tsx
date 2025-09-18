import type { ReactNode } from "react"
import { Link } from "@tanstack/react-router"

interface AuthLayoutProps {
	children: ReactNode
}

export const AuthLayout = ({ children }: AuthLayoutProps) => {
	return (
		<div className='min-h-screen bg-gray-50 dark:bg-gray-900 flex flex-col justify-center py-12 sm:px-6 lg:px-8'>
			<div className='sm:mx-auto sm:w-full sm:max-w-md'>
				<Link to='/' className='flex justify-center'>
					<img className='h-12 w-auto' src='/vite.svg' alt='React-RoR' />
				</Link>
				<h2 className='mt-6 text-center text-3xl font-extrabold text-gray-900 dark:text-white'>
					React-RoR
				</h2>
			</div>

			<div className='mt-8 sm:mx-auto sm:w-full sm:max-w-md'>
				<div className='bg-white dark:bg-gray-800 py-8 px-4 shadow sm:rounded-lg sm:px-10'>
					{children}
				</div>
			</div>

			<div className='mt-8 sm:mx-auto sm:w-full sm:max-w-md'>
				<div className='text-center'>
					<Link
						to='/'
						className='text-sm text-cyan-600 hover:text-cyan-500 dark:text-cyan-400 dark:hover:text-cyan-300'
					>
						← Back to home
					</Link>
				</div>
			</div>
		</div>
	)
}
