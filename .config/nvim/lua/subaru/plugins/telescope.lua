local telescope = require("telescope.builtin")
local utils = require("telescope.utils")

local function get_changed_files()
	local parent_branch =
		utils.get_os_command_output({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}" })[1]
	if not parent_branch or parent_branch == "" then
		print("No upstream branch found. Using 'main' as default.")
		parent_branch = "main"
	end

	local changed_files = utils.get_os_command_output({ "git", "diff", "--name-only", parent_branch })

	-- Debug: Print the number of changed files
	print("Number of changed files: " .. #changed_files)

	-- Debug: Print the first few changed files (if any)
	for i = 1, math.min(5, #changed_files) do
		print("Changed file " .. i .. ": " .. changed_files[i])
	end

	return changed_files
end

local function search_changed_files()
	local changed_files = get_changed_files()

	if #changed_files == 0 then
		print("No changed files found.")
		return
	end

	print(vim.inspect(changed_files))

	telescope.find_files({
		prompt_title = "Changed Files",
		search_dirs = changed_files,
	})
end

-- Set up a keymap to trigger the search
vim.api.nvim_set_keymap("n", "<leader>fc", [[<cmd>lua search_changed_files()<CR>]], { noremap = true, silent = true })

return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")
	end,
	keys = {
		{
			"<leader>,",
			"<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
			desc = "Switch Buffer",
		},
		{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Buffers" },
		{
			"<leader>fc",
			"<cmd>Telescope grep_string<cr>",
			desc = "Find string under cursor in cwd",
		},
		{
			"<leader>ff",
			"<cmd>Telescope find_files<cr>",
			desc = "Find files in cwd",
		},
		{
			"<leader>fb",
			"<cmd>Telescope buffers<cr>",
			desc = "Find active buffers",
		},
		{
			"<leader>ft",
			"<cmd>TodoTelescope<cr>",
			desc = "Find todos",
		},
		{
			"<leader>fs",
			"<cmd>Telescope live_grep<cr>",
			desc = "Find string in cwd",
		},
		{
			"<leader>fC",
			search_changed_files,
			desc = "Search changed files",
		},
		{
			"<leader>fG",
			"<cmd>Telescope git_status<cr>",
			desc = "Search git status",
		},
		{
			"<leader>fS",
			function()
				require("telescope.builtin").treesitter({
					prompt_title = " Find Symbols",
					find_command = { "rg", "--files", "--hidden", "-g", "!.git/*" },
					initial_mode = "insert",
					layout_strategy = "horizontal",
					layout_config = {
						width = 0.75,
						height = 0.80,
						prompt_position = "top",
					},
					keys = {
						{
							"<C-d>",
							require("telescope.actions").delete_buffer,
						},
					},
				})
			end,
			desc = "Search symbols in current buffer",
		},
	},
}
