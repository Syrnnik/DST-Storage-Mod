-- Collect single chest details
local function GetChestDetails(chest)
  local guid = chest.GUID
  local prefab = chest.prefab

  print(
    "[Storage Viewer]",
    "Gathering chest details for chest GUID:",
    tostring(guid),
    "Prefab:",
    tostring(prefab)
  )

  local pos = chest:GetPosition()
  local details = {
    id = tostring(guid),
    type = prefab,
    x = pos.x,
    z = pos.z,
    items = {},
  }

  for slot_idx, v in pairs(chest.components.container.slots) do
    if v then
      local name = v.prefab
      local stackable = v.components.stackable
      local count = stackable and stackable:StackSize() or 1
      print(
        "[Storage Viewer]",
        "Chest",
        tostring(guid),
        "Slot:",
        tostring(slot_idx),
        "Item:",
        tostring(name),
        "Count:",
        tostring(count)
      )

      -- Проверяем, есть ли уже предмет с таким именем в списке
      local found = false
      for _, existing_item in ipairs(details.items) do
        if existing_item.name == name then
          existing_item.count = existing_item.count + count
          found = true
          break
        end
      end

      -- Если такого предмета еще нет, добавляем новый элемент
      if not found then
        local item = {
          name = name,
          count = count,
        }
        table.insert(details.items, item)
      end
    else
      print(
        "[Storage Viewer]",
        "Chest",
        tostring(guid),
        "Slot:",
        tostring(slot_idx),
        "is empty."
      )
    end
  end

  return details
end

function GetSpecialChestsDetails()
  print("[Storage Viewer]", "Getting all special chests details...")
  local chests = GetSpecialChests()
  local allChestsDetails = {}

  print("[Storage Viewer]", "Total special chests:", tostring(#chests))

  for _, chest in ipairs(chests) do
    local detail = GetChestDetails(chest)
    table.insert(allChestsDetails, detail)
  end

  return allChestsDetails
end
