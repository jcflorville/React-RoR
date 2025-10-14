import { z } from "zod"

export const taskSchema = z.object({
	title: z
		.string()
		.min(2, "Title must be at least 2 characters")
		.max(200, "Title cannot exceed 200 characters"),
	description: z
		.string()
		.max(2000, "Description cannot exceed 2000 characters")
		.optional()
		.or(z.literal("")),
	status: z.enum(["todo", "in_progress", "completed", "blocked"]).optional(),
	priority: z.enum(["low", "medium", "high", "urgent"]).optional(),
	due_date: z
		.string()
		.optional()
		.refine(
			(date) => {
				if (!date || date === "") return true
				const selectedDate = new Date(date)
				const today = new Date()
				today.setHours(0, 0, 0, 0)

				// Check if date is valid and not in the past
				if (isNaN(selectedDate.getTime())) return false

				return selectedDate >= today
			},
			{ message: "Due date cannot be in the past" }
		),
	user_id: z.number().optional(),
})

export type TaskFormData = z.infer<typeof taskSchema>

// Default values for form
export const taskDefaultValues: Partial<TaskFormData> = {
	title: "",
	description: "",
	status: "todo",
	priority: "medium",
	due_date: "",
}
