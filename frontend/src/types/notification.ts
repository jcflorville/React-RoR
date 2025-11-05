import type { User } from "./auth"

export type NotificationEventType =
	| "mention"
	| "task_assigned"
	| "task_completed"
	| "comment_added"
	| "deadline_soon"
	| "project_shared"
	| "task_status_changed"

export interface Notification {
	id: number
	event_type: NotificationEventType
	message: string
	read_at: string | null
	created_at: string
	updated_at: string
	metadata: NotificationMetadata
	actor: User
	notifiable_type: string
	notifiable_id: number
}

export interface NotificationMetadata {
	comment_content?: string
	task_title?: string
	project_name?: string
	old_status?: string
	new_status?: string
	completed_at?: string
	[key: string]: string | undefined
}

export interface NotificationsResponse {
	success: boolean
	data: Notification[]
	message?: string
	pagination?: {
		current_page: number
		total_pages: number
		total_count: number
		per_page: number
	}
}

export interface NotificationResponse {
	success: boolean
	data: Notification
	message?: string
}

export interface UnreadCountResponse {
	success: boolean
	data: {
		unread_count: number
	}
	message?: string
}
