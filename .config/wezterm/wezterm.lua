local wezterm = require("wezterm")

return {
	-- color_scheme = "termnial.sexy",
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.5,
	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular", stretch = "Normal", style = "Normal" }),
	macos_window_background_blur = 30,
	window_background_opacity = 0.80,
	window_decorations = "RESIZE",
	keys = {
		{
			key = "h",
			mods = "CTRL",
			action = wezterm.action.Multiple({
				wezterm.action.SendKey({ key = "\\", mods = "CTRL" }),
				wezterm.action.SendKey({ key = "n", mods = "CTRL" }),
				-- Shortcut of <C-w><C-h>
				wezterm.action.SendKey({ key = "h", mods = "CTRL" }),
			}),
		},
	},
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
