return {
	"michaelb/sniprun",
	branch = "master",
	build = "sh install.sh",
	event = "VeryLazy",
	-- do 'sh install.sh 1' if you want to force compile locally
	-- (instead of fetching a binary from the github release). Requires Rust >= 1.65
	config = function()
		require("sniprun").setup({
			snipruncolors = {
				SniprunVirtualTextOk = { ctermbg = "none", fg = "#eed49f" },
			},
		})
	end,
}
