local Settings = {}
local ModEnv = require("sv_modenv")

-- Reads environment prefilled in modmain without direct GLOBAL access.
local STORAGE_VIEWER_ENV = ModEnv.Get()

-- Small helper to keep numeric mod settings within expected bounds.
local function Clamp(number, min_value, max_value)
  if number < min_value then
    return min_value
  end

  if number > max_value then
    return max_value
  end

  return number
end

local function GetCurrentModName()
  if type(STORAGE_VIEWER_ENV) ~= "table" then
    return nil
  end

  local mod_name = STORAGE_VIEWER_ENV.MOD_NAME

  if type(mod_name) == "string" and mod_name ~= "" then
    return mod_name
  end

  return nil
end

-- Wrapper around GetModConfigData with safe fallback.
local function ReadRawSetting(name)
  local mod_name = GetCurrentModName()

  if mod_name == nil or type(STORAGE_VIEWER_ENV) ~= "table" then
    return nil
  end

  if type(STORAGE_VIEWER_ENV.GET_MOD_CONFIG_DATA) ~= "function" then
    return nil
  end

  return STORAGE_VIEWER_ENV.GET_MOD_CONFIG_DATA(name, mod_name)
end

local function ToNumber(value)
  if
    type(STORAGE_VIEWER_ENV) == "table"
    and type(STORAGE_VIEWER_ENV.TO_NUMBER) == "function"
  then
    return STORAGE_VIEWER_ENV.TO_NUMBER(value)
  end

  return nil
end

-- Reads boolean from mod settings with default fallback.
local function ReadBooleanSetting(name, default_value)
  local value = ReadRawSetting(name)

  if value == nil then
    return default_value
  end

  return value == true
end

-- Reads numeric setting and clamps it to safe interval.
local function ReadNumberSetting(name, default_value, min_value, max_value)
  local value = ToNumber(ReadRawSetting(name))

  if value == nil then
    value = default_value
  end

  return Clamp(value, min_value, max_value)
end

-- Radius for minisign lookup near chest.
Settings.SIGN_RADIUS = ReadNumberSetting("SIGN_RADIUS", 2, 1, 4)
Settings.DEBUG_LOGS = ReadBooleanSetting("DEBUG_LOGS", false)

-- Per-prefab switches from mod configuration screen.
Settings.ALLOWED_PREFABS = {
  treasurechest = ReadBooleanSetting("ALLOW_TREASURECHEST", true),
  icebox = ReadBooleanSetting("ALLOW_ICEBOX", true),
  saltbox = ReadBooleanSetting("ALLOW_SALTBOX", true),
  dragonflychest = ReadBooleanSetting("ALLOW_DRAGONFLYCHEST", true),
}

-- UI and input defaults for storage button behavior.
local open_menu_key = type(STORAGE_VIEWER_ENV) == "table"
    and STORAGE_VIEWER_ENV.KEY_K
  or nil

if open_menu_key == nil and _G and type(_G.KEY_K) == "number" then
  open_menu_key = _G.KEY_K
end

Settings.OPEN_MENU_KEY = open_menu_key
-- Position above inventory center
Settings.BUTTON_DEFAULT_X = 0
Settings.BUTTON_DEFAULT_Y = 120
Settings.BUTTON_REPOSITION_PERIOD_SEC = 2
Settings.BUTTON_ICON_ATLAS = "images/inventoryimages.xml"
Settings.BUTTON_ICON_TEX = "treasurechest.tex"
Settings.BUTTON_TOOLTIP = "Открыть Склад"

return Settings
