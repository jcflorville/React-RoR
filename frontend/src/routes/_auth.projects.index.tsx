import { createFileRoute, useNavigate } from "@tanstack/react-router"
import { DashboardLayout } from "@components/layouts/DashboardLayout"
import { Header } from "@/components/projects/Header"
import { Filters } from "@/components/projects/Filters"
import { List } from "@/components/projects/List"
import { ViewModal } from "@/components/projects/modals/ViewModal"
import { FormModal } from "@/components/projects/modals/FormModal"
import { type Project } from "@/lib/api/types/project"
import { useState, useMemo, useEffect } from "react"
import {
	useInfiniteProjects,
	useDeleteProject,
	projectsKeys,
} from "@/hooks/queries/projects-queries"
import { useInView } from "react-intersection-observer"
import { useQueryClient } from "@tanstack/react-query"
import { projectsApi } from "@/lib/api/services/projects"

export const Route = createFileRoute("/_auth/projects/")({
	component: ProjectsIndexPage,
})

function ProjectsIndexPage() {
	const navigate = useNavigate()
	const queryClient = useQueryClient()
	const [searchTerm, setSearchTerm] = useState("")
	const [statusFilter, setStatusFilter] = useState<string>("")
	const [priorityFilter, setPriorityFilter] = useState<string>("")
	const [sortBy, setSortBy] = useState<string>("name")

	const [selectedProjectId, setSelectedProjectId] = useState<number | null>(
		null
	)
	const [isViewModalOpen, setIsViewModalOpen] = useState(false)
	const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)

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
				return "created_at_desc"
		}
	}

	const filters = useMemo(
		() => ({
			search: searchTerm || undefined,
			status: statusFilter || undefined,
			priority: priorityFilter || undefined,
			sort: mapSortValue(sortBy),
		}),
		[searchTerm, statusFilter, priorityFilter, sortBy]
	)

	const {
		data,
		isLoading,
		error,
		fetchNextPage,
		hasNextPage,
		isFetchingNextPage,
	} = useInfiniteProjects(filters, 10)

	const { ref, inView } = useInView({
		threshold: 0,
		rootMargin: "100px",
	})

	useEffect(() => {
		if (inView && hasNextPage && !isFetchingNextPage) {
			fetchNextPage()
		}
	}, [inView, hasNextPage, isFetchingNextPage, fetchNextPage])

	const deleteProjectMutation = useDeleteProject()

	const projects = data?.pages.flatMap((page) => page.data) || []

	const handleCreateProject = () => {
		setIsCreateModalOpen(true)
	}

	const handleCloseCreateModal = () => {
		setIsCreateModalOpen(false)
	}

	const handleCreateSuccess = (projectId: number) => {
		navigate({
			to: "/projects/$id/edit",
			params: { id: projectId.toString() },
		})
	}

	const handleDeleteProject = async (project: Project) => {
		if (
			window.confirm(
				`Are you sure you want to delete the project "${project.name}"?`
			)
		) {
			try {
				await deleteProjectMutation.mutateAsync(project.id)
			} catch (error) {
				console.error("Error deleting project:", error)
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
		queryClient.prefetchQuery({
			queryKey: projectsKeys.detail(project.id),
			queryFn: () => projectsApi.getById(project.id),
		})

		navigate({
			to: "/projects/$id/edit",
			params: { id: project.id.toString() },
		})
	}

	const handleEditFromModal = (projectId: number) => {
		queryClient.prefetchQuery({
			queryKey: projectsKeys.detail(projectId),
			queryFn: () => projectsApi.getById(projectId),
		})

		navigate({
			to: "/projects/$id/edit",
			params: { id: projectId.toString() },
		})
		handleCloseModal()
	}

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
						projects={projects}
						loading={isLoading}
						onEditProject={handleEditProject}
						onDeleteProject={handleDeleteProject}
						onViewProject={handleViewProject}
					/>

					<div ref={ref} className='flex items-center justify-center py-8'>
						{isFetchingNextPage && (
							<div className='flex items-center gap-2'>
								<div className='animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500' />
								<span className='text-sm text-gray-600'>
									Loading more projects...
								</span>
							</div>
						)}
						{!hasNextPage && projects.length > 0 && (
							<p className='text-gray-500 text-sm'>No more projects to load</p>
						)}
					</div>

					{projects.length === 0 && !isLoading && (
						<div className='text-center py-12 text-gray-500'>
							No projects found
						</div>
					)}
				</div>
			</DashboardLayout>

			<ViewModal
				isOpen={isViewModalOpen}
				onClose={handleCloseModal}
				projectId={selectedProjectId}
				onEdit={handleEditFromModal}
			/>

			<FormModal
				mode='create'
				isOpen={isCreateModalOpen}
				onClose={handleCloseCreateModal}
				onSuccess={handleCreateSuccess}
			/>
		</>
	)
}
