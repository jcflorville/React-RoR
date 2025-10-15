// Query Keys - Centralização de chaves para cache invalidation
// Seguindo padrão hierárquico recomendado pela documentação

import type { ProjectFilters } from "../types/project"

export const projectsKeys = {
	all: ["projects"] as const,
	lists: () => [...projectsKeys.all, "list"] as const,
	list: (filters?: Omit<ProjectFilters, "page">) =>
		[...projectsKeys.lists(), filters] as const,
	details: () => [...projectsKeys.all, "detail"] as const,
	detail: (id: number) => [...projectsKeys.details(), id] as const,
}

// Exemplo de como as keys ficam:
// projectsKeys.all                     → ["projects"]
// projectsKeys.lists()                → ["projects", "list"]
// projectsKeys.list({ status: "active" }) → ["projects", "list", { status: "active" }]
// projectsKeys.detail(1)              → ["projects", "detail", 1]
