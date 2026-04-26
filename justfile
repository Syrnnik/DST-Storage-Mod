dst_mod_dir := env_var_or_default(
  "DST_LOCAL_MOD_DIR",
  "$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods/storage-viewer",
)

default:
  @just --list

check:
  stylua --check src
  luacheck src

deploy:
  mkdir -p "{{dst_mod_dir}}"
  sudo rsync -a --delete src/ "{{dst_mod_dir}}/"
  @echo "Deployed mod to {{dst_mod_dir}}"
