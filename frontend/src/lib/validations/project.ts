// Validação Zod para Projects
import { z } from "zod"

// Schema para criação e edição de projeto
export const projectSchema = z
	.object({
		name: z
			.string()
			.min(1, "Project name is required")
			.min(2, "Project name must be at least 2 characters")
			.max(100, "Project name must be at most 100 characters"),
		description: z
			.string()
			.max(2000, "Description must be at most 2000 characters")
			.optional()
			.or(z.literal("")),
		status: z
			.enum(["draft", "active", "completed", "archived"])
			.default("draft"),
		priority: z.enum(["low", "medium", "high", "urgent"]).default("medium"),
		start_date: z.string().optional().or(z.literal("")),
		end_date: z.string().optional().or(z.literal("")),
		category_ids: z.array(z.number()).optional().default([]),
	})
	.refine(
		(data) => {
			// Validação: end_date deve ser depois de start_date
			if (data.start_date && data.end_date) {
				const startDate = new Date(data.start_date)
				const endDate = new Date(data.end_date)
				return endDate >= startDate
			}
			return true
		},
		{
			message: "End date must be after start date",
			path: ["end_date"],
		}
	)

// Tipos TypeScript automáticos
export type ProjectFormData = z.infer<typeof projectSchema>
