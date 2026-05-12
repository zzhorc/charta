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
config.font = wezterm.font('MesloLGS NF')
config.font_size = 14.0
config.window_background_opacity = 0.9
config.macos_window_background_blur = 25
config.initial_cols = 120
config.initial_rows = 30
config.window_padding = { left = '20px', right = '20px', top = '40px', bottom = '20px' }
config.max_fps = 240
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.line_height = 1.20
config.enable_scroll_bar = true

-- ===== Custom Theme Definitions =====
local light_bg = '#D5D0B5'
local light_fg = '#3C3836'

local light_scheme = config.color_schemes and config.color_schemes['Kaku Light']
if light_scheme then
  light_scheme.background = light_bg
  light_scheme.foreground = light_fg
  light_scheme.cursor_bg = '#7C6F64'
  light_scheme.cursor_fg = light_bg
  light_scheme.selection_bg = '#BDB596'
  light_scheme.selection_fg = '#3C3836'
  light_scheme.ansi = {'#4C4F69','#D20F39','#40A02B','#DF8E1D','#1E66F5','#D27A8A','#179299','#ACB0BE'}
  light_scheme.brights = {'#7C7F93','#D20F39','#40A02B','#DF8E1D','#1E66F5','#E08999','#179299','#E6E9EF'}
  if light_scheme.tab_bar then
    light_scheme.tab_bar.background = light_bg
    if light_scheme.tab_bar.inactive_tab then light_scheme.tab_bar.inactive_tab.bg_color = light_bg end
    if light_scheme.tab_bar.new_tab then light_scheme.tab_bar.new_tab.bg_color = light_bg end
  end
end

local dark_scheme = config.color_schemes and config.color_schemes['Kaku Dark']
if dark_scheme then
  dark_scheme.ansi = {'#45475A','#F38BA8','#A6E3A1','#F9E2AF','#89B4FA','#D27A8A','#94E2D5','#BAC2DE'}
  dark_scheme.brights = {'#6C7086','#F38BA8','#A6E3A1','#F9E2AF','#89B4FA','#E08999','#94E2D5','#A6ADC8'}
end

-- ===== Robust Theme Resolution Logic =====
local function is_dark_mode()
  -- 1. Try WezTerm GUI API
  if wezterm.gui then
    local appearance = wezterm.gui.get_appearance()
    if appearance:find('Dark') then return true end
    if appearance:find('Light') then return false end
  end
  
  -- 2. Fallback to macOS system defaults (most reliable)
  local handle = io.popen('defaults read -g AppleInterfaceStyle 2>/dev/null')
  if handle then
    local result = handle:read('*a') or ''
    handle:close()
    return result:find('Dark') ~= nil
  end
  
  return false -- Final fallback
end

-- Only auto-switch if the scheme is set to 'Auto' or hasn't been explicitly locked to a theme
-- (This allows manual overrides from the Kaku menu to persist until the next restart/reload)
if config.color_scheme == 'Auto' or not config.color_scheme or config.color_scheme == '' then
  config.color_scheme = is_dark_mode() and 'Kaku Dark' or 'Kaku Light'
end

-- Apply Light-mode Titlebar fixes
if config.color_scheme == 'Kaku Light' then
  config.window_frame = {
    active_titlebar_bg = light_bg,
    inactive_titlebar_bg = light_bg,
    button_bg = light_bg,
    button_hover_bg = light_bg,
  }
end

config.mouse_bindings = config.mouse_bindings or {}
table.insert(config.mouse_bindings, {
  event = { Down = { streak = 1, button = 'Right' } },
  mods = 'NONE',
  action = wezterm.action.PasteFrom('Clipboard'),
})

config.tab_close_confirmation = true
config.tab_title_show_basename_only = false

return config
