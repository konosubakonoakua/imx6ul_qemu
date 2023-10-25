require("lspconfig").clangd.setup({
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
		"--query-driver=$HOME/.local/opt/armgnu/current/bin/arm-none-eabi-gcc",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
})
