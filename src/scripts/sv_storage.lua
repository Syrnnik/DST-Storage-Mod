local Logger = require("sv_logger")
local SETTINGS = require("sv_settings")
local ModEnv = require("sv_modenv")
local STORAGE_VIEWER_ENV = ModEnv.Get()

local Storage = {}

-- STORAGE is the server-side source of truth for storage data.
-- Key: chest GUID
-- Value: { id, type, x, z, items = { {name, count}, ... } }
local STORAGE = {}

-- TRACKED_CHESTS stores chest instances with attached event handlers.
-- This prevents duplicate event subscriptions for the same chest.
local TRACKED_CHESTS = {}

-- Prevent duplicate module initialization.
local IS_INITIALIZED = false

local function RemoveChestFromStorageByGuid(guid)
  STORAGE[guid] = nil
  TRACKED_CHESTS[guid] = nil
end

local function HasNearbySign(chest)
  -- Chest is treated as storage only when minisign exists nearby.
  local x, _, z = chest.Transform:GetWorldPosition()
  if type(STORAGE_VIEWER_ENV) ~= "table" then
    return false
  end

  local get_sim = STORAGE_VIEWER_ENV.GET_SIM
  if type(get_sim) ~= "function" then
    return false
  end

  local sim = get_sim()
  if sim == nil then
    return false
  end

  local entities = sim:FindEntities(x, 0, z, SETTINGS.SIGN_RADIUS)

  for _, ent in ipairs(entities) do
    if ent.prefab == "minisign" then
      return true
    end
  end

  return false
end

local function BuildItemsList(chest)
  -- Aggregate identical prefabs into one count entry.
  local items_map = {}

  for _, item in pairs(chest.components.container.slots) do
    if item and item.prefab then
      local stackable = item.components and item.components.stackable
      local count = stackable and stackable:StackSize() or 1
      items_map[item.prefab] = (items_map[item.prefab] or 0) + count
    end
  end

  local items_list = {}
  for name, count in pairs(items_map) do
    table.insert(items_list, {
      name = name,
      count = count,
    })
  end

  return items_list
end

local function IsValidChest(chest)
  -- Minimal technical checks before reading chest data.
  return chest
    and chest:IsValid()
    and chest.components
    and chest.components.container
end

local function IsValidStorageChest(chest)
  -- Storage chest must be technically valid, enabled in settings,
  -- and marked by nearby minisign.
  return IsValidChest(chest)
    and SETTINGS.ALLOWED_PREFABS[chest.prefab] == true
    and HasNearbySign(chest)
end

local function InitChestInStorage(chest)
  -- One function for add/update/remove of one chest entry.
  local guid = chest and chest.GUID
  if not guid then
    return
  end

  if not IsValidStorageChest(chest) then
    RemoveChestFromStorageByGuid(guid)
    return
  end

  local items = BuildItemsList(chest)
  if #items == 0 then
    RemoveChestFromStorageByGuid(guid)
    return
  end

  local x, _, z = chest.Transform:GetWorldPosition()
  STORAGE[guid] = {
    id = tostring(guid),
    type = chest.prefab,
    x = x,
    z = z,
    items = items,
  }
end

local function AttachChestHandlers(chest)
  if TRACKED_CHESTS[chest.GUID] then
    return
  end

  TRACKED_CHESTS[chest.GUID] = chest

  chest:ListenForEvent("onclose", InitChestInStorage)
  chest:ListenForEvent("itemget", InitChestInStorage)
  chest:ListenForEvent("itemlose", InitChestInStorage)
  chest:ListenForEvent("onremove", function(inst)
    RemoveChestFromStorageByGuid(inst.GUID)
  end)

  chest:DoTaskInTime(0, InitChestInStorage)
end

local function OnChestPrefabPostInit(chest)
  if type(STORAGE_VIEWER_ENV) ~= "table" then
    return
  end

  local get_world = STORAGE_VIEWER_ENV.GET_WORLD
  if type(get_world) ~= "function" then
    return
  end

  local world = get_world()
  if world == nil or not world.ismastersim then
    return
  end

  if not chest or SETTINGS.ALLOWED_PREFABS[chest.prefab] ~= true then
    return
  end

  AttachChestHandlers(chest)
end

function Storage.Initialize()
  if IS_INITIALIZED then
    return
  end
  IS_INITIALIZED = true

  if type(STORAGE_VIEWER_ENV) ~= "table" then
    return
  end

  local add_prefab_post_init = STORAGE_VIEWER_ENV.ADD_PREFAB_POST_INIT
  for prefab, enabled in pairs(SETTINGS.ALLOWED_PREFABS) do
    if enabled and type(add_prefab_post_init) == "function" then
      add_prefab_post_init(prefab, OnChestPrefabPostInit)
    end
  end

  local add_sim_post_init = STORAGE_VIEWER_ENV.ADD_SIM_POST_INIT
  local get_world = STORAGE_VIEWER_ENV.GET_WORLD
  if
    type(add_sim_post_init) == "function" and type(get_world) == "function"
  then
    add_sim_post_init(function()
      local world = get_world()
      if not world or not world.ismastersim then
        return
      end

      Logger.DebugPrint("[Storage Viewer]", "Storage initialized")
    end)
  end
end

function Storage.GetPayload()
  -- Return compact list for JSON transport.
  -- Sending GUID-keyed map can be encoded as sparse array with many nulls.
  local payload = {}
  for _, chest_data in pairs(STORAGE) do
    payload[#payload + 1] = chest_data
  end
  return payload
end

return Storage
