-- Radius in which we search for signs (tiles)
local SIGNS_TILES_RADIUS = 2

-- Which chest types to consider
local SPECIAL_CHESTS_TYPES = {
  treasurechest = true,
  -- TODO: add iceboxes
  -- icebox = true,
}

-- Specific turf type required for special chests
local GROUND = GLOBAL.WORLD_TILES.FUNGUSMOON

function IsSpecialChest(ent)
  local prefab = ent and ent.prefab

  -- Not valid container entity
  if not (ent and ent.components and ent.components.container) then
    print(
      "[Storage Viewer][IsSpecialChest] Rejected: not a container entity",
      tostring(ent),
      tostring(prefab)
    )
    return false
  end

  -- Not special chest type
  if not SPECIAL_CHESTS_TYPES[prefab] then
    print(
      "[Storage Viewer][IsSpecialChest] Rejected: prefab not in SPECIAL_CHESTS_TYPES",
      tostring(prefab)
    )
    return false
  end

  -- Check that it's placed on mushroom turf
  local pos = ent:GetPosition()
  local posX = pos.x
  local posZ = pos.z
  local ground = GLOBAL.TheWorld.Map:GetTileAtPoint(posX, 0, posZ)
  -- Not on required turf
  if ground ~= GROUND then
    print(
      "[Storage Viewer][IsSpecialChest] Rejected: not on MUSHROOMFIELD (found turf="
        .. tostring(ground)
        .. ", required turf="
        .. tostring(GROUND)
        .. ")",
      tostring(prefab),
      string.format("(%.2f, %.2f)", posX, posZ)
    )
    return false
  end

  -- Check that at least one minisign is nearby
  for _, obj in pairs(GLOBAL.Ents) do
    if obj.prefab == "minisign" then
      local objPos = obj:GetPosition()
      local dx = objPos.x - posX
      local dz = objPos.z - posZ

      -- Found nearby minisigns
      if (dx * dx + dz * dz) < SIGNS_TILES_RADIUS * SIGNS_TILES_RADIUS then
        print(
          "[Storage Viewer][IsSpecialChest] ACCEPTED:",
          tostring(prefab),
          string.format("(%.2f, %.2f)", posX, posZ)
        )
        return true
      end
    end
  end

  -- No nearby minisign
  print(
    "[Storage Viewer][IsSpecialChest] Rejected: no nearby minisign",
    tostring(prefab),
    string.format("(%.2f, %.2f)", posX, posZ)
  )

  return false
end

function GetSpecialChests()
  local result = {}
  print("[Storage Viewer][GetSpecialChests] Collecting special chests...")

  for _, ent in pairs(GLOBAL.Ents) do
    if IsSpecialChest(ent) then
      print(
        "[Storage Viewer][GetSpecialChests] Added chest:",
        tostring(ent.prefab),
        tostring(ent.GUID)
      )
      table.insert(result, ent)
    end
  end

  print(
    "[Storage Viewer][GetSpecialChests] Total special chests found:",
    tostring(#result)
  )
  return result
end
