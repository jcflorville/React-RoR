import { api } from "@/lib/api"
import type {
	NotificationsResponse,
	NotificationResponse,
	UnreadCountResponse,
} from "@/types/notification"

const NOTIFICATIONS_URL = "/notifications"

// Get all notifications for current user
export const getNotifications = async (params?: {
	page?: number
	per_page?: number
	unread_only?: boolean
}): Promise<NotificationsResponse> => {
	const queryParams = new URLSearchParams()

	if (params?.page) queryParams.append("page", params.page.toString())
	if (params?.per_page)
		queryParams.append("per_page", params.per_page.toString())
	if (params?.unread_only !== undefined)
		queryParams.append("unread_only", params.unread_only.toString())

	const queryString = queryParams.toString()
	const url = `${NOTIFICATIONS_URL}${queryString ? `?${queryString}` : ""}`

	const response = await api.get<NotificationsResponse>(url)
	return response.data
}

// Get unread count
export const getUnreadCount = async (): Promise<UnreadCountResponse> => {
	const response = await api.get<UnreadCountResponse>(
		`${NOTIFICATIONS_URL}/unread_count`
	)
	return response.data
}

// Mark notification as read
export const markAsRead = async (
	notificationId: number
): Promise<NotificationResponse> => {
	const response = await api.patch<NotificationResponse>(
		`${NOTIFICATIONS_URL}/${notificationId}/mark_as_read`
	)
	return response.data
}

// Mark notification as unread
export const markAsUnread = async (
	notificationId: number
): Promise<NotificationResponse> => {
	const response = await api.patch<NotificationResponse>(
		`${NOTIFICATIONS_URL}/${notificationId}/mark_as_unread`
	)
	return response.data
}

// Mark all as read
export const markAllAsRead = async (): Promise<{ success: boolean }> => {
	const response = await api.post<{ success: boolean }>(
		`${NOTIFICATIONS_URL}/mark_all_as_read`
	)
	return response.data
}

// Delete notification
export const deleteNotification = async (
	notificationId: number
): Promise<{ success: boolean }> => {
	const response = await api.delete<{ success: boolean }>(
		`${NOTIFICATIONS_URL}/${notificationId}`
	)
	return response.data
}
