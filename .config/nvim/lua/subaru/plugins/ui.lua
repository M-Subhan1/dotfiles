return {
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			{
				"MunifTanjim/nui.nvim",
				event = "VeryLazy",
			},
			"rcarriga/nvim-notify",
		},
		opts = function(_, opts)
			opts.routes = opts.routes or {}
			opts.routes = {
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			}

			local focused = true
			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function()
					focused = true
				end,
			})
			vim.api.nvim_create_autocmd("FocusLost", {
				callback = function()
					focused = false
				end,
			})
			table.insert(opts.routes, 1, {
				filter = {
					cond = function()
						return not focused
					end,
				},
				view = "notify_send",
				opts = { stop = false },
			})

			opts.commands = {
				all = {
					-- options for the message history that you get with `:Noice`
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {},
				},
			}

			opts.presets = {
				lsp_doc_border = true,
			}
		end,
	},
	{
		"rcarriga/nvim-notify",
		keys = {
			{
				"n",
				"<leader>n",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss notification",
			},
		},
		opts = {
			timeout = 3000,
			background_colour = "#000000",
			render = "wrapped-compact",
		},
	},
}
