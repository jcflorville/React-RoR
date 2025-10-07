import { Modal, Button, Spinner, Badge, Progress } from "flowbite-react"
import { ModalHeader, ModalBody, ModalFooter } from "flowbite-react"
import { useModalProject } from "@/hooks/queries/projects-queries"
import { customModalTheme } from "@/lib/flowbite-theme"

interface ViewModalProps {
	isOpen: boolean
	onClose: () => void
	projectId: number | null
	onEdit?: (projectId: number) => void
}

export function ViewModal({
	isOpen,
	onClose,
	projectId,
	onEdit,
}: ViewModalProps) {
	const {
		data: projectResponse,
		isLoading,
		error,
	} = useModalProject(projectId, {
		enabled: isOpen && !!projectId,
	})

	const project = projectResponse?.data

	if (!isOpen) return null

	const getStatusColor = (status: string) => {
		switch (status) {
			case "active":
				return "info"
			case "completed":
				return "success"
			case "draft":
				return "warning"
			case "archived":
				return "gray"
			default:
				return "gray"
		}
	}

	const getPriorityColor = (priority: string) => {
		switch (priority) {
			case "urgent":
				return "failure"
			case "high":
				return "warning"
			case "medium":
				return "info"
			case "low":
				return "gray"
			default:
				return "gray"
		}
	}

	const getPriorityIcon = (priority: string) => {
		switch (priority) {
			case "urgent":
				return "🔥"
			case "high":
				return "⚡"
			case "medium":
				return "📋"
			case "low":
				return "📝"
			default:
				return "📝"
		}
	}

	const getTaskStats = (tasks: any[]) => {
		const stats = {
			completed: tasks.filter((t) => t.status === "completed").length,
			in_progress: tasks.filter((t) => t.status === "in_progress").length,
			todo: tasks.filter((t) => t.status === "todo").length,
			blocked: tasks.filter((t) => t.status === "blocked").length,
			total: tasks.length,
		}
		const progress =
			stats.total > 0 ? Math.round((stats.completed / stats.total) * 100) : 0
		return { ...stats, progress }
	}

	const formatDate = (dateString: string) => {
		return new Date(dateString).toLocaleDateString("pt-BR")
	}

	return (
		<Modal
			show={isOpen}
			onClose={onClose}
			size='2xl'
			theme={customModalTheme.modal}
		>
			<ModalHeader>
				{isLoading ? (
					<div className='h-6 w-48 bg-gray-200 rounded animate-pulse' />
				) : (
					project?.name || "Projeto"
				)}
			</ModalHeader>

			<ModalBody>
				{isLoading ? (
					<div className='flex items-center justify-center py-8'>
						<Spinner size='xl' />
						<span className='ml-3 text-gray-900 dark:text-gray-100'>
							Carregando projeto...
						</span>
					</div>
				) : error ? (
					<div className='text-center py-8'>
						<p className='text-red-600 dark:text-red-400 mb-4'>
							Erro ao carregar projeto
						</p>
					</div>
				) : project ? (
					<div className='space-y-6 '>
						{/* Status e Prioridade */}
						<div className='flex flex-wrap gap-4'>
							<div>
								<span className='text-sm font-medium text-gray-600 dark:text-gray-300 block mb-1'>
									Status
								</span>
								<Badge color={getStatusColor(project.status)}>
									{project.status}
								</Badge>
							</div>
							<div>
								<span className='text-sm font-medium text-gray-600 dark:text-gray-300 block mb-1'>
									Prioridade
								</span>
								<Badge color={getPriorityColor(project.priority)}>
									{getPriorityIcon(project.priority)} {project.priority}
								</Badge>
							</div>
						</div>

						{/* Progresso */}
						{project.tasks && project.tasks.length > 0 && (
							<div>
								<h4 className='text-lg font-medium mb-3 text-gray-900 dark:text-gray-100'>
									Progresso do Projeto
								</h4>
								{(() => {
									const stats = getTaskStats(project.tasks)
									return (
										<div className='space-y-3'>
											<div className='flex items-center justify-between'>
												<span className='text-sm text-gray-600 dark:text-gray-300'>
													{stats.completed} de {stats.total} tarefas concluídas
												</span>
												<span className='text-sm font-medium text-gray-900 dark:text-gray-100'>
													{stats.progress}%
												</span>
											</div>
											<Progress progress={stats.progress} color='blue' />
											<div className='grid grid-cols-2 gap-4 text-sm text-gray-600 dark:text-gray-300'>
												<div className='flex justify-between'>
													<span>✅ Concluídas:</span>
													<span>{stats.completed}</span>
												</div>
												<div className='flex justify-between'>
													<span>🔄 Em progresso:</span>
													<span>{stats.in_progress}</span>
												</div>
												<div className='flex justify-between'>
													<span>📝 A fazer:</span>
													<span>{stats.todo}</span>
												</div>
												<div className='flex justify-between'>
													<span>🚫 Bloqueadas:</span>
													<span>{stats.blocked}</span>
												</div>
											</div>
										</div>
									)
								})()}
							</div>
						)}

						{/* Datas */}
						<div className='text-base leading-relaxed text-gray-600 dark:text-gray-300 rounded-2xl border border-gray-200 dark:border-gray-600 p-4 shadow-md bg-gray-50 dark:bg-gray-800/50'>
							<h4 className='mb-3 text-gray-900 dark:text-gray-100 font-medium'>
								Datas
							</h4>
							<div className='grid grid-cols-1 md:grid-cols-2 gap-3 text-sm'>
								<div className='flex justify-between'>
									<span>Criado em:</span>
									<span>{formatDate(project.created_at)}</span>
								</div>
								{project.start_date && (
									<div className='flex justify-between'>
										<span>Data de início:</span>
										<span>{formatDate(project.start_date)}</span>
									</div>
								)}
								{project.end_date && (
									<div className='flex justify-between'>
										<span>Prazo final:</span>
										<span>{formatDate(project.end_date)}</span>
									</div>
								)}
								<div className='flex justify-between'>
									<span>Última atualização:</span>
									<span>{formatDate(project.updated_at)}</span>
								</div>
							</div>
						</div>

						{/* Categorias */}
						{project.categories && project.categories.length > 0 && (
							<div>
								<div className='text-lg font-medium mb-3 text-gray-900 dark:text-gray-100'>
									Categorias
								</div>
								<div className='flex flex-wrap gap-2'>
									{project.categories.map((category) => (
										<span
											key={category.id}
											className='inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium'
											style={{
												backgroundColor: category.color + "20",
												color: category.color,
											}}
										>
											{category.name}
										</span>
									))}
								</div>
							</div>
						)}

						{/* Descrição */}
						{project.description && (
							<div className='text-base leading-relaxed text-gray-600 dark:text-gray-300 rounded-2xl border border-gray-200 dark:border-gray-600 p-4 shadow-md bg-gray-50 dark:bg-gray-800/50'>
								<div className='text-lg font-medium mb-3 text-gray-900 dark:text-gray-100'>
									Descrição
								</div>
								<p className='whitespace-pre-wrap'>{project.description}</p>
							</div>
						)}
					</div>
				) : (
					<div className='text-center py-8'>
						<p className='text-gray-600 dark:text-gray-300'>
							Projeto não encontrado
						</p>
					</div>
				)}
			</ModalBody>

			{project && onEdit && (
				<ModalFooter>
					<Button onClick={() => onEdit(project.id)}>Editar Projeto</Button>
					<Button color='gray' onClick={onClose}>
						Fechar
					</Button>
				</ModalFooter>
			)}
		</Modal>
	)
}
