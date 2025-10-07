export const customModalTheme = {
	modal: {
		content: {
			base: "relative h-full w-full p-4 md:h-auto",
			inner: "relative flex max-h-[90dvh] flex-col rounded-lg shadow-xl",
		},
		header: {
			base: "flex items-start justify-between rounded-t border-b border-gray-600 p-5 bg-[rgb(31,41,55)]",
			popup: "border-b-0 p-2",
			title: "text-xl font-semibold text-gray-100",
			close: {
				base: "ml-auto inline-flex items-center rounded-lg bg-transparent p-1.5 text-sm text-gray-400 hover:bg-gray-700 hover:text-gray-100",
				icon: "h-5 w-5",
			},
		},
		body: {
			base: "flex-1 overflow-auto p-6 bg-[rgb(31,41,55)] text-gray-100",
			popup: "pt-0",
		},
		footer: {
			base: "flex items-center space-x-2 rounded-b border-t border-gray-600 p-6 bg-[rgb(31,41,55)]",
			popup: "border-t-0",
		},
	},
}
