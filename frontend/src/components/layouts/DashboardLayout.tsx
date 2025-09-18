import type { ReactNode } from "react"
import { useState } from "react"
import { DashboardHeader } from "./components/DashboardHeader"
import { DashboardSidebar } from "./components/Sidebar"

interface DashboardLayoutProps {
	children: ReactNode
}

export const DashboardLayout = ({ children }: DashboardLayoutProps) => {
	const [sidebarCollapsed, setSidebarCollapsed] = useState(false)

	const toggleSidebar = () => {
		console.log("Toggle sidebar clicked, current state:", sidebarCollapsed)
		setSidebarCollapsed(!sidebarCollapsed)
	}

	return (
		<div className='min-h-screen bg-gray-50 dark:bg-gray-900'>
			{/* Header */}
			<DashboardHeader onToggleSidebar={toggleSidebar} />

			<div className='flex pt-16'>
				{/* Sidebar */}
				<div
					className={`hidden lg:flex lg:flex-col lg:fixed lg:top-16 lg:bottom-0 lg:left-0 transition-all duration-300 ${
						sidebarCollapsed ? "lg:w-16" : "lg:w-64"
					}`}
				>
					<div className='flex-1 flex flex-col min-h-0 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700'>
						<div className='flex-1 flex flex-col overflow-y-auto'>
							<DashboardSidebar collapsed={sidebarCollapsed} />
						</div>
					</div>
				</div>

				{/* Main content */}
				<div
					className={`flex-1 flex flex-col transition-all duration-300 ${
						sidebarCollapsed ? "lg:pl-16" : "lg:pl-64"
					}`}
				>
					<main className='flex-1 p-4 lg:p-8'>
						<div className='max-w-7xl mx-auto'>{children}</div>
					</main>
				</div>
			</div>

			{/* Mobile sidebar overlay */}
			<div className='lg:hidden'>
				{/* This would be for mobile sidebar overlay - can be implemented with state management */}
			</div>
		</div>
	)
}
