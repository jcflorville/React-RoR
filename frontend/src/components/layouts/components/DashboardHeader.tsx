// frontend/src/components/layouts/components/DashboardHeader.tsx
import { Link, useNavigate } from "@tanstack/react-router"
import {
	Navbar,
	NavbarCollapse,
	NavbarToggle,
	Dropdown,
	DropdownDivider,
	DropdownHeader,
	DropdownItem,
	Avatar,
} from "flowbite-react"
import { useAuthStore } from "@stores/auth-store"
import { useLogoutMutation } from "@hooks/queries/auth-queries"

interface DashboardHeaderProps {
	onToggleSidebar: () => void
}

export const DashboardHeader = ({ onToggleSidebar }: DashboardHeaderProps) => {
	const { user } = useAuthStore() // ✅ Direto do store
	const navigate = useNavigate()
	const logoutMutation = useLogoutMutation()

	const handleLogoClick = () => {
		navigate({ to: "/dashboard" })
	}

	const handleLogout = () => {
		logoutMutation.mutate()
	}

	return (
		<Navbar
			fluid
			className='fixed top-0 left-0 right-0 z-50 border-b bg-white dark:bg-gray-800 px-4'
		>
			<div className='flex items-center'>
				<button
					onClick={onToggleSidebar}
					type='button'
					className='flex items-center justify-center w-10 h-10 text-gray-500 rounded-lg hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-white dark:hover:bg-gray-700 mr-3 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500'
					aria-label='Toggle sidebar'
				>
					<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
						<path
							fillRule='evenodd'
							d='M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z'
							clipRule='evenodd'
						/>
					</svg>
				</button>

				<div
					className='flex items-center cursor-pointer'
					onClick={handleLogoClick}
				>
					<img src='/vite.svg' className='mr-3 h-6 sm:h-8' alt='Logo' />
					<span className='self-center whitespace-nowrap text-xl font-semibold dark:text-white'>
						Dashboard
					</span>
				</div>
			</div>

			<div className='flex items-center gap-4'>
				<div className='hidden lg:block'>
					<div className='relative'>
						<div className='absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none'>
							<svg
								className='w-4 h-4 text-gray-500 dark:text-gray-400'
								fill='none'
								stroke='currentColor'
								viewBox='0 0 24 24'
							>
								<path
									strokeLinecap='round'
									strokeLinejoin='round'
									strokeWidth={2}
									d='M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'
								/>
							</svg>
						</div>
						<input
							type='search'
							className='block w-full p-2 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-cyan-500 focus:border-cyan-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-cyan-500 dark:focus:border-cyan-500'
							placeholder='Search...'
						/>
					</div>
				</div>

				<button className='relative p-2 text-gray-500 rounded-lg hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-white dark:hover:bg-gray-700'>
					<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
						<path d='M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z' />
					</svg>
					<div className='absolute block w-3 h-3 bg-red-500 border-2 border-white rounded-full -top-0.5 start-2.5 dark:border-gray-900'></div>
				</button>

				<Dropdown
					arrowIcon={false}
					inline
					label={
						<Avatar
							alt={`${user?.name || "User"} avatar`}
							img={
								user
									? `https://ui-avatars.com/api/?name=${encodeURIComponent(
											user.name
									  )}&background=0891b2&color=fff`
									: "https://flowbite.com/docs/images/people/profile-picture-5.jpg"
							}
							rounded
						/>
					}
				>
					<DropdownHeader>
						<span className='block text-sm'>{user?.name || "User"}</span>
						<span className='block truncate text-sm font-medium'>
							{user?.email || "user@example.com"}
						</span>
					</DropdownHeader>
					<DropdownItem as={Link} to='/dashboard/profile'>
						Profile
					</DropdownItem>
					<DropdownItem as={Link} to='/dashboard/settings'>
						Settings
					</DropdownItem>
					<DropdownDivider />
					<DropdownItem
						onClick={handleLogout}
						className='text-red-600 hover:text-red-700 hover:bg-red-50'
					>
						{logoutMutation.isPending ? "Signing out..." : "Sign out"}
					</DropdownItem>
				</Dropdown>

				<NavbarToggle className='lg:hidden' />
			</div>

			<NavbarCollapse className='lg:hidden'>
				<div className='p-4 space-y-2'>
					<input
						type='search'
						className='block w-full p-2 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-cyan-500 focus:border-cyan-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-cyan-500 dark:focus:border-cyan-500'
						placeholder='Search...'
					/>
				</div>
			</NavbarCollapse>
		</Navbar>
	)
}
