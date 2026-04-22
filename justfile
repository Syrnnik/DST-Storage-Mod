default:
  @just --list

check:
  stylua --check src
  luacheck src
