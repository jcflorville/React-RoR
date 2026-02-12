import { createFileRoute } from "@tanstack/react-router"
import { useDrawing, useUpdateDrawing } from "@/hooks/queries/drawings-queries"
import { FabricCanvas } from "@/components/FabricCanvas"
import { useDebounce } from "@/hooks/useDebounce"
import { FiLoader, FiSave } from "react-icons/fi"
import { useCallback, useEffect, useRef } from "react"
import type { FabricCanvasData } from "@/types/drawing"

export const Route = createFileRoute("/_auth/dada/$id")({
	component: DrawingEditor,
})

function DrawingEditor() {
	const { id } = Route.useParams()
	const drawingId = Number(id)
	const { data: drawing, isLoading, error } = useDrawing(drawingId)
	const updateDrawing = useUpdateDrawing(drawingId)

	// Ref to always have the latest lock_version without recreating callbacks
	const lockVersionRef = useRef(0)
	useEffect(() => {
		if (drawing) lockVersionRef.current = drawing.lock_version
	}, [drawing])

	const saveCanvas = useCallback(
		async (canvasData: FabricCanvasData) => {
			try {
				await updateDrawing.mutateAsync({
					canvas_data: canvasData,
					lock_version: lockVersionRef.current,
				})
			} catch (error) {
				console.error("Failed to save drawing:", error)
			}
		},
		[updateDrawing],
	)

	const debouncedSave = useDebounce(saveCanvas, 1000)

	if (isLoading) {
		return (
			<div className='flex items-center justify-center min-h-screen'>
				<FiLoader className='h-8 w-8 animate-spin text-muted-foreground' />
			</div>
		)
	}

	if (error || !drawing) {
		return (
			<div className='flex items-center justify-center min-h-screen'>
				<div className='text-center'>
					<h2 className='text-2xl font-bold mb-2'>Drawing not found</h2>
					<p className='text-muted-foreground'>
						The drawing you're looking for doesn't exist or you don't have
						access to it.
					</p>
				</div>
			</div>
		)
	}

	return (
		<div className='h-screen flex flex-col'>
			<div className='border-b px-4 py-3 flex items-center justify-between'>
				<h1 className='text-lg font-semibold'>{drawing.title}</h1>
				{updateDrawing.isPending && (
					<div className='flex items-center gap-2 text-sm text-muted-foreground'>
						<FiSave className='h-4 w-4 animate-pulse' />
						<span>Saving...</span>
					</div>
				)}
			</div>
			<div className='flex-1 overflow-auto'>
				<FabricCanvas
					canvasData={drawing.canvas_data}
					onUpdate={debouncedSave}
				/>
			</div>
		</div>
	)
}
