// Modal único para Create e Edit de Project
import { Modal } from "flowbite-react"
import { ModalHeader, ModalBody } from "flowbite-react"
import { ProjectForm } from "../forms/ProjectForm"
import { customModalTheme } from "@/lib/flowbite-theme"
import { type Project } from "@/lib/api/types/project"
import type { ProjectFormData } from "@/lib/validations/project"
import {
	useCreateProject,
	useUpdateProject,
} from "@/hooks/queries/projects-queries"
import { toast } from "react-hot-toast"

interface FormModalProps {
	mode: "create" | "edit"
	isOpen: boolean
	onClose: () => void
	onSuccess?: (projectId: number) => void
	project?: Project
}

export function FormModal({
	mode,
	isOpen,
	onClose,
	onSuccess,
	project,
}: FormModalProps) {
	const createProjectMutation = useCreateProject()
	const updateProjectMutation = useUpdateProject()

	const isLoading =
		createProjectMutation.isPending || updateProjectMutation.isPending

	const handleSubmit = async (data: ProjectFormData) => {
		try {
			if (mode === "create") {
				const result = await createProjectMutation.mutateAsync({
					name: data.name,
					description: data.description || undefined,
					status: data.status,
					priority: data.priority,
					start_date: data.start_date || undefined,
					end_date: data.end_date || undefined,
					category_ids: data.category_ids,
				})

				toast.success("Project created successfully!")
				onClose()

				// Chamar callback de sucesso com o ID do projeto criado
				if (onSuccess && result.data) {
					onSuccess(result.data.id)
				}
			} else if (mode === "edit" && project) {
				await updateProjectMutation.mutateAsync({
					id: project.id,
					name: data.name,
					description: data.description || undefined,
					status: data.status,
					priority: data.priority,
					start_date: data.start_date || undefined,
					end_date: data.end_date || undefined,
					category_ids: data.category_ids,
				})

				toast.success("Project updated successfully!")
				onClose()
			}
		} catch (error) {
			const errorMessage =
				error instanceof Error ? error.message : "An error occurred"
			toast.error(errorMessage)
		}
	}

	return (
		<Modal
			show={isOpen}
			onClose={onClose}
			size='2xl'
			theme={customModalTheme.modal}
		>
			<ModalHeader>
				{mode === "create" ? "Create New Project" : "Edit Project"}
			</ModalHeader>

			<ModalBody>
				<ProjectForm
					initialData={mode === "edit" ? project : undefined}
					onSubmit={handleSubmit}
					isLoading={isLoading}
					submitLabel={mode === "create" ? "Create Project" : "Save Changes"}
				/>
			</ModalBody>
		</Modal>
	)
}
