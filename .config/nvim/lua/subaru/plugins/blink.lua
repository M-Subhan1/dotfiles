local trigger_text = ";"

return { -- optional blink completion source for require statements and module annotations
	"saghen/blink.cmp",
	build = "cargo +nightly build --release",
	opts = function(_, opts)
		opts.enabled = function()
			-- Get the current buffer's filetype
			local filetype = vim.bo[0].filetype
			-- Disable for Telescope buffers
			if filetype == "TelescopePrompt" or filetype == "minifiles" or filetype == "snacks_picker_input" then
				return false
			end
			return true
		end

		return {
			snippets = { preset = "luasnip" },
			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "mono",
			},
			sources = {
				-- add lazydev to your completion providers
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
					lsp = {
						name = "lsp",
						enabled = true,
						module = "blink.cmp.sources.lsp",
						min_keyword_length = 2,
						-- When linking markdown notes, I would get snippets and text in the
						-- suggestions, I want those to show only if there are no LSP
						-- suggestions
						--
						-- Enabled fallbacks as this seems to be working now
						-- Disabling fallbacks as my snippets wouldn't show up when editing
						-- lua files
						-- fallbacks = { "snippets", "buffer" },
						score_offset = 90, -- the higher the number, the higher the priority
					},
					snippets = {
						name = "snippets",
						enabled = true,
						max_items = 15,
						min_keyword_length = 2,
						module = "blink.cmp.sources.snippets",
						score_offset = 85, -- the higher the number, the higher the priority
						-- Only show snippets if I type the trigger_text characters, so
						-- to expand the "bash" snippet, if the trigger_text is ";" I have to
						should_show_items = function()
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
							-- NOTE: remember that `trigger_text` is modified at the top of the file
							return before_cursor:match(trigger_text .. "%w*$") ~= nil
						end,
						-- After accepting the completion, delete the trigger_text characters
						-- from the final inserted text
						-- Modified transform_items function based on suggestion by `synic` so
						-- that the luasnip source is not reloaded after each transformation
						-- https://github.com/linkarzu/dotfiles-latest/discussions/7#discussion-7849902
						-- NOTE: I also tried to add the ";" prefix to all of the snippets loaded from
						-- friendly-snippets in the luasnip.lua file, but I was unable to do
						-- so, so I still have to use the transform_items here
						-- This removes the ";" only for the friendly-snippets snippets
						transform_items = function(_, items)
							local line = vim.api.nvim_get_current_line()
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before_cursor = line:sub(1, col)
							local start_pos, end_pos = before_cursor:find(trigger_text .. "[^" .. trigger_text .. "]*$")
							if start_pos then
								for _, item in ipairs(items) do
									if not item.trigger_text_modified then
										---@diagnostic disable-next-line: inject-field
										item.trigger_text_modified = true
										item.textEdit = {
											newText = item.insertText or item.label,
											range = {
												start = { line = vim.fn.line(".") - 1, character = start_pos - 1 },
												["end"] = { line = vim.fn.line(".") - 1, character = end_pos },
											},
										}
									end
								end
							end
							return items
						end,
					},
				},
			},
			keymap = {
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				cmdline = {
					enabled = false,
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
						components = {
							kind_icon = {
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								-- (optional) use highlights from mini.icons
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
							kind = {
								-- (optional) use highlights from mini.icons
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
					},
				},
			},
		}
	end,
	dependencies = {
		"saghen/blink.compat",
	},
}
