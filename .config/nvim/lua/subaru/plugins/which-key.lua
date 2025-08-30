return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = function()
		return {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			spec = {
				{ "<leader>u", name = "Undo Tree", icon = " " }, -- group
				{ "<leader>c", group = "Code Actions", name = "Code Actions", icon = " " },
				{ "<leader>s", group = "split" },
			},
		}
	end,
}
