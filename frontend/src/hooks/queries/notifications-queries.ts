import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import {
	getNotifications,
	getUnreadCount,
	markAsRead,
	markAsUnread,
	markAllAsRead,
	deleteNotification,
} from "@/lib/api/services/notifications"
import toast from "react-hot-toast"

// Query Keys
export const notificationsKeys = {
	all: ["notifications"] as const,
	lists: () => [...notificationsKeys.all, "list"] as const,
	list: (params?: {
		page?: number
		per_page?: number
		unread_only?: boolean
	}) => [...notificationsKeys.lists(), params] as const,
	unreadCount: () => [...notificationsKeys.all, "unread-count"] as const,
}

// Hooks

// Get all notifications
export const useNotifications = (params?: {
	page?: number
	per_page?: number
	unread_only?: boolean
}) => {
	return useQuery({
		queryKey: notificationsKeys.list(params),
		queryFn: () => getNotifications(params),
	})
}

// Get unread count
export const useUnreadCount = () => {
	return useQuery({
		queryKey: notificationsKeys.unreadCount(),
		queryFn: getUnreadCount,
		refetchInterval: 30000, // Refetch every 30s as fallback
	})
}

// Mark as read mutation
export const useMarkAsRead = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: markAsRead,
		onSuccess: () => {
			// Invalidate notifications and unread count
			queryClient.invalidateQueries({ queryKey: notificationsKeys.all })
		},
		onError: () => {
			toast.error("Failed to mark notification as read")
		},
	})
}

// Mark as unread mutation
export const useMarkAsUnread = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: markAsUnread,
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: notificationsKeys.all })
		},
		onError: () => {
			toast.error("Failed to mark notification as unread")
		},
	})
}

// Mark all as read mutation
export const useMarkAllAsRead = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: markAllAsRead,
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: notificationsKeys.all })
			toast.success("All notifications marked as read")
		},
		onError: () => {
			toast.error("Failed to mark all as read")
		},
	})
}

// Delete notification mutation
export const useDeleteNotification = () => {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: deleteNotification,
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: notificationsKeys.all })
			toast.success("Notification deleted")
		},
		onError: () => {
			toast.error("Failed to delete notification")
		},
	})
}
