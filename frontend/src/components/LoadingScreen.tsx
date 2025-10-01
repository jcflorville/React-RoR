// frontend/src/components/LoadingScreen.tsx
export const LoadingScreen = () => {
	return (
		<div className='min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center'>
			<div className='text-center'>
				{/* Loading Spinner */}
				<div className='animate-spin rounded-full h-12 w-12 border-b-2 border-cyan-500 mx-auto mb-4'></div>

				{/* Loading Text */}
				<p className='text-gray-600 dark:text-gray-400 text-sm'>
					Loading your application...
				</p>

				{/* Optional: Logo */}
				<div className='mt-8'>
					<img
						className='h-8 w-auto mx-auto opacity-50'
						src='/vite.svg'
						alt='React-RoR'
					/>
				</div>
			</div>
		</div>
	)
}
