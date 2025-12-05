local ImageButton = require("widgets/imagebutton")
local json = GLOBAL.json or require("json")
local inspect = require("inspect")
local StoragePanel = require("chestspanel")

-- Кнопка на HUD (клиент)
AddClassPostConstruct("widgets/controls", function(controls)
  controls.storageBtn = controls.top_root:AddChild(
    ImageButton("images/inventoryimages.xml", "treasurechest.tex")
  )
  controls.storageBtn:SetPosition(-300, -220)
  controls.storageBtn:SetScale(1)
  controls.storageBtn:SetTooltip("Открыть склад")
  controls.storageBtn:SetOnClick(function()
    local player = controls.owner
    ToggleStorageMenu(player)
  end)
end)

-- Сервер: по запросу клиента отдаёт данные о сундуках (в JSON)
AddModRPCHandler("storage_viewer", "OpenStorageMenu", function(player)
  local chests = GetSpecialChestsDetails()
  print("[Storage Viewer]", "Found special chests", tostring(chests))
  local data = json.encode(chests)
  print("[Storage Viewer]", "Encoded data:", #data, tostring(data))

  GLOBAL.SendModRPCToClient(
    GLOBAL.CLIENT_MOD_RPC["storage_viewer"]["ShowStorageMenu"],
    player.userid,
    player,
    data
  )
end)

-- Клиент: принимает данные и открывает окно
AddClientModRPCHandler(
  "storage_viewer",
  "ShowStorageMenu",
  function(player, data)
    local storage_menu = player.HUD.storage_menu

    -- Проверяем что панель существует и не скрыта
    if not storage_menu then
      return
    end
    if not storage_menu:IsVisible() then
      return
    end

    local chests = json.decode(data)
    print("[Storage Viewer]", "Decoded data", inspect(chests), #chests)

    -- Обновляем данные сундуков
    storage_menu:ShowChestsList(chests)
  end
)

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_K, function()
  ToggleStorageMenu()
end)

function ToggleStorageMenu(player)
  player = player or GLOBAL.ThePlayer

  if not player or not player.HUD then
    return
  end

  local storage_menu = player.HUD.storage_menu

  -- Создаём окно, если его ещё нет
  if not storage_menu then
    player.HUD.storage_menu = player.HUD:AddChild(StoragePanel())
    -- GLOBAL.TheFrontEnd.overlayroot:AddChild(StoragePanel())
    -- controls.top_root:AddChild(StoragePanel())
    storage_menu = player.HUD.storage_menu
  end

  -- Переключение видимости
  if storage_menu:IsVisible() then
    storage_menu:Close()
  else
    storage_menu:Open()

    -- Запрашиваем обновление данных
    GLOBAL.SendModRPCToServer(
      GLOBAL.MOD_RPC["storage_viewer"]["OpenStorageMenu"]
    )
  end
end
