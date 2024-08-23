return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		opts = {
			debug = true, -- Enable debugging
			question_header = "  User ",
			answer_header = "  Copilot ",
			auto_follow_cursor = false, -- Don't follow the cursor after getting response
			show_help = false, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
			mappings = {
				-- Use tab for completion
				complete = {
					detail = "Use @<Tab> or /<Tab> for options.",
					insert = "<Tab>",
				},
				-- Close the chat
				close = {
					normal = "q",
					insert = "<C-c>",
				},
				-- Reset the chat buffer
				reset = {
					normal = "<C-x>",
					insert = "<C-x>",
				},
				-- Submit the prompt to Copilot
				submit_prompt = {
					normal = "<CR>",
					insert = "<C-CR>",
				},
				-- Accept the diff
				accept_diff = {
					normal = "<C-y>",
					insert = "<C-y>",
				},
				-- Yank the diff in the response to register
				yank_diff = {
					normal = "gmy",
				},
				-- Show the diff
				show_diff = {
					normal = "gmd",
				},
				-- Show the prompt
				show_system_prompt = {
					normal = "gmp",
				},
				-- Show the user selection
				show_user_selection = {
					normal = "gms",
				},
			},
			prompts = {
				Explain = {
					mapping = "<leader>ae",
					description = "AI Explain",
				},
				Review = {
					mapping = "<leader>ar",
					description = "AI Review",
				},
				Tests = {
					mapping = "<leader>at",
					description = "AI Tests",
				},
				Fix = {
					mapping = "<leader>af",
					description = "AI Fix",
				},
				Optimize = {
					mapping = "<leader>ao",
					description = "AI Optimize",
				},
				Docs = {
					mapping = "<leader>ad",
					description = "AI Documentation",
				},
				CommitStaged = {
					prompt = "Write commit message for the change with commitizen convention",
					mapping = "<leader>ac",
					description = "AI Generate Commit",
				},
				BetterNamings = {
					prompt = "Based on the current context, suggest better names for variables, functions, classes",
					mapping = "<leader>an",
					description = "AI Better Namings",
				},
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")
			opts.selection = select.visual or select.buffer
			chat.setup(opts)
			-- Setup the CMP integration
			require("CopilotChat.integrations.cmp").setup()

			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, { selection = select.visual or select.buffer })
			end, { nargs = "*", range = true })

			-- Restore CopilotChatBuffer
			vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
				chat.ask(args.args, { selection = select.buffer })
			end, { nargs = "*", range = true })

			-- Custom buffer for CopilotChat
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = true
					vim.opt_local.number = true

					-- Get current filetype and set it to markdown if the current filetype is copilot-chat
					local ft = vim.bo.filetype
					if ft == "copilot-chat" then
						vim.bo.filetype = "markdown"
					end
				end,
			})

			-- Add which-key mappings
			require("which-key").add({
				{ "<leader>gm", group = "+Copilot Chat" }, -- group
				{ "<leader>gmd", desc = "Show diff" },
				{ "<leader>gmp", desc = "System prompt" },
				{ "<leader>gms", desc = "Show selection" },
				{ "<leader>gmy", desc = "Yank diff" },
			})
		end,
		-- See Commands section for default commands if you want to lazy load on them
		keys = {
			-- Show help actions with telescope
			{
				"<leader>ah",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.help_actions())
				end,
				desc = "CopilotChat - Help actions",
			},
			-- Show prompts actions with telescope
			{
				"<leader>ap",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>ap",
				":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
				mode = "x",
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>aa",
				":CopilotChatVisual",
				mode = "x",
				desc = "CopilotChat - Open in vertical split",
			},
			-- Custom input for CopilotChat
			{
				"<leader>ai",
				function()
					local input = vim.fn.input("Ask Copilot: ")
					if input ~= "" then
						vim.cmd("CopilotChat " .. input)
					end
				end,
				desc = "CopilotChat - Ask input",
			},
			-- Generate commit message based on the git diff
			{
				"<leader>am",
				"<cmd>CopilotChatCommitStaged<cr>",
				desc = "CopilotChat - Generate commit message for staged changes",
			},
			-- Quick chat with Copilot
			{
				"<leader>aq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						vim.cmd("CopilotChatBuffer " .. input)
					end
				end,
				desc = "CopilotChat - Quick chat",
			},

			{ "<leader>ae", mode = "v", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
			{ "<leader>at", mode = "v", "<<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
			{ "<leader>ar", mode = "v", "<<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
			{ "<leader>ao", mode = "v", "<<cmd>CopilotChatOptimize<cr>", desc = "CopilotChat - Optimize code" },
			{ "<leader>aR", mode = "v", "<<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
			{ "<leader>an", mode = "v", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
			{ "<leader>aa", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
			{ "<leader>ax", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
			{ "<leader>af", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Fix Diagnostic" },
			{ "<leader>ad", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Debug Info" },
			{ "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
		},
	},
}
