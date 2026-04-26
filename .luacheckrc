std = "lua51"
max_line_length = 80
allow_defined_top = true
exclude_files = {
  "scripts/**",
  "src/modinfo.lua",
}

globals = {
  "GLOBAL",
  "modimport",
  "modname",
  "KEY_K",
  "GetModConfigData",
  "json",
  "TheSim",
  "TheWorld",
  "AddPrefabPostInit",
  "AddSimPostInit",
  "AddModRPCHandler",
  "SendModRPCToClient",
  "CLIENT_MOD_RPC",
  "Class",
  "ANCHOR_MIDDLE",
  "ANCHOR_BOTTOM",
  "NEWFONT_OUTLINE",
  "NUMBERFONT",
  "GetInventoryItemAtlas",
  "ThePlayer",
  "SendModRPCToServer",
  "MOD_RPC",
  "AddClassPostConstruct",
  "TheInput",
  "AddClientModRPCHandler",
}
