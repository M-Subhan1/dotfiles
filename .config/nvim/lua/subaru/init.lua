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
