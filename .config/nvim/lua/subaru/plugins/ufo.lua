return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	config = function()
		local ufo = require("ufo")
		local keymap = vim.keymap

		keymap.set("n", "zR", require("ufo").openAllFolds)
		keymap.set("n", "zM", require("ufo").closeAllFolds)

		ufo.setup({
			open_fold_hl_timeout = 100,
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
		})
	end,
}
