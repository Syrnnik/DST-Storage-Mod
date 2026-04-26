local ImageButton = require("widgets/imagebutton")
local StoragePanel = require("sv_storagepanel")
local Settings = require("sv_settings")
local ModEnv = require("sv_modenv")
local Logger = require("sv_logger")

local STORAGE_VIEWER_ENV = ModEnv.Get()
local IS_HOTKEY_BOUND = false

local function GetPlayer()
  if type(STORAGE_VIEWER_ENV) ~= "table" then
    return nil
  end

  if type(STORAGE_VIEWER_ENV.GET_PLAYER) ~= "function" then
    return nil
  end

  return STORAGE_VIEWER_ENV.GET_PLAYER()
end

local function SendOpenMenuRPC()
  if type(STORAGE_VIEWER_ENV) ~= "table" then
    return
  end

  if
    type(STORAGE_VIEWER_ENV.GET_MOD_RPC) ~= "function"
    or type(STORAGE_VIEWER_ENV.SEND_MOD_RPC_TO_SERVER) ~= "function"
  then
    return
  end

  local mod_rpc = STORAGE_VIEWER_ENV.GET_MOD_RPC()
  local storage_namespace = mod_rpc and mod_rpc.storage_viewer
  local rpc = storage_namespace and storage_namespace.OpenStorageMenu

  -- Ensure client has local RPC id table for SendModRPCToServer
  if not rpc and type(STORAGE_VIEWER_ENV.ADD_MOD_RPC_HANDLER) == "function" then
    STORAGE_VIEWER_ENV.ADD_MOD_RPC_HANDLER(
      "storage_viewer",
      "OpenStorageMenu",
      function() end
    )
    mod_rpc = STORAGE_VIEWER_ENV.GET_MOD_RPC()
    storage_namespace = mod_rpc and mod_rpc.storage_viewer
    rpc = storage_namespace and storage_namespace.OpenStorageMenu
  end

  if not rpc then
    Logger.DebugPrint(
      "[Storage Viewer]",
      "OpenStorageMenu RPC is not registered"
    )
    return
  end

  Logger.DebugPrint("[Storage Viewer]", "Sending OpenStorageMenu RPC")
  STORAGE_VIEWER_ENV.SEND_MOD_RPC_TO_SERVER(rpc)
end

-- Places button above inventory center
local function UpdateStorageButtonPosition(storage_button)
  if not storage_button then
    return
  end

  storage_button:SetPosition(
    Settings.BUTTON_DEFAULT_X,
    Settings.BUTTON_DEFAULT_Y
  )
end

local function ToggleStorageMenu(player)
  player = player or GetPlayer()

  if not player or not player.HUD then
    return
  end

  local storage_menu = player.HUD.storage_menu

  -- Create panel widget once and reuse it between opens
  if not storage_menu then
    player.HUD.storage_menu = player.HUD:AddChild(StoragePanel())
    storage_menu = player.HUD.storage_menu
  end

  -- Toggle panel visibility and request fresh server data on open
  if storage_menu:IsVisible() then
    storage_menu:Close()
  else
    storage_menu:Open()
    SendOpenMenuRPC()
  end
end

-- Adds a HUD button for opening storage panel
local function EnsureHotkeyBound()
  if IS_HOTKEY_BOUND then
    return
  end

  local global_table = GLOBAL or (_G and _G.GLOBAL) or nil
  local key_code = Settings.OPEN_MENU_KEY
  if key_code == nil and global_table and global_table.KEY_K ~= nil then
    key_code = global_table.KEY_K
  end
  if key_code == nil and _G and _G.KEY_K ~= nil then
    key_code = _G.KEY_K
  end

  if key_code == nil then
    Logger.DebugPrint(
      "[Storage Viewer]",
      "Hotkey bind skipped: key code is nil"
    )
    return
  end

  local input = (global_table and global_table.TheInput) or TheInput
  if not input then
    Logger.DebugPrint(
      "[Storage Viewer]",
      "Hotkey bind skipped: TheInput is nil"
    )
    return
  end

  input:AddKeyDownHandler(key_code, function()
    ToggleStorageMenu()
  end)
  IS_HOTKEY_BOUND = true
  Logger.DebugPrint("[Storage Viewer]", "Hotkey bound")
end

if
  type(STORAGE_VIEWER_ENV) == "table"
  and type(STORAGE_VIEWER_ENV.ADD_CLASS_POST_CONSTRUCT) == "function"
then
  STORAGE_VIEWER_ENV.ADD_CLASS_POST_CONSTRUCT(
    "widgets/controls",
    function(controls)
      local parent = controls.bottom_root or controls.top_root
      controls.storage_btn = parent:AddChild(
        ImageButton(Settings.BUTTON_ICON_ATLAS, Settings.BUTTON_ICON_TEX)
      )
      controls.storage_btn:SetScale(1)
      controls.storage_btn:SetTooltip(Settings.BUTTON_TOOLTIP)
      controls.storage_btn:SetOnClick(function()
        ToggleStorageMenu(controls.owner)
      end)

      -- Position once after HUD is fully initialized
      controls.inst:DoTaskInTime(0, function()
        UpdateStorageButtonPosition(controls.storage_btn)
      end)

      -- Re-apply periodically in case HUD root is rebuilt by other mods
      controls.inst:DoPeriodicTask(
        Settings.BUTTON_REPOSITION_PERIOD_SEC,
        function()
          UpdateStorageButtonPosition(controls.storage_btn)
        end
      )
      -- Input may be unavailable during early mod load, so bind hotkey lazily
      EnsureHotkeyBound()
    end
  )
end

-- Attempt immediate binding as well for cases where input is already ready
EnsureHotkeyBound()
