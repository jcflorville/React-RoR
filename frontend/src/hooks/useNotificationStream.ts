import { useEffect, useRef, useState, useCallback } from "react"
import type { Notification } from "@/types/notification"
import { useAuthStore } from "@/stores/auth-store"

interface SSEMessage {
	type: "heartbeat" | "notification"
	timestamp?: string
	data?: Notification
}

interface UseNotificationStreamOptions {
	onNotification?: (notification: Notification) => void
	onError?: (error: Event) => void
	autoConnect?: boolean
}

interface UseNotificationStreamReturn {
	notifications: Notification[]
	isConnected: boolean
	connect: () => void
	disconnect: () => void
	clearNotifications: () => void
}

export const useNotificationStream = (
	options: UseNotificationStreamOptions = {}
): UseNotificationStreamReturn => {
	const { onNotification, onError, autoConnect = true } = options

	const [notifications, setNotifications] = useState<Notification[]>([])
	const [isConnected, setIsConnected] = useState(false)
	const eventSourceRef = useRef<EventSource | null>(null)
	const { token } = useAuthStore()

	const connect = useCallback(() => {
		if (!token) {
			console.warn("No auth token available for SSE connection")
			return
		}

		if (eventSourceRef.current) {
			console.warn("SSE connection already exists")
			return
		}

		try {
			// EventSource doesn't support custom headers natively
			// So we pass token as query param (alternative: use fetch + ReadableStream)
			const url = `${
				import.meta.env.VITE_API_URL
			}/notification_stream?token=${token}`

			const eventSource = new EventSource(url)
			eventSourceRef.current = eventSource

			// Connection opened
			eventSource.onopen = () => {
				console.log("SSE connection established")
				setIsConnected(true)
			}

			// Listen for heartbeat
			eventSource.addEventListener("ping", (event) => {
				const data = JSON.parse(event.data) as SSEMessage
				console.log("Heartbeat received:", data.timestamp)
			})

			// Listen for notifications
			eventSource.addEventListener("notification", (event) => {
				const notification = JSON.parse(event.data) as Notification
				console.log("Notification received:", notification)

				setNotifications((prev) => [notification, ...prev])

				// Call callback if provided
				if (onNotification) {
					onNotification(notification)
				}
			})

			// Error handler
			eventSource.onerror = (error) => {
				console.error("SSE connection error:", error)
				setIsConnected(false)

				if (onError) {
					onError(error)
				}

				// Auto-reconnect after 5 seconds
				setTimeout(() => {
					if (eventSourceRef.current) {
						eventSourceRef.current.close()
						eventSourceRef.current = null
					}
					connect()
				}, 5000)
			}
		} catch (error) {
			console.error("Failed to establish SSE connection:", error)
			setIsConnected(false)
		}
	}, [token, onNotification, onError])

	const disconnect = useCallback(() => {
		if (eventSourceRef.current) {
			console.log("Closing SSE connection")
			eventSourceRef.current.close()
			eventSourceRef.current = null
			setIsConnected(false)
		}
	}, [])

	const clearNotifications = useCallback(() => {
		setNotifications([])
	}, [])

	// Auto-connect on mount if enabled
	useEffect(() => {
		if (autoConnect && token) {
			connect()
		}

		// Cleanup on unmount
		return () => {
			disconnect()
		}
	}, [autoConnect, token, connect, disconnect])

	return {
		notifications,
		isConnected,
		connect,
		disconnect,
		clearNotifications,
	}
}
