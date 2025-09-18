import { Link } from "@tanstack/react-router"
import {
	Navbar,
	NavbarBrand,
	NavbarCollapse,
	NavbarLink,
	NavbarToggle,
} from "flowbite-react"

export const AppHeader = () => {
	return (
		<Navbar fluid rounded className='border-b'>
			<NavbarBrand>
				<Link to='/' className='flex items-center'>
					<img src='/vite.svg' className='mr-3 h-6 sm:h-9' alt='Logo' />
					<span className='self-center whitespace-nowrap text-xl font-semibold dark:text-white'>
						React-RoR
					</span>
				</Link>
			</NavbarBrand>

			<NavbarToggle />

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

				<div className='flex items-center gap-2 mt-2 lg:mt-0'>
					<Link
						to='/sign-in'
						className='text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 transition-colors'
					>
						Sign In
					</Link>
					<Link
						to='/sign-up'
						className='bg-cyan-700 hover:bg-cyan-800 text-white px-4 py-2 rounded-lg transition-colors'
					>
						Sign Up
					</Link>
				</div>
			</NavbarCollapse>
		</Navbar>
	)
}
