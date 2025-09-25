// frontend/src/components/layouts/components/Sidebar.tsx
import { Link } from "@tanstack/react-router"
import {
	Sidebar,
	SidebarItem,
	SidebarItemGroup,
	SidebarItems,
} from "flowbite-react"
import { useLogoutMutation } from "@hooks/queries/auth-queries"

interface DashboardSidebarProps {
	collapsed: boolean
}

export const DashboardSidebar = ({ collapsed }: DashboardSidebarProps) => {
	const logoutMutation = useLogoutMutation()

	const handleLogout = () => {
		logoutMutation.mutate()
	}

	return (
		<Sidebar className='h-full overflow-hidden'>
			<SidebarItems>
				<SidebarItemGroup>
					{/* ✅ CORREÇÃO: Usar as prop do SidebarItem ao invés de Link aninhado */}
					<SidebarItem
						as={Link}
						to='/dashboard'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path d='M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z' />
							</svg>
						)}
					>
						{!collapsed && "Dashboard"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/profile'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path
									fillRule='evenodd'
									d='M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && "Profile"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/projects'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path d='M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z' />
							</svg>
						)}
					>
						{!collapsed && "Projects"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/documents'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path
									fillRule='evenodd'
									d='M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && "Documents"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/notifications'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path d='M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6zM10 18a3 3 0 01-3-3h6a3 3 0 01-3 3z' />
							</svg>
						)}
					>
						{!collapsed && "Notifications"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/kanban'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path
									fillRule='evenodd'
									d='M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3zm11.707 4.707a1 1 0 00-1.414-1.414L10 9.586 8.707 8.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && "Kanban"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/inbox'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path
									fillRule='evenodd'
									d='M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && "Inbox"}
					</SidebarItem>

					<SidebarItem
						as={Link}
						to='/dashboard/users'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path
									fillRule='evenodd'
									d='M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-6-3a2 2 0 11-4 0 2 2 0 014 0zm-2 4a5 5 0 00-4.546 2.916A5.986 5.986 0 0010 16a5.986 5.986 0 004.546-2.084A5 5 0 0010 11z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && "Users"}
					</SidebarItem>
				</SidebarItemGroup>

				<SidebarItemGroup>
					<SidebarItem
						as={Link}
						to='/dashboard/settings'
						icon={() => (
							<svg className='w-5 h-5' fill='currentColor' viewBox='0 0 20 20'>
								<path
									fillRule='evenodd'
									d='M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 01-2.286.948c-1.372-.836-2.942.734-2.106 2.106.54.886.061 2.042-.947 2.287-1.561.379-1.561 2.6 0 2.978a1.532 1.532 0 01.947 2.287c-.836 1.372.734 2.942 2.106 2.106a1.532 1.532 0 012.287.947c.379 1.561 2.6 1.561 2.978 0a1.533 1.533 0 012.287-.947c1.372.836 2.942-.734 2.106-2.106a1.533 1.533 0 01.947-2.287c1.561-.379 1.561-2.6 0-2.978a1.532 1.532 0 01-.947-2.287c.836-1.372-.734-2.942-2.106-2.106a1.532 1.532 0 01-2.287-.947zM10 13a3 3 0 100-6 3 3 0 000 6z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && "Settings"}
					</SidebarItem>

					{/* ✅ CORREÇÃO: Usar onClick para logout ao invés de Link */}
					<SidebarItem
						onClick={handleLogout}
						className='cursor-pointer hover:bg-red-50 dark:hover:bg-red-900/20'
						icon={() => (
							<svg
								className='w-5 h-5 text-red-600'
								fill='currentColor'
								viewBox='0 0 20 20'
							>
								<path
									fillRule='evenodd'
									d='M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z'
									clipRule='evenodd'
								/>
							</svg>
						)}
					>
						{!collapsed && (
							<span className='text-red-600'>
								{logoutMutation.isPending ? "Signing out..." : "Sign Out"}
							</span>
						)}
					</SidebarItem>
				</SidebarItemGroup>
			</SidebarItems>
		</Sidebar>
	)
}
