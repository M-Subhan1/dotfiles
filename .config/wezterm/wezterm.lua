local wezterm = require("wezterm")

return {
	-- color_scheme = "termnial.sexy",
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.5,
	font = wezterm.font("MesloLGS Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" }),
	macos_window_background_blur = 30,
	window_background_opacity = 0.80,
	window_decorations = "RESIZE",
	keys = {
		{
			key = "f",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
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
