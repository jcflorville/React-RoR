import { useEffect, useRef } from "react"
import {
	useNotifications,
	useMarkAllAsRead,
} from "@/hooks/queries/notifications-queries"
import { NotificationItem } from "./NotificationItem"

interface NotificationDropdownProps {
	onClose: () => void
}

export const NotificationDropdown = ({
	onClose,
}: NotificationDropdownProps) => {
	const dropdownRef = useRef<HTMLDivElement>(null)
	const { data, isLoading } = useNotifications({
		per_page: 10,
		unread_only: false,
	})
	const markAllAsReadMutation = useMarkAllAsRead()

	const notifications = data?.data || []
	const hasNotifications = notifications.length > 0

	// Close dropdown when clicking outside
	useEffect(() => {
		const handleClickOutside = (event: MouseEvent) => {
			if (
				dropdownRef.current &&
				!dropdownRef.current.contains(event.target as Node)
			) {
				onClose()
			}
		}

		document.addEventListener("mousedown", handleClickOutside)
		return () => document.removeEventListener("mousedown", handleClickOutside)
	}, [onClose])

	const handleMarkAllAsRead = () => {
		markAllAsReadMutation.mutate()
	}

	return (
		<div
			ref={dropdownRef}
			className='absolute right-0 mt-2 w-96 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 z-50'
		>
			{/* Header */}
			<div className='flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700'>
				<h3 className='text-lg font-semibold text-gray-900 dark:text-white'>
					Notifications
				</h3>
				{hasNotifications && (
					<button
						onClick={handleMarkAllAsRead}
						disabled={markAllAsReadMutation.isPending}
						className='text-sm text-blue-600 dark:text-blue-400 hover:underline disabled:opacity-50'
					>
						Mark all read
					</button>
				)}
			</div>

			{/* List */}
			<div className='max-h-96 overflow-y-auto'>
				{isLoading ? (
					<div className='p-8 text-center text-gray-500 dark:text-gray-400'>
						Loading...
					</div>
				) : !hasNotifications ? (
					<div className='p-8 text-center text-gray-500 dark:text-gray-400'>
						No notifications yet
					</div>
				) : (
					<div className='divide-y divide-gray-200 dark:divide-gray-700'>
						{notifications.map((notification) => (
							<NotificationItem
								key={notification.id}
								notification={notification}
								onClick={() => onClose()}
							/>
						))}
					</div>
				)}
			</div>

			{/* Footer */}
			{hasNotifications && (
				<div className='p-3 border-t border-gray-200 dark:border-gray-700'>
					<button
						onClick={onClose}
						className='w-full text-center text-sm text-blue-600 dark:text-blue-400 hover:underline'
					>
						View all notifications
					</button>
				</div>
			)}
		</div>
	)
}
