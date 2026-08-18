name = "Storage Viewer"
description =
  [[Adds a Storage button and a hotkey (K) that show every item kept in your marked containers, with total counts.

Place a Mini Sign next to a container to mark it as storage. Chests, Ice Boxes, Salt Boxes and Scaled Chests are supported and can be turned off individually in the settings.]]
author = "Syrnnik"
version = "1.0"
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dst_compatible = true
all_clients_require_mod = true
server_only_mod = false
server_filter_tags = { "storage", "ui", "qol", "containers" }

configuration_options = {
  {
    name = "DEBUG_LOGS",
    label = "Debug Logs",
    options = {
      { description = "Disabled", data = false },
      { description = "Enabled", data = true },
    },
    default = false,
  },
  {
    name = "SIGN_RADIUS",
    label = "Storage Sign Radius",
    options = {
      { description = "1", data = 1 },
      { description = "2", data = 2 },
      { description = "3", data = 3 },
      { description = "4", data = 4 },
    },
    default = 2,
  },
  {
    name = "ALLOW_TREASURECHEST",
    label = "Track Treasure Chest",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "ALLOW_ICEBOX",
    label = "Track Ice Box",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "ALLOW_SALTBOX",
    label = "Track Salt Box",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
  {
    name = "ALLOW_DRAGONFLYCHEST",
    label = "Track Scaled Chest",
    options = {
      { description = "Enabled", data = true },
      { description = "Disabled", data = false },
    },
    default = true,
  },
}
