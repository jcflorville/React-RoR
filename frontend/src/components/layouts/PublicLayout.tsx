import type { ReactNode } from "react"
import { AppHeader } from "./components/Header"
import { AppFooter } from "./components/Footer"

interface PublicLayoutProps {
	children: ReactNode
}

export const PublicLayout = ({ children }: PublicLayoutProps) => {
	return (
		<div className='min-h-screen flex flex-col'>
			<AppHeader />
			<main className='flex-1 container mx-auto px-4 py-8'>{children}</main>
			<AppFooter />
		</div>
	)
}
