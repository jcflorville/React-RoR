import { createFileRoute } from "@tanstack/react-router"
import { DashboardLayout } from "@components/layouts/DashboardLayout"
import { Header } from "@/components/projects/Header"
import { Filters } from "@/components/projects/Filters"
import { List } from "@/components/projects/List"
import { ViewModal } from "@/components/projects/modals/ViewModal"
import { type Project } from "@/lib/api/types/project"
import { useState, useMemo } from "react"
import { useProjects, useDeleteProject } from "@/hooks/queries/projects-queries"

export const Route = createFileRoute("/_auth/projects")({
	component: ProjectsPage,
})

function ProjectsPage() {
	const [searchTerm, setSearchTerm] = useState("")
	const [statusFilter, setStatusFilter] = useState<string>("")
	const [priorityFilter, setPriorityFilter] = useState<string>("")
	const [sortBy, setSortBy] = useState<string>("name")

	// Estados do Modal
	const [selectedProjectId, setSelectedProjectId] = useState<number | null>(
		null
	)
	const [isViewModalOpen, setIsViewModalOpen] = useState(false)

	// Função para mapear sortBy para os valores que o backend espera
	const mapSortValue = (
		sortBy: string
	):
		| "name_asc"
		| "name_desc"
		| "priority_desc"
		| "status"
		| "created_at_desc" => {
		switch (sortBy) {
			case "name":
				return "name_asc"
			case "priority":
				return "priority_desc"
			case "status":
				return "status"
			case "created_at":
				return "created_at_desc"
			default:
				return "created_at_desc" // valor padrão
		}
	}

	// TanStack Query - Busca dados da API
	const filters = useMemo(
		() => ({
			search: searchTerm || undefined,
			status: statusFilter || undefined,
			priority: priorityFilter || undefined,
			sort: mapSortValue(sortBy),
		}),
		[searchTerm, statusFilter, priorityFilter, sortBy]
	)

	const { data: projectsResponse, isLoading, error } = useProjects(filters)

	// Mutations para operações CRUD
	const deleteProjectMutation = useDeleteProject()

	// Projects data from API response
	const projects = projectsResponse?.data || []

	const handleCreateProject = () => {
		console.log("Criar projeto")
	}

	const handleDeleteProject = async (project: Project) => {
		if (
			window.confirm(
				`Tem certeza que deseja deletar o projeto "${project.name}"?`
			)
		) {
			try {
				await deleteProjectMutation.mutateAsync(project.id)
			} catch (error) {
				console.error("Erro ao deletar projeto:", error)
			}
		}
	}

	const handleViewProject = (project: Project) => {
		setSelectedProjectId(project.id)
		setIsViewModalOpen(true)
	}

	const handleCloseModal = () => {
		setIsViewModalOpen(false)
		setSelectedProjectId(null)
	}

	const handleEditProject = (project: Project) => {
		// TODO: Navegar para página de edição
		console.log("Editar projeto:", project.id)
		// Fechar modal por enquanto
		handleCloseModal()
	}

	const handleEditFromModal = (projectId: number) => {
		// TODO: Navegar para página de edição
		console.log("Editar projeto:", projectId)
		// Fechar modal por enquanto
		handleCloseModal()
	}

	// Error state
	if (error) {
		return (
			<DashboardLayout>
				<div className='space-y-6'>
					<Header
						searchTerm={searchTerm}
						onSearchChange={setSearchTerm}
						onCreateProject={handleCreateProject}
					/>
					<div className='bg-red-50 border border-red-200 rounded-md p-4'>
						<h3 className='text-red-800 font-medium'>
							Erro ao carregar projetos
						</h3>
						<p className='text-red-600 text-sm mt-1'>
							{error instanceof Error ? error.message : "Erro desconhecido"}
						</p>
						<button
							onClick={() => window.location.reload()}
							className='mt-2 text-red-800 hover:text-red-900 text-sm underline'
						>
							Tentar novamente
						</button>
					</div>
				</div>
			</DashboardLayout>
		)
	}

	// Loading state
	if (isLoading) {
		return (
			<DashboardLayout>
				<div className='space-y-6'>
					<Header
						searchTerm={searchTerm}
						onSearchChange={setSearchTerm}
						onCreateProject={handleCreateProject}
					/>
					<Filters
						status={statusFilter}
						priority={priorityFilter}
						sortBy={sortBy}
						onStatusChange={setStatusFilter}
						onPriorityChange={setPriorityFilter}
						onSortChange={setSortBy}
					/>
					<List
						projects={[]}
						loading={true}
						onEditProject={handleEditProject}
						onDeleteProject={handleDeleteProject}
						onViewProject={handleViewProject}
					/>
				</div>
			</DashboardLayout>
		)
	}

	return (
		<>
			<DashboardLayout>
				<div className='space-y-6'>
					{/* Header */}
					<Header
						searchTerm={searchTerm}
						onSearchChange={setSearchTerm}
						onCreateProject={handleCreateProject}
					/>

					{/* Filters */}
					<Filters
						status={statusFilter}
						priority={priorityFilter}
						sortBy={sortBy}
						onStatusChange={setStatusFilter}
						onPriorityChange={setPriorityFilter}
						onSortChange={setSortBy}
					/>

					{/* Projects List */}
					<List
						projects={projects}
						loading={isLoading}
						onEditProject={handleEditProject}
						onDeleteProject={handleDeleteProject}
						onViewProject={handleViewProject}
					/>
				</div>
			</DashboardLayout>

			{/* Modal */}
			<ViewModal
				isOpen={isViewModalOpen}
				onClose={handleCloseModal}
				projectId={selectedProjectId}
				onEdit={handleEditFromModal}
			/>
		</>
	)
}
