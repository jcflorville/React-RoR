import { Link } from "@tanstack/react-router"
import {
	Avatar,
	Button,
	Dropdown,
	DropdownDivider,
	DropdownHeader,
	DropdownItem,
	Navbar,
	NavbarBrand,
	NavbarCollapse,
	NavbarLink,
	NavbarToggle,
	DarkThemeToggle,
} from "flowbite-react"

// ✨ Imports limpos com path aliases
import { useAuth } from "@hooks/use-auth"
import { useLogoutMutation } from "@hooks/queries/auth-queries"

export const AppHeader = () => {
	const { user, isAuthenticated, isLoading } = useAuth()
	const logoutMutation = useLogoutMutation()

	const handleLogout = () => {
		logoutMutation.mutate()
	}

	const renderAuthSection = () => {
		// Loading state
		if (isLoading) {
			return (
				<div className='flex items-center space-x-2'>
					<div className='animate-pulse'>
						<div className='h-8 w-8 bg-gray-300 rounded-full'></div>
					</div>
				</div>
			)
		}

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
						<span className='block text-sm font-medium'>{user.name}</span>
						<span className='block truncate text-sm text-gray-500'>
							{user.email}
						</span>
					</DropdownHeader>
					<DropdownItem as={Link} to='/dashboard'>
						Dashboard
					</DropdownItem>
					<DropdownItem as={Link} to='/profile'>
						Profile
					</DropdownItem>
					<DropdownItem as={Link} to='/settings'>
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
			)
		}

		// Not authenticated
		return (
			<div className='flex items-center space-x-2'>
				<Button
					as={Link}
					to='/login'
					color='gray'
					size='sm'
					className='border-gray-300 hover:bg-gray-50'
				>
					Sign In
				</Button>
				<Button as={Link} to='/register' color='blue' size='sm'>
					Sign Up
				</Button>
			</div>
		)
	}

	return (
		<Navbar fluid rounded>
			<NavbarBrand>
				<Link to='/' className='flex items-center'>
					<img src='/vite.svg' className='mr-3 h-6 sm:h-9' alt='Logo' />
					<span className='self-center whitespace-nowrap text-xl font-semibold dark:text-white'>
						React-RoR
					</span>
				</Link>
			</NavbarBrand>

			<div className='flex md:order-2'>
				<div className='mr-4 flex items-center'>
					<DarkThemeToggle />
				</div>

				{renderAuthSection()}

				<NavbarToggle />
			</div>

			<NavbarCollapse>
				<NavbarLink>
					<Link
						to='/'
						className='[&.active]:text-cyan-700 hover:text-cyan-600 transition-colors'
					>
						Home
					</Link>
				</NavbarLink>

				<NavbarLink>
					<Link
						to='/about'
						className='[&.active]:text-cyan-700 hover:text-cyan-600 transition-colors'
					>
						About
					</Link>
				</NavbarLink>

				{isAuthenticated && (
					<>
						<NavbarLink>
							<Link
								to='/dashboard'
								className='[&.active]:text-cyan-700 hover:text-cyan-600 transition-colors'
							>
								Dashboard
							</Link>
						</NavbarLink>
						<NavbarLink>
							<Link
								to='/profile'
								className='[&.active]:text-cyan-700 hover:text-cyan-600 transition-colors'
							>
								Profile
							</Link>
						</NavbarLink>
					</>
				)}
			</NavbarCollapse>
		</Navbar>
	)
}
