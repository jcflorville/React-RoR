import { Link } from "@tanstack/react-router"
import {
	HiUser,
	HiCheckCircle,
	HiChat,
	HiExclamation,
	HiShare,
	HiRefresh,
	HiX,
} from "react-icons/hi"
import {
	useMarkAsRead,
	useDeleteNotification,
} from "@/hooks/queries/notifications-queries"
import type { Notification } from "@/types/notification"

interface NotificationItemProps {
	notification: Notification
	onClick?: () => void
}

// Helper to get icon based on event type
const getNotificationIcon = (eventType: string) => {
	const iconClass = "w-5 h-5"

	switch (eventType) {
		case "mention":
		case "task_assigned":
			return <HiUser className={iconClass} />
		case "task_completed":
			return <HiCheckCircle className={iconClass} />
		case "comment_added":
			return <HiChat className={iconClass} />
		case "deadline_soon":
			return <HiExclamation className={iconClass} />
		case "project_shared":
			return <HiShare className={iconClass} />
		case "task_status_changed":
			return <HiRefresh className={iconClass} />
		default:
			return <HiExclamation className={iconClass} />
	}
}

// Helper to format time ago (simple implementation)
const formatTimeAgo = (dateString: string): string => {
	const date = new Date(dateString)
	const now = new Date()
	const seconds = Math.floor((now.getTime() - date.getTime()) / 1000)

	if (seconds < 60) return "just now"
	const minutes = Math.floor(seconds / 60)
	if (minutes < 60) return `${minutes}m ago`
	const hours = Math.floor(minutes / 60)
	if (hours < 24) return `${hours}h ago`
	const days = Math.floor(hours / 24)
	if (days < 7) return `${days}d ago`
	const weeks = Math.floor(days / 7)
	return `${weeks}w ago`
}

// Helper to get notification link
const getNotificationLink = (notification: Notification): string => {
	const { notifiable_type, notifiable_id } = notification

	switch (notifiable_type) {
		case "Task":
			return `/tasks/${notifiable_id}`
		case "Comment":
			// Navigate to task containing the comment
			return `/tasks/${notification.metadata?.task_id || ""}`
		case "Project":
			return `/projects/${notifiable_id}`
		default:
			return "/notifications"
	}
}

export const NotificationItem = ({
	notification,
	onClick,
}: NotificationItemProps) => {
	const markAsReadMutation = useMarkAsRead()
	const deleteMutation = useDeleteNotification()

	const handleClick = () => {
		if (!notification.read_at) {
			markAsReadMutation.mutate(notification.id)
		}
		onClick?.()
	}

	const handleDelete = (e: React.MouseEvent) => {
		e.preventDefault()
		e.stopPropagation()
		deleteMutation.mutate(notification.id)
	}

	const iconColorClass = notification.read_at
		? "text-gray-400 dark:text-gray-500"
		: "text-blue-600 dark:text-blue-400"

	return (
		<Link
			to={getNotificationLink(notification)}
			onClick={handleClick}
			className={`block p-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors relative group ${
				notification.read_at ? "opacity-75" : ""
			}`}
		>
			<div className='flex items-start gap-3'>
				{/* Icon */}
				<div className={`flex-shrink-0 ${iconColorClass}`}>
					{getNotificationIcon(notification.event_type)}
				</div>

				{/* Content */}
				<div className='flex-1 min-w-0'>
					<p className='text-sm text-gray-900 dark:text-white'>
						<span className='font-medium'>{notification.actor.name}</span>{" "}
						{notification.message}
					</p>
					<p className='text-xs text-gray-500 dark:text-gray-400 mt-1'>
						{formatTimeAgo(notification.created_at)}
					</p>
				</div>

				{/* Unread indicator & delete button */}
				<div className='flex-shrink-0 flex items-center gap-2'>
					{!notification.read_at && (
						<div className='w-2 h-2 bg-blue-600 dark:bg-blue-400 rounded-full' />
					)}
					<button
						onClick={handleDelete}
						className='opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-600 dark:hover:text-red-400 transition-opacity'
						title='Delete notification'
					>
						<HiX className='w-4 h-4' />
					</button>
				</div>
			</div>
		</Link>
	)
}
