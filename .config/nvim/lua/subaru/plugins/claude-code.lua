return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code" },
		{ "<leader>at", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{
			"<leader>as",
			mode = "v",
			function()
				vim.cmd("ClaudeCodeSend")
				vim.defer_fn(function()
					vim.cmd("ClaudeCodeFocus")
				end, 0)
			end,
			desc = "Send (ClaudeCode)",
		},
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
		},
		-- Diff management
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	},
	config = true,
}
