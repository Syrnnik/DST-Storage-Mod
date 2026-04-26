-- DST injects modname into modmain, keep it for all submodules.
local ModEnv = require("sv_modenv")
local DST_GLOBAL = GLOBAL
local THE_NET = DST_GLOBAL and DST_GLOBAL.TheNet
local KEY_K_VALUE = DST_GLOBAL and DST_GLOBAL.KEY_K

if KEY_K_VALUE == nil then
  KEY_K_VALUE = (_G and _G.KEY_K) or nil
end

ModEnv.Set({
  MOD_NAME = modname,
  KEY_K = KEY_K_VALUE,
  GET_MOD_CONFIG_DATA = DST_GLOBAL and DST_GLOBAL.GetModConfigData or nil,
  TO_NUMBER = (DST_GLOBAL and DST_GLOBAL.tonumber) or tonumber,
  JSON = DST_GLOBAL and DST_GLOBAL.json or nil,
  GET_SIM = function()
    return DST_GLOBAL and DST_GLOBAL.TheSim or nil
  end,
  GET_WORLD = function()
    return DST_GLOBAL and DST_GLOBAL.TheWorld or nil
  end,
  ADD_PREFAB_POST_INIT = function(prefab, fn)
    return AddPrefabPostInit(prefab, fn)
  end,
  ADD_SIM_POST_INIT = function(fn)
    return AddSimPostInit(fn)
  end,
  ADD_MOD_RPC_HANDLER = function(namespace, name, fn)
    return AddModRPCHandler(namespace, name, fn)
  end,
  ADD_CLIENT_MOD_RPC_HANDLER = function(namespace, name, fn)
    return AddClientModRPCHandler(namespace, name, fn)
  end,
  SEND_MOD_RPC_TO_CLIENT = function(rpc, userid, ...)
    return SendModRPCToClient(rpc, userid, ...)
  end,
  GET_CLIENT_MOD_RPC = function()
    return CLIENT_MOD_RPC
  end,
  GET_MOD_RPC = function()
    return MOD_RPC
  end,
  SEND_MOD_RPC_TO_SERVER = function(rpc)
    return SendModRPCToServer(rpc)
  end,
  ADD_CLASS_POST_CONSTRUCT = function(target, fn)
    return AddClassPostConstruct(target, fn)
  end,
  GET_INPUT = function()
    return DST_GLOBAL and DST_GLOBAL.TheInput or nil
  end,
  GET_PLAYER = function()
    return DST_GLOBAL and DST_GLOBAL.ThePlayer or nil
  end,
})

modimport("scripts/sv_settings.lua")
modimport("scripts/sv_logger.lua")

if THE_NET ~= nil and THE_NET:GetIsServer() then
  modimport("scripts/sv_storage.lua")
  modimport("scripts/sv_server_rpc.lua")
end

if THE_NET ~= nil and not THE_NET:IsDedicated() then
  modimport("scripts/sv_storagepanel.lua")
  modimport("scripts/sv_client_rpc.lua")
  modimport("scripts/sv_client_controls.lua")
end
