-- Requires
local awful = require("awful")
awful.util = require("awful.util")
local gfs = require("gears.filesystem")
local default_theme_path = gfs.get_themes_dir() .. "/default/"
local default_titlebar_path = default_theme_path .. "/titlebar/"

-- Theme fonts and colors
theme = {}
theme.font          = "DaddyTimeMono Nerd Font 10"

theme.bg_normal     = "#0A0A0A"
theme.bg_focus      = "#202020aa"
theme.bg_urgent     = "#ff0000"
theme.titlebar_fg_normal = "#444444"
theme.titlebar_fg_focus = "#aaaaaa"
theme.titlebar_bg_focus = "#404040cc"
theme.titlebar_bg_normal = "#282828aa"
theme.fg_normal     = "#FFFFFF"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ff0000"

-- Only modify empty taglist fg, rest is inherited from theme.fg_*
theme.taglist_bg_focus      = "#505050"
theme.taglist_fg_empty     = "#505050"

-- Only modify empty tasklist fg, rest is inherited from theme.fg_*
theme.tasklist_fg_minimize     = "#444444"
theme.tasklist_maximized     = "<span bgcolor=\"#00DD00\"> + </span> "
theme.tasklist_fg_normal     = "#666666"
theme.tasklist_fg_focus     = "#ffffff"
theme.tasklist_bg_focus     = "#404040aa"

theme.border_width  = 1
theme.border_normal = "#222222"
theme.border_focus  = "#888888"
theme.border_marked = "#91231c"

-- Display the taglist squares
theme.taglist_squares = true

-- Don't show app icons in wibar
theme.tasklist_disable_icon = true

-- Maximized clients have no border
theme.maximized_hide_border = true

-- Default master width
theme.master_width_factor = 0.55
--theme.master_fill_policy = 'master_width_factor'

-- Menu
theme.menu_width = 200

-- Wibar
theme.wibar_height = 20

-- Icons
theme.awesome_icon = '/usr/share/awesome/themes/sky/awesome-icon.png'
theme.icon_theme = 'Clarity'

theme.layout_floating   = default_theme_path.."layouts/floatingw.png"
theme.layout_magnifier  = default_theme_path.."layouts/magnifierw.png"
theme.layout_max        = default_theme_path.."layouts/maxw.png"
theme.layout_fullscreen = default_theme_path.."layouts/fullscreenw.png"
theme.layout_tilebottom = default_theme_path.."layouts/tilebottomw.png"
theme.layout_tileleft   = default_theme_path.."layouts/tileleftw.png"
theme.layout_tile       = default_theme_path.."layouts/tilew.png"
theme.layout_tiletop    = default_theme_path.."layouts/tiletopw.png"
theme.layout_spiral     = default_theme_path.."layouts/spiralw.png"
theme.layout_dwindle    = default_theme_path.."layouts/dwindlew.png"
theme.layout_cornernw   = default_theme_path.."layouts/cornernww.png"
theme.layout_cornerne   = default_theme_path.."layouts/cornernew.png"
theme.layout_cornersw   = default_theme_path.."layouts/cornersww.png"
theme.layout_cornerse   = default_theme_path.."layouts/cornersew.png"

theme.titlebar_close_button_normal              = default_titlebar_path .. "close_normal.png"
theme.titlebar_close_button_focus               = default_titlebar_path .. "close_focus.png"
theme.titlebar_minimize_button_normal           = default_titlebar_path .. "minimize_normal.png"
theme.titlebar_minimize_button_focus            = default_titlebar_path .. "minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive     = default_titlebar_path .. "ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = default_titlebar_path .. "ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = default_titlebar_path .. "ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = default_titlebar_path .. "ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive    = default_titlebar_path .. "sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = default_titlebar_path .. "sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = default_titlebar_path .. "sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = default_titlebar_path .. "sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive  = default_titlebar_path .. "floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = default_titlebar_path .. "floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = default_titlebar_path .. "floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = default_titlebar_path .. "floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = default_titlebar_path .. "maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = default_titlebar_path .. "maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = default_titlebar_path .. "maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = default_titlebar_path .. "maximized_focus_active.png"

return theme
