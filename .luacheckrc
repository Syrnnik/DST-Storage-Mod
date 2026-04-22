std = "lua51"
max_line_length = 80
allow_defined_top = true
exclude_files = {
  "scripts/**",
  "src/modinfo.lua",
}

files["src/scripts/finder.lua"] = {
  max_line_length = false,
}

globals = {
  "GLOBAL",
  "TheNet",
  "TheWorld",
  "TheSim",
  "Ents",
  "TUNING",
  "STRINGS",
  "PrefabFiles",
  "PrefabPostInit",
  "AddPrefabPostInit",
  "AddPlayerPostInit",
  "AddSimPostInit",
  "modimport",
  "AddClassPostConstruct",
  "Button",
  "SendModRPCToServer",
  "MOD_RPC",
  "AddModRPCHandler",
  "AddClientModRPCHandler",
  "SendRPCToClient",
  "Widget",
  "Class",
  "Text",
  "ScrollList",
  "DEFAULTFONT",
  "ThePlayer",
  "ANCHOR_MIDDLE",
  "SCALEMODE_PROPORTIONAL",
  "GetInventoryItemAtlas",
  "NEWFONT_OUTLINE",
  "NUMBERFONT",
  "HUD_ATLAS",
  "IsSpecialChest",
  "GetSpecialChests",
  "GetSpecialChestsDetails",
  "ToggleStorageMenu",
}
