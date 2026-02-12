import { createFileRoute, Link, useNavigate } from "@tanstack/react-router"
import { useDrawings, useCreateDrawing } from "@/hooks/queries/drawings-queries"
import { Button } from "flowbite-react"
import { FiPlus, FiLoader } from "react-icons/fi"

export const Route = createFileRoute("/_auth/dada/")({
	component: DadaIndex,
})

function DadaIndex() {
	const { data: drawings, isLoading } = useDrawings()
	const createDrawing = useCreateDrawing()
	const navigate = useNavigate()

	const handleCreateDrawing = async () => {
		try {
			const newDrawing = await createDrawing.mutateAsync({
				title: "Untitled Drawing",
			})
			// Navigate to the new drawing editor
			navigate({ to: "/dada/$id", params: { id: newDrawing.id.toString() } })
		} catch (error) {
			console.error("Failed to create drawing:", error)
		}
	}

	if (isLoading) {
		return (
			<div className='flex items-center justify-center min-h-[400px]'>
				<FiLoader className='h-8 w-8 animate-spin text-muted-foreground' />
			</div>
		)
	}

	return (
		<div className='space-y-6'>
			<div className='flex items-center justify-between'>
				<div>
					<h2 className='text-2xl font-bold'>My Drawings</h2>
					<p className='text-muted-foreground'>
						Create and manage your visual conversations
					</p>
				</div>
				<Button
					onClick={handleCreateDrawing}
					disabled={createDrawing.isPending}
				>
					{createDrawing.isPending ? (
						<FiLoader className='h-4 w-4 animate-spin mr-2' />
					) : (
						<FiPlus className='h-4 w-4 mr-2' />
					)}
					New Drawing
				</Button>
			</div>

			{drawings && drawings.length > 0 ? (
				<div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4'>
					{drawings.map((drawing) => (
						<Link
							key={drawing.id}
							to='/dada/$id'
							params={{ id: drawing.id.toString() }}
							className='block p-6 border rounded-lg hover:border-primary transition-colors'
						>
							<h3 className='font-semibold mb-2'>{drawing.title}</h3>
							<p className='text-sm text-muted-foreground'>
								Updated {new Date(drawing.updated_at).toLocaleDateString()}
							</p>
						</Link>
					))}
				</div>
			) : (
				<div className='text-center py-12 border border-dashed rounded-lg'>
					<p className='text-muted-foreground mb-4'>No drawings yet</p>
					<Button
						onClick={handleCreateDrawing}
						disabled={createDrawing.isPending}
					>
						<FiPlus className='h-4 w-4 mr-2' />
						Create your first drawing
					</Button>
				</div>
			)}
		</div>
	)
}
