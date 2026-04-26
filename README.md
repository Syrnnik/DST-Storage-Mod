# Storage Viewer

A Don't Starve Together mod that adds a quick Storage panel to view aggregated item counts from marked nearby containers

![Storage Viewer Preview](assets/storage-viewer-preview.png)

## Features

- Adds a HUD button and hotkey to open the Storage panel
- Shows item icons with total counts across tracked containers
- Treats containers near minisigns as storage containers
- Syncs storage data from server to client via mod RPC

## How Storage Detection Works

- Server tracks supported container prefabs
- A container is considered part of storage when a minisign is found nearby
- Item counts are aggregated on the server and sent to the client UI

## Configuration

- `SIGN_RADIUS` controls minisign lookup radius
- `ALLOW_TREASURECHEST` enables or disables treasure chest tracking
- `ALLOW_ICEBOX` enables or disables ice box tracking
- `ALLOW_SALTBOX` enables or disables salt box tracking
- `ALLOW_DRAGONFLYCHEST` enables or disables scaled chest tracking

## Project Structure

- `src/modmain.lua` mod entrypoint and module wiring
- `src/scripts/sv_modenv.lua` DST environment bridge
- `src/scripts/sv_settings.lua` settings and UI constants
- `src/scripts/sv_logger.lua` debug logger
- `src/scripts/sv_storage.lua` server storage tracking and aggregation
- `src/scripts/sv_server_rpc.lua` server RPC handlers
- `src/scripts/sv_client_rpc.lua` client RPC handlers and payload mapping
- `src/scripts/sv_client_controls.lua` HUD button and hotkey logic
- `src/scripts/sv_storagepanel.lua` storage panel widget
- `src/scripts/tableutils.lua` shared table utilities

## Development

- Run checks with `just check`
- Deploy local build with `just deploy`
- Override deploy target with `DST_LOCAL_MOD_DIR`
