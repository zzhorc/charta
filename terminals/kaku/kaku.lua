local wezterm = require 'wezterm'

local function resolve_bundled_config()
  local resource_dir = wezterm.executable_dir:gsub('MacOS/?$', 'Resources')
  local bundled = resource_dir .. '/kaku.lua'
  local f = io.open(bundled, 'r')
  if f then
    f:close()
    return bundled
  end

  local app_bundled = '/Applications/Kaku.app/Contents/Resources/kaku.lua'
  f = io.open(app_bundled, 'r')
  if f then
    f:close()
    return app_bundled
  end

  local home = os.getenv('HOME') or ''
  local home_bundled = home .. '/Applications/Kaku.app/Contents/Resources/kaku.lua'
  f = io.open(home_bundled, 'r')
  if f then
    f:close()
    return home_bundled
  end

  local dev_bundled = wezterm.executable_dir .. '/../../assets/macos/Kaku.app/Contents/Resources/kaku.lua'
  f = io.open(dev_bundled, 'r')
  if f then
    f:close()
    return dev_bundled
  end

  return nil
end

local config = {}
local bundled = resolve_bundled_config()

if bundled then
  local ok, loaded = pcall(dofile, bundled)
  if ok and type(loaded) == 'table' then
    config = loaded
  else
    wezterm.log_error('Kaku: failed to load bundled defaults from ' .. bundled)
  end
else
  wezterm.log_error('Kaku: bundled defaults not found')
end

-- User overrides:
-- 1) Font family and size
config.font = wezterm.font('MesloLGS NF')
config.font_size = 14.0

-- 2) Visual appearance
config.window_background_opacity = 0.9
config.macos_window_background_blur = 25

-- 3) Window size, padding, and sleek frameless look
config.initial_cols = 120
config.initial_rows = 30
config.window_padding = { left = '20px', right = '20px', top = '40px', bottom = '20px' }

config.max_fps = 240
-- 标签页花哨模式
config.use_fancy_tab_bar = false
-- 标签页在底部
config.tab_bar_at_bottom = true
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.line_height = 1.20
config.enable_scroll_bar = true

-- ===== Custom Theme Definitions =====
local light_bg = '#D5D0B5' -- Warmer, slightly darker vintage paper
local light_fg = '#3C3836' -- Espresso dark text for high contrast and comfort

-- Customize Kaku Light
local light_scheme = config.color_schemes and config.color_schemes['Kaku Light']
if light_scheme then
  light_scheme.background = light_bg
  light_scheme.foreground = light_fg
  light_scheme.cursor_bg = '#7C6F64'
  light_scheme.cursor_fg = light_bg
  light_scheme.selection_bg = '#BDB596'
  light_scheme.selection_fg = '#3C3836'
  
  light_scheme.ansi = {
    '#4C4F69', -- black
    '#D20F39', -- red
    '#40A02B', -- green
    '#DF8E1D', -- yellow
    '#1E66F5', -- blue
    '#D27A8A', -- magenta (Warm Rose Pink)
    '#179299', -- cyan
    '#ACB0BE', -- white
  }
  light_scheme.brights = {
    '#7C7F93', -- bright black
    '#D20F39', -- bright red
    '#40A02B', -- bright green
    '#DF8E1D', -- bright yellow
    '#1E66F5', -- bright blue
    '#E08999', -- bright magenta
    '#179299', -- bright cyan
    '#E6E9EF', -- bright white
  }

  if light_scheme.tab_bar then
    light_scheme.tab_bar.background = light_bg
    light_scheme.tab_bar.inactive_tab_edge = light_bg
    if light_scheme.tab_bar.inactive_tab then light_scheme.tab_bar.inactive_tab.bg_color = light_bg end
    if light_scheme.tab_bar.new_tab then light_scheme.tab_bar.new_tab.bg_color = light_bg end
  end
end

-- Customize Kaku Dark
local dark_scheme = config.color_schemes and config.color_schemes['Kaku Dark']
if dark_scheme then
  dark_scheme.ansi = {
    '#45475A', -- black
    '#F38BA8', -- red
    '#A6E3A1', -- green
    '#F9E2AF', -- yellow
    '#89B4FA', -- blue
    '#D27A8A', -- magenta (Warm Rose Pink)
    '#94E2D5', -- cyan
    '#BAC2DE', -- white
  }
  dark_scheme.brights = {
    '#6C7086', -- bright black
    '#F38BA8', -- bright red
    '#A6E3A1', -- bright green
    '#F9E2AF', -- bright yellow
    '#89B4FA', -- bright blue
    '#E08999', -- bright magenta
    '#94E2D5', -- bright cyan
    '#A6ADC8', -- bright white
  }
end

-- ===== Theme Resolution =====
-- We set this to 'Auto' to let Kaku's built-in logic handle real-time switching.
-- If you manually select 'Kaku Light' or 'Kaku Dark' in the Kaku menu,
-- this configuration will still respect your choice because we are defining
-- those schemes above without overriding the final resolution logic.
config.color_scheme = (wezterm.gui and wezterm.gui.get_appearance() or 'Dark'):find('Dark') and 'Kaku Dark' or 'Kaku Light'

config.mouse_bindings = config.mouse_bindings or {}
table.insert(config.mouse_bindings, {
  event = { Down = { streak = 1, button = 'Right' } },
  mods = 'NONE',
  action = wezterm.action.PasteFrom('Clipboard'),
})

config.tab_close_confirmation = true
config.tab_title_show_basename_only = false

return config
