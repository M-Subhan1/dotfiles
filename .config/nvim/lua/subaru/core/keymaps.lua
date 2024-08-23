local keymap = vim.keymap
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "

local function appendDescription(options, desc)
	options.desc = desc
	return options
end

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save file and quit
keymap.set("n", "<Leader>W", ":update<Return>", appendDescription(opts, "Save file and quit"))
keymap.set("n", "<Leader>q", ":quit<Return>", appendDescription(opts, "Quit"))
keymap.set("n", "<Leader>Q", ":qa<Return>", appendDescription(opts, "Quit all"))

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Split window horizontally" })

-- tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- center cursor
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- create new lines without entering insert mode
keymap.set("n", "<leader>o", "o<ESC>", { desc = "Insert new line below" })
keymap.set("n", "<leader>O", "O<ESC>", { desc = "Insert new line above" })

-- enter twilight mode
keymap.set("n", "tw", ":Twilight<enter>", appendDescription(opts, "Toggle twilight mode"))
