require("subaru.core")
require("subaru.lazy")

require("mini.comment").setup()
require("mini.surround").setup()
require("mini.bracketed").setup()
require("mini.indentscope").setup()

require("mini.pairs").setup({
	modes = { insert = true, command = true, terminal = false },
	-- skip autopair when next character is one of these
	skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
	-- skip autopair when the cursor is inside these treesitter nodes
	skip_ts = { "string" },
	-- skip autopair when next character is closing pair
	-- and there are more closing pairs than opening pairs
	skip_unbalanced = true,
	-- better deal with markdown code blocks
	markdown = true,
})

require("mini.move").setup({
	mappings = {
		left = "H",
		right = "L",
		down = "J",
		up = "K",

		line_left = "",
		line_right = "",
		line_down = "",
		line_up = "",
	},
})

require("mini.icons").setup()
require("nvim-tree").setup({
	disable_netrw = true,
	view = {
		width = 30,
		relativenumber = true,
		preserve_window_proportions = false,
	},
	-- change folder arrow icons
	renderer = {
		root_folder_label = false,
		indent_markers = {
			enable = true,
		},
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "", -- arrow when folder is closed
					arrow_open = "", -- arrow when folder is open
				},
			},
		},
	},
	-- disable window_picker for
	-- explorer to work well with
	-- window splits
	actions = {
		open_file = {
			quit_on_open = true,
			window_picker = {
				enable = false,
			},
		},
	},
	filters = {
		custom = { "node_modules/.*" },
	},
	git = {
		ignore = false,
	},
})
