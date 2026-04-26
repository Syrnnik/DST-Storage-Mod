local json = json or require("json")
local Logger = require("sv_logger")
local TableUtils = require("tableutils")
local StoragePanel = require("sv_storagepanel")
local ModEnv = require("sv_modenv")

local STORAGE_VIEWER_ENV = ModEnv.Get()

local function ToNumber(value)
  if
    type(STORAGE_VIEWER_ENV) == "table"
    and type(STORAGE_VIEWER_ENV.TO_NUMBER) == "function"
  then
    return STORAGE_VIEWER_ENV.TO_NUMBER(value)
  end

  return (GLOBAL and GLOBAL.tonumber and GLOBAL.tonumber(value))
    or (_G and _G.tonumber and _G.tonumber(value))
end

local function GetCurrentPlayer()
  if
    type(STORAGE_VIEWER_ENV) == "table"
    and type(STORAGE_VIEWER_ENV.GET_PLAYER) == "function"
  then
    local player = STORAGE_VIEWER_ENV.GET_PLAYER()
    if player then
      return player
    end
  end

  if GLOBAL and GLOBAL.ThePlayer then
    return GLOBAL.ThePlayer
  end

  return ThePlayer
end

local function BuildItemsListFromStorage(storage)
  local items_map = {}

  for _, chest in pairs(storage or {}) do
    if chest and chest.items then
      for _, item in ipairs(chest.items) do
        if item and item.name then
          local count = ToNumber(item.count) or 0
          items_map[item.name] = (items_map[item.name] or 0) + count
        end
      end
    end
  end

  local items_list = {}
  for name, count in pairs(items_map) do
    table.insert(items_list, {
      name = name,
      count = count,
    })
  end

  table.sort(items_list, function(left_item, right_item)
    if left_item.count == right_item.count then
      return left_item.name < right_item.name
    end

    return left_item.count > right_item.count
  end)

  return items_list
end

-- Receives storage snapshot from server and forwards it into opened UI panel
-- Supports both handler signatures:
-- 1) function(data)
-- 2) function(player, data)
AddClientModRPCHandler("storage_viewer", "ShowStorageMenu", function(arg1, arg2)
  local data
  local player

  if arg2 ~= nil then
    player = arg1
    data = arg2
  else
    data = arg1
    player = GetCurrentPlayer()
  end

  Logger.DebugPrint(
    "[Storage Viewer]",
    "ShowStorageMenu RPC received",
    "arg1:",
    type(arg1),
    "arg2:",
    type(arg2),
    "payload:",
    type(data)
  )

  if not player or not player.HUD then
    Logger.DebugPrint("[Storage Viewer]", "Skip response: player or HUD is nil")
    return
  end

  local storage_menu = player.HUD.storage_menu

  -- Create panel on-demand if RPC response wins the initialization race
  if not storage_menu then
    player.HUD.storage_menu = player.HUD:AddChild(StoragePanel())
    storage_menu = player.HUD.storage_menu
  end

  if not storage_menu:IsVisible() then
    storage_menu:Open()
  end

  if type(data) ~= "string" then
    Logger.DebugPrint(
      "[Storage Viewer]",
      "Skip response: payload is not string, got:",
      type(data)
    )
    return
  end

  local storage = json.decode(data) or {}
  local items_list = BuildItemsListFromStorage(storage)
  Logger.DebugPrint(
    "[Storage Viewer]",
    "Received unique items:",
    tostring(TableUtils.CountEntries(items_list))
  )

  storage_menu:ShowItemsList(items_list)
end)
