import { Link } from "@tanstack/react-router"
import {
	Avatar,
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

export const AppHeader = () => {
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
						<span className='block text-sm'>Bonnie Green</span>
						<span className='block truncate text-sm font-medium'>
							name@flowbite.com
						</span>
					</DropdownHeader>
					<DropdownItem>Dashboard</DropdownItem>
					<DropdownItem>Settings</DropdownItem>
					<DropdownItem>Earnings</DropdownItem>
					<DropdownDivider />
					<DropdownItem>Sign out</DropdownItem>
				</Dropdown>
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
			</NavbarCollapse>
		</Navbar>
	)
}
