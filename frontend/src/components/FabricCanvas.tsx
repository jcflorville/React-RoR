import { useEffect, useRef } from "react"
import { Canvas, PencilBrush } from "fabric"
import type { FabricCanvasData } from "@/types/drawing"

interface FabricCanvasProps {
	canvasData: FabricCanvasData
	onUpdate: (data: FabricCanvasData) => void
	readonly?: boolean
}

export function FabricCanvas({
	canvasData,
	onUpdate,
	readonly = false,
}: FabricCanvasProps) {
	const canvasRef = useRef<HTMLCanvasElement>(null)
	const fabricRef = useRef<Canvas | null>(null)
	const onUpdateRef = useRef(onUpdate)
	onUpdateRef.current = onUpdate

	useEffect(() => {
		if (!canvasRef.current) return

		const canvas = new Canvas(canvasRef.current, {
			width: 800,
			height: 600,
			backgroundColor: "#ffffff",
			isDrawingMode: !readonly,
		})

		// Configure brush
		if (!readonly) {
			const brush = new PencilBrush(canvas)
			brush.width = 2
			brush.color = "#000000"
			canvas.freeDrawingBrush = brush
		}

		// Load existing data (Fabric v7 returns Promise)
		if (canvasData.objects?.length > 0) {
			canvas.loadFromJSON(canvasData).then(() => canvas.renderAll())
		}

		// Emit changes on user actions only
		// path:created  → freehand stroke completed (does NOT fire during loadFromJSON)
		// object:modified → user moved/resized an object
		// object:removed → user deleted an object
		if (!readonly) {
			const emitChange = () => {
				onUpdateRef.current(canvas.toJSON() as FabricCanvasData)
			}
			canvas.on("path:created", emitChange)
			canvas.on("object:modified", emitChange)
			canvas.on("object:removed", emitChange)
		}

		fabricRef.current = canvas

		return () => {
			canvas.dispose()
			fabricRef.current = null
		}
	}, []) // Mount once — canvasData is guaranteed ready by parent

	return (
		<div className='flex items-center justify-center bg-gray-100 p-4'>
			<canvas ref={canvasRef} className='border border-gray-300 shadow-lg' />
		</div>
	)
}
