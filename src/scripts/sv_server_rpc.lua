local ModEnv = require("sv_modenv")
local STORAGE_VIEWER_ENV = ModEnv.Get()

local json = (type(STORAGE_VIEWER_ENV) == "table" and STORAGE_VIEWER_ENV.JSON)
  or require("json")
local Logger = require("sv_logger")
local Storage = require("sv_storage")
local TableUtils = require("tableutils")

local function EnsureClientShowMenuRPC()
  local get_client_mod_rpc = STORAGE_VIEWER_ENV.GET_CLIENT_MOD_RPC
  if type(get_client_mod_rpc) ~= "function" then
    return nil
  end

  local client_mod_rpc = get_client_mod_rpc()
  local storage_viewer_rpc = client_mod_rpc and client_mod_rpc["storage_viewer"]
  local show_storage_menu_rpc = storage_viewer_rpc
    and storage_viewer_rpc["ShowStorageMenu"]

  if show_storage_menu_rpc then
    return show_storage_menu_rpc
  end

  local add_client_mod_rpc_handler =
    STORAGE_VIEWER_ENV.ADD_CLIENT_MOD_RPC_HANDLER
  if type(add_client_mod_rpc_handler) ~= "function" then
    return nil
  end

  -- Register ID table on this side if it is missing
  add_client_mod_rpc_handler(
    "storage_viewer",
    "ShowStorageMenu",
    function() end
  )

  client_mod_rpc = get_client_mod_rpc()
  storage_viewer_rpc = client_mod_rpc and client_mod_rpc["storage_viewer"]
  return storage_viewer_rpc and storage_viewer_rpc["ShowStorageMenu"]
end

-- Server starts storage tracking once during mod init
Storage.Initialize()

-- Handles client request and sends full STORAGE snapshot to that client
if
  type(STORAGE_VIEWER_ENV) == "table"
  and type(STORAGE_VIEWER_ENV.ADD_MOD_RPC_HANDLER) == "function"
then
  STORAGE_VIEWER_ENV.ADD_MOD_RPC_HANDLER(
    "storage_viewer",
    "OpenStorageMenu",
    function(player)
      if not player or not player.userid then
        return
      end

      local storage = Storage.GetPayload()
      local data = json.encode(storage)

      Logger.DebugPrint(
        "[Storage Viewer]",
        "Storage entries:",
        tostring(TableUtils.CountEntries(storage))
      )

      local show_storage_menu_rpc = EnsureClientShowMenuRPC()

      if
        type(STORAGE_VIEWER_ENV.SEND_MOD_RPC_TO_CLIENT) == "function"
        and show_storage_menu_rpc
      then
        -- Send only encoded payload to client handler
        STORAGE_VIEWER_ENV.SEND_MOD_RPC_TO_CLIENT(
          show_storage_menu_rpc,
          player.userid,
          data
        )
      else
        Logger.DebugPrint(
          "[Storage Viewer]",
          "ShowStorageMenu RPC is not registered on server side"
        )
      end
    end
  )
end
