// frontend/src/components/layouts/components/Header.tsx
import { Link, useNavigate } from "@tanstack/react-router"
import {
	Avatar,
	Button,
	Dropdown,
	DropdownDivider,
	DropdownHeader,
	DropdownItem,
	Navbar,
	NavbarCollapse,
	NavbarLink,
	NavbarToggle,
	DarkThemeToggle,
} from "flowbite-react"
import { useAuthStore } from "@stores/auth-store"
import { useLogoutMutation } from "@hooks/queries/auth-queries"

export const AppHeader = () => {
	const { user, isAuthenticated } = useAuthStore()
	const logoutMutation = useLogoutMutation()
	const navigate = useNavigate()

	const handleLogout = () => {
		logoutMutation.mutate()
	}

	const handleLogoClick = () => {
		navigate({ to: "/" })
	}

	const renderAuthSection = () => {
		// Authenticated user
		if (isAuthenticated && user) {
			return (
				<Dropdown
					arrowIcon={false}
					inline
					label={
						<Avatar
							alt={`${user.name} avatar`}
							img={`https://ui-avatars.com/api/?name=${encodeURIComponent(
								user.name
							)}&background=0891b2&color=fff`}
							rounded
						/>
					}
				>
					<DropdownHeader>
						<span className='block text-sm'>{user.name}</span>
						<span className='block truncate text-sm font-medium'>
							{user.email}
						</span>
					</DropdownHeader>
					<DropdownItem as={Link} to='/dashboard'>
						Dashboard
					</DropdownItem>
					<DropdownItem as={Link} to='/dashboard/profile'>
						Profile
					</DropdownItem>
					<DropdownDivider />
					<DropdownItem
						onClick={handleLogout}
						className='text-red-600 hover:text-red-700 hover:bg-red-50'
					>
						{logoutMutation.isPending ? "Signing out..." : "Sign out"}
					</DropdownItem>
				</Dropdown>
			)
		}

		// Not authenticated
		return (
			<div className='flex items-center space-x-2'>
				<Button
					as={Link}
					to='/sign-in'
					color='gray'
					size='sm'
					className='border-gray-300 hover:bg-gray-50'
				>
					Sign In
				</Button>
				<Button as={Link} to='/sign-up' color='blue' size='sm'>
					Sign Up
				</Button>
			</div>
		)
	}

	return (
		<Navbar fluid rounded>
			<div
				className='flex items-center cursor-pointer'
				onClick={handleLogoClick}
			>
				<img src='/vite.svg' className='mr-3 h-6 sm:h-9' alt='Logo' />
				<span className='self-center whitespace-nowrap text-xl font-semibold dark:text-white'>
					React-RoR
				</span>
			</div>

			<div className='flex md:order-2'>
				<div className='mr-4 flex items-center'>
					<DarkThemeToggle />
				</div>

				{renderAuthSection()}

				<NavbarToggle />
			</div>

			<NavbarCollapse>
				<NavbarLink as='div'>
					<Link
						to='/'
						className='block py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent [&.active]:text-cyan-700'
					>
						Home
					</Link>
				</NavbarLink>

				<NavbarLink as='div'>
					<Link
						to='/about'
						className='block py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent [&.active]:text-cyan-700'
					>
						About
					</Link>
				</NavbarLink>

				{isAuthenticated && (
					<>
						<NavbarLink as='div'>
							<Link
								to='/dashboard'
								className='block py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent [&.active]:text-cyan-700'
							>
								Dashboard
							</Link>
						</NavbarLink>
					</>
				)}
			</NavbarCollapse>
		</Navbar>
	)
}
