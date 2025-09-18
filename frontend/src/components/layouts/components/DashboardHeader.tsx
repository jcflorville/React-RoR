import { Link } from "@tanstack/react-router"
import {
	Navbar,
	NavbarBrand,
	NavbarCollapse,
	NavbarToggle,
	Dropdown,
	DropdownDivider,
	DropdownHeader,
	DropdownItem,
	Avatar,
} from "flowbite-react"

interface DashboardHeaderProps {
	onToggleSidebar: () => void
}

export const DashboardHeader = ({ onToggleSidebar }: DashboardHeaderProps) => {
	return (
		<Navbar
			fluid
			className='fixed top-0 left-0 right-0 z-50 border-b bg-white dark:bg-gray-800 px-4'
		>
			<div className='flex items-center'>
				{/* Sidebar Toggle Button */}
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

				<NavbarBrand>
					<Link to='/dashboard' className='flex items-center'>
						<img src='/vite.svg' className='mr-3 h-6 sm:h-8' alt='Logo' />
						<span className='self-center whitespace-nowrap text-xl font-semibold dark:text-white'>
							Dashboard
						</span>
					</Link>
				</NavbarBrand>
			</div>

			<div className='flex items-center gap-4'>
				{/* Search Bar */}
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

				{/* Notifications */}
				<button className='relative p-2 text-gray-500 rounded-lg hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-white dark:hover:bg-gray-700'>
					<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
						<path d='M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z' />
					</svg>
					<div className='absolute block w-3 h-3 bg-red-500 border-2 border-white rounded-full -top-0.5 start-2.5 dark:border-gray-900'></div>
				</button>

				{/* User Menu */}
				<Dropdown
					arrowIcon={false}
					inline
					label={
						<Avatar
							alt='User settings'
							img='https://flowbite.com/docs/images/people/profile-picture-5.jpg'
							rounded
						/>
					}
				>
					<DropdownHeader>
						<span className='block text-sm'>João Silva</span>
						<span className='block truncate text-sm font-medium'>
							joao@example.com
						</span>
					</DropdownHeader>
					<DropdownItem>
						{/* <Link to='/dashboard/profile'>Profile</Link> */}
						Profile
					</DropdownItem>
					<DropdownItem>
						{/* <Link to='/dashboard/settings'>Settings</Link> */}
						Settings
					</DropdownItem>
					<DropdownDivider />
					<DropdownItem>
						<Link to='/sign-in'>Sign out</Link>
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
