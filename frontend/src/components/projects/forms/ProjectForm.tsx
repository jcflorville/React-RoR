// Formulário compartilhado de Project (usado em Create e Edit)
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { Button, Label, TextInput, Textarea, Select } from "flowbite-react"
import { projectSchema, type ProjectFormData } from "@/lib/validations/project"
import { type Project } from "@/lib/api/types/project"
import { useCategories } from "@/hooks/queries/categories-queries"
import { useState } from "react"

interface ProjectFormProps {
	initialData?: Partial<Project>
	onSubmit: (data: ProjectFormData) => void
	isLoading?: boolean
	submitLabel: string
}

export function ProjectForm({
	initialData,
	onSubmit,
	isLoading = false,
	submitLabel,
}: ProjectFormProps) {
	const { data: categoriesResponse, isLoading: loadingCategories } =
		useCategories()
	const categories = categoriesResponse?.data || []

	// Selected categories state (for multiselect)
	const [selectedCategories, setSelectedCategories] = useState<number[]>(
		initialData?.categories?.map((c) => c.id) || []
	)

	const {
		register,
		handleSubmit,
		formState: { errors },
	} = useForm<ProjectFormData>({
		resolver: zodResolver(projectSchema) as any,
		defaultValues: {
			name: initialData?.name || "",
			description: initialData?.description || "",
			status: (initialData?.status || "draft") as ProjectFormData["status"],
			priority: (initialData?.priority ||
				"medium") as ProjectFormData["priority"],
			start_date: initialData?.start_date || "",
			end_date: initialData?.end_date || "",
			category_ids: selectedCategories,
		},
	})

	const onFormSubmit = (data: ProjectFormData) => {
		// Incluir category_ids selecionados
		onSubmit({
			...data,
			category_ids: selectedCategories,
		})
	}

	const toggleCategory = (categoryId: number) => {
		setSelectedCategories((prev) =>
			prev.includes(categoryId)
				? prev.filter((id) => id !== categoryId)
				: [...prev, categoryId]
		)
	}

	return (
		<form onSubmit={handleSubmit(onFormSubmit)} className='space-y-4'>
			{/* Project Name */}
			<div>
				<Label htmlFor='name'>Project Name *</Label>
				<TextInput
					id='name'
					type='text'
					placeholder='Enter project name'
					{...register("name")}
					color={errors.name ? "failure" : "gray"}
				/>
				{errors.name && (
					<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
						{errors.name.message}
					</p>
				)}
			</div>

			{/* Description */}
			<div>
				<Label htmlFor='description'>Description</Label>
				<Textarea
					id='description'
					placeholder='Enter project description'
					rows={4}
					{...register("description")}
					color={errors.description ? "failure" : "gray"}
				/>
				{errors.description && (
					<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
						{errors.description.message}
					</p>
				)}
			</div>

			{/* Status and Priority Row */}
			<div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
				{/* Status */}
				<div>
					<Label htmlFor='status'>Status</Label>
					<Select id='status' {...register("status")}>
						<option value='draft'>Draft</option>
						<option value='active'>Active</option>
						<option value='completed'>Completed</option>
						<option value='archived'>Archived</option>
					</Select>
				</div>

				{/* Priority */}
				<div>
					<Label htmlFor='priority'>Priority</Label>
					<Select id='priority' {...register("priority")}>
						<option value='low'>Low</option>
						<option value='medium'>Medium</option>
						<option value='high'>High</option>
						<option value='urgent'>Urgent</option>
					</Select>
				</div>
			</div>

			{/* Dates Row */}
			<div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
				{/* Start Date */}
				<div>
					<Label htmlFor='start_date'>Start Date</Label>
					<TextInput
						id='start_date'
						type='date'
						{...register("start_date")}
						color={errors.start_date ? "failure" : "gray"}
					/>
					{errors.start_date && (
						<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
							{errors.start_date.message}
						</p>
					)}
				</div>

				{/* End Date */}
				<div>
					<Label htmlFor='end_date'>End Date</Label>
					<TextInput
						id='end_date'
						type='date'
						{...register("end_date")}
						color={errors.end_date ? "failure" : "gray"}
					/>
					{errors.end_date && (
						<p className='mt-1 text-sm text-red-600 dark:text-red-400'>
							{errors.end_date.message}
						</p>
					)}
				</div>
			</div>

			{/* Categories */}
			<div>
				<Label>Categories</Label>
				{loadingCategories ? (
					<div className='text-sm text-gray-500 dark:text-gray-400'>
						Loading categories...
					</div>
				) : categories.length === 0 ? (
					<div className='text-sm text-gray-500 dark:text-gray-400'>
						No categories available
					</div>
				) : (
					<div className='flex flex-wrap gap-2 mt-2'>
						{categories.map((category) => (
							<button
								key={category.id}
								type='button'
								onClick={() => toggleCategory(category.id)}
								className={`
									inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium
									transition-all duration-200 border-2
									${
										selectedCategories.includes(category.id)
											? "border-current opacity-100"
											: "border-gray-300 dark:border-gray-600 opacity-60 hover:opacity-80"
									}
								`}
								style={{
									backgroundColor: selectedCategories.includes(category.id)
										? category.color + "20"
										: "transparent",
									color: category.color,
								}}
							>
								{selectedCategories.includes(category.id) && "✓ "}
								{category.name}
							</button>
						))}
					</div>
				)}
			</div>

			{/* Submit Button */}
			<div className='flex justify-end gap-3 pt-4 border-t border-gray-200 dark:border-gray-700'>
				<Button type='submit' disabled={isLoading}>
					{isLoading ? "Saving..." : submitLabel}
				</Button>
			</div>
		</form>
	)
}
