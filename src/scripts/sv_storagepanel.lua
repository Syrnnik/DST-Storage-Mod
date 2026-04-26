local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local TEMPLATES = require("widgets/templates")
local ImageButton = require("widgets/imagebutton")
local ScrollableList = require("widgets/scrollablelist")

local GRID_COLUMNS = 12
local GRID_CELL_WIDTH = 64
local GRID_SLOT_SCALE = 0.8
local GRID_ROW_HEIGHT = 64
local GRID_VISIBLE_ROWS = 4

local StoragePanel = Class(Widget, function(self, items)
  Widget._ctor(self, "StoragePanel")
  self:Close()

  self.items = items or {}

  self:SetHAnchor(ANCHOR_MIDDLE)
  self:SetVAnchor(ANCHOR_MIDDLE)
  self:SetPosition(0, 0)

  self.panel = self:AddChild(TEMPLATES.CenterPanel())
  self.panel:SetPosition(0, 0)

  self.title = self.panel:AddChild(Text(NEWFONT_OUTLINE, 56, "Склад"))
  self.title:SetPosition(0, 240)

  self.back_btn = self.panel:AddChild(TEMPLATES.BackButton(function()
    self:Close()
  end, ""))
  self.back_btn:SetPosition(-360, 240)

  self.loader =
    self.panel:AddChild(Text(NEWFONT_OUTLINE, 36, "Загружаем.."))
  self.loader:SetPosition(0, 0)

  self.empty_text =
    self.panel:AddChild(Text(NEWFONT_OUTLINE, 34, "Склад пуст"))
  self.empty_text:SetPosition(0, -10)
  self.empty_text:Hide()

  self.items_list = self.panel:AddChild(
    ScrollableList({}, 700, 360, GRID_ROW_HEIGHT, GRID_VISIBLE_ROWS)
  )
  self.items_list:SetPosition(0, -20)
  self.items_list:Hide()

  self:ShowItemsList(self.items)
end)

local function CreateItemCell(row, item, x, y)
  local slot = row:AddChild(ImageButton("images/hud.xml", "inv_slot.tex"))
  slot:SetPosition(x, y)
  slot:SetScale(GRID_SLOT_SCALE)
  slot:SetClickable(false)

  if item and item.name then
    local tex = item.name .. ".tex"
    slot.icon = slot:AddChild(Image(GetInventoryItemAtlas(tex), tex))
  end

  -- Number overlaps the top-center area of icon
  local item_count =
    row:AddChild(Text(NUMBERFONT, 28, tostring(item.count or 0)))
  item_count:SetPosition(x, y + 15)
end

local function CreateGridRow(items, start_index)
  local row = Widget("storage_item_row")

  -- ScrollableList rows are already positioned inside the panel area
  -- so grid should start from local row origin and go to the right
  local start_x = 0
  local y = 0

  for column = 1, GRID_COLUMNS do
    local item_index = start_index + column - 1
    local item = items[item_index]
    if not item then
      break
    end

    local x = start_x + (column - 1) * GRID_CELL_WIDTH
    CreateItemCell(row, item, x, y)
  end

  return row
end

function StoragePanel:ShowItemsList(items)
  self.loader:Hide()

  self.items = items or {}

  if #self.items == 0 then
    self.items_list:Hide()
    self.empty_text:Show()
    self.items_list:SetList({})
    return
  end

  self.empty_text:Hide()

  local rows = {}
  for i = 1, #self.items, GRID_COLUMNS do
    table.insert(rows, CreateGridRow(self.items, i))
  end

  self.items_list:SetList(rows)
  self.items_list:Show()
end

function StoragePanel:Open()
  self:Show()
  self:SetFocus()

  self.loader:Show()
  self.empty_text:Hide()
  self.items_list:Hide()
end

function StoragePanel:Close()
  self:Hide()
end

return StoragePanel
