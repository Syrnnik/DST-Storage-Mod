local Logger = {}
local Settings = require("sv_settings")

-- Reads debug mode from centralized settings module.
local DEBUG = Settings.DEBUG_LOGS == true

-- Use this for debug-only logs across modules.
function Logger.DebugPrint(...)
  if DEBUG then
    print(...)
  end
end

function Logger.IsDebugEnabled()
  return DEBUG
end

-- Optional runtime override for local debugging.
function Logger.SetDebugEnabled(value)
  DEBUG = value and true or false
end

return Logger
