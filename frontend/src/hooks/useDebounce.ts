import { useEffect, useRef } from "react"

/**
 * Hook to debounce a callback function
 * Returns a debounced version of the callback that delays execution
 */
export function useDebounce<T extends (...args: any[]) => void>(
	callback: T,
	delay: number,
): T {
	const timeoutRef = useRef<NodeJS.Timeout>()
	const callbackRef = useRef(callback)

	// Update callback ref when it changes
	useEffect(() => {
		callbackRef.current = callback
	}, [callback])

	// Cleanup timeout on unmount
	useEffect(() => {
		return () => {
			if (timeoutRef.current) {
				clearTimeout(timeoutRef.current)
			}
		}
	}, [])

	const debouncedCallback = ((...args: Parameters<T>) => {
		if (timeoutRef.current) {
			clearTimeout(timeoutRef.current)
		}

		timeoutRef.current = setTimeout(() => {
			callbackRef.current(...args)
		}, delay)
	}) as T

	return debouncedCallback
}
