import { HiBell } from "react-icons/hi"
import { useState } from "react"
import { useUnreadCount } from "@/hooks/queries/notifications-queries"
import { NotificationDropdown } from "./NotificationDropdown"

export const NotificationBell = () => {
	const [isOpen, setIsOpen] = useState(false)
	const { data: unreadData } = useUnreadCount()

	const unreadCount = unreadData?.data?.unread_count || 0
	const hasUnread = unreadCount > 0

	return (
		<div className='relative'>
			<button
				onClick={() => setIsOpen(!isOpen)}
				className='relative p-2 text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700'
				aria-label='Notifications'
			>
				<HiBell className='w-6 h-6' />

				{/* Badge with unread count */}
				{hasUnread && (
					<span className='absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full min-w-[20px]'>
						{unreadCount > 99 ? "99+" : unreadCount}
					</span>
				)}
			</button>

			{/* Dropdown */}
			{isOpen && <NotificationDropdown onClose={() => setIsOpen(false)} />}
		</div>
	)
}
