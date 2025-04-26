return {
	"olimorris/codecompanion.nvim",
	opts = function()
		return {
			display = {
				chat = {
					show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
					start_in_insert_mode = true, -- Open the chat buffer in insert mode?
					-- Change the default icons
					icons = {
						pinned_buffer = " ",
						watched_buffer = "👀 ",
					},

					-- Alter the sizing of the debug window
					debug_window = {
						---@return number|fun(): number
						width = vim.o.columns - 5,
						---@return number|fun(): number
						height = vim.o.lines - 2,
					},

					-- Options to customize the UI of the chat buffer
					window = {
						layout = "vertical", -- float|vertical|horizontal|buffer
						border = "single",
						height = 0.8,
						width = 0.45,
						relative = "editor",
						full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
						opts = {
							breakindent = true,
							cursorcolumn = false,
							cursorline = false,
							foldcolumn = "0",
							linebreak = true,
							list = false,
							numberwidth = 1,
							signcolumn = "no",
							spell = false,
							wrap = true,
						},
					},

					---Customize how tokens are displayed
					---@param tokens number
					---@return string
					token_count = function(tokens)
						return " (" .. tokens .. " tokens)"
					end,
				},

				action_palette = {
					width = 95,
					height = 10,
					provider = "telescope", -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
					opts = {
						show_default_actions = true, -- Show the default actions in the action palette?
						show_default_prompt_library = true, -- Show the default prompt library in the action palette?
					},
				},
			},

			strategies = {
				chat = {
					adapter = "openrouter_gemini_pro",
					roles = {
						user = "subaru",
						---@type string|fun(adapter: CodeCompanion.Adapter): string
						llm = function(adapter)
							return "AI (" .. adapter.formatted_name .. ")"
						end,
					},

					tools = {
						["mcp"] = {
							callback = require("mcphub.extensions.codecompanion"),
							description = "Call tools and resources from the MCP Servers",
							opts = {
								user_approval = true,
							},
						},
						vectorcode = {
							description = "Run VectorCode to retrieve the project context.",
							callback = require("vectorcode.integrations").codecompanion.chat.make_tool({
								-- your options goes here
							}),
						},
					},
				},

				inline = {
					keymaps = {
						accept_change = {
							modes = { n = "ga" },
							description = "Accept the suggested change",
						},
						reject_change = {
							modes = { n = "gr" },
							description = "Reject the suggested change",
						},
					},
				},
			},
			adapters = {
				openrouter_claude = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "https://openrouter.ai/api",
							api_key = "OPENROUTER_API_KEY",
							chat_url = "/v1/chat/completions",
						},
						schema = {
							model = {
								default = "anthropic/claude-3.7-sonnet",
							},
						},
					})
				end,

				openrouter_gemini_pro = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "https://openrouter.ai/api",
							api_key = "OPENROUTER_API_KEY",
							chat_url = "/v1/chat/completions",
						},
						schema = {
							model = {
								default = "google/gemini-2.5-pro-preview-03-25",
							},
						},
					})
				end,

				openrouter_gemini_flash = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "https://openrouter.ai/api",
							chat_url = "/v1/chat/completions",
							api_key = function()
								return os.getenv("OPENROUTER_API_KEY")
							end,
						},
						schema = {
							model = {
								default = "google/gemini-2.5-flash-preview",
							},
						},
					})
				end,
			},

			opts = {
				log_level = "DEBUG",
			},
		}
	end,
	init = function()
		local notify = require("notify")

		local M = {}

		function M:init()
			local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

			vim.api.nvim_create_autocmd({ "User" }, {
				pattern = "CodeCompanionRequestStarted",
				group = group,
				callback = function(request)
					local title = "CodeCompanion: " .. request.data.strategy
					local notification = notify(
						"Requesting assistance...",
						vim.log.levels.INFO,
						{ title = title, keep = true, icon = "" }
					)
					M:store_progress_handle(request.data.id, notification)
				end,
			})

			vim.api.nvim_create_autocmd({ "User" }, {
				pattern = "CodeCompanionRequestFinished",
				group = group,
				callback = function(request)
					local notification = M:pop_progress_handle(request.data.id)
					if notification then
						local final_message = "Unhandled Status"
						local level = vim.log.levels.WARN
						if request.data.status == "success" then
							final_message = "Completed"
							level = vim.log.levels.INFO
						elseif request.data.status == "error" then
							final_message = "Error"
							level = vim.log.levels.ERROR
						elseif request.data.status == "cancelled" then
							final_message = "Cancelled"
							level = vim.log.levels.WARN
						end
						notification:update({
							message = final_message,
							level = level,
							keep = false,
							timeout = 3000,
						})
					end
				end,
			})
		end

		M.handles = {}

		function M:store_progress_handle(id, handle)
			M.handles[id] = handle
		end

		function M:pop_progress_handle(id)
			local handle = M.handles[id]
			M.handles[id] = nil
			return handle
		end

		M:init()

		-- Keybindings
		vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionAction<CR>", { desc = " CodeCompanion: Action Palette" })
		vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat<CR>", { desc = " CodeCompanion: Chat" })
		vim.keymap.set("n", "<leader>aq", "<cmd>CodeCompanion<CR>", { desc = " CodeCompanion: Quick Action" })

		-- Extend code companion commands
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
