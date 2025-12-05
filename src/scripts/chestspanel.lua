local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local TEMPLATES = require("widgets/templates")
local Grid = require("widgets/grid")
local ImageButton = require("widgets/imagebutton")

-- TODO: add loading state
-- TODO: set loading to true on open
-- TODO: if loading, show spinner

----------------------------------------------------------
-- Панель Списка Сундуков и их Предметов
----------------------------------------------------------
local ChestsPanel = Class(Widget, function(self, chests)
  Widget._ctor(self, "ChestsPanel")
  self:Close()

  self.slot_size = 70
  self.chests = chests or {}
  self.current_chest = nil
  self.cols = 3
  self.coffset = 90
  self.roffset = 90

  -- Центрируем
  self:SetHAnchor(ANCHOR_MIDDLE)
  self:SetVAnchor(ANCHOR_MIDDLE)
  self:SetPosition(0, 0)

  ------------------------------------------------------
  -- Панель
  ------------------------------------------------------
  self.panel = self:AddChild(TEMPLATES.CenterPanel(1, 1, false, 200, 400))
  self.panel:SetPosition(0, 0)

  self.title = self.panel:AddChild(Text(NEWFONT_OUTLINE, 48, "Сундуки"))
  self.title:SetPosition(0, 240)

  ------------------------------------------------------
  -- Грид с Сундуками
  ------------------------------------------------------
  self.grid = self.panel:AddChild(Grid())
  self.grid:SetPosition(0, 0)

  ------------------------------------------------------
  -- Кнопка Закрытия
  ------------------------------------------------------
  self.close_btn = self.panel:AddChild(TEMPLATES.BackButton(
    function()
      self:Close()
    end,
    "Закрыть",
    {
      x = 30,
      y = 0,
    }
  ))
  self.close_btn:SetPosition(-360, 240)

  ------------------------------------------------------
  -- Кнопка Назад
  ------------------------------------------------------
  self.back_btn = self.panel:AddChild(TEMPLATES.BackButton(
    function()
      self:ShowChestsList()
    end,
    "Назад",
    {
      x = 10,
      y = 0,
    }
  ))
  self.back_btn:SetPosition(-360, 240)

  ------------------------------------------------------
  -- Первичное заполнение
  ------------------------------------------------------
  self:ShowChestsList(self.chests)
end)

----------------------------------------------------------
-- Обновление Списка Сундуков
----------------------------------------------------------
function ChestsPanel:UpdateChests(chests)
  self.chests = chests or {}

  -- Список виджетов
  local slots = self:CreateChestsSlots()

  -- Очищаем текущий грид
  self.grid:Clear()
  -- Перезаполняем грид сундуками
  self.grid:FillGrid(self.cols, self.coffset, self.roffset, slots)

  -- Центрируем грид
  self:CenterGrid(slots)
end

----------------------------------------------------------
-- Создание Слотов для Каждого Сундука
----------------------------------------------------------
function ChestsPanel:CreateChestsSlots()
  local widgets = {}

  for _, chest in ipairs(self.chests) do
    -- Первый предмет
    local item = chest.items[1]
    local slot = self:CreateChestSlot(item, chest)
    table.insert(widgets, slot)
  end

  return widgets
end

----------------------------------------------------------
-- Создание Слота для Сундука
----------------------------------------------------------
function ChestsPanel:CreateChestSlot(item, chest)
  local slot = ImageButton("images/hud.xml", "inv_slot.tex")

  -- Иконка
  if item then
    local item_tex = item.name .. ".tex"
    slot.icon = slot:AddChild(Image(GetInventoryItemAtlas(item_tex), item_tex))
  end

  -- Нажатие на слот
  slot:SetOnClick(function()
    print("Click on slot", tostring(item.name))
    self:ShowChestItems(chest)
  end)

  return slot
end

----------------------------------------------------------
-- Показываем Содержимое Сундука
----------------------------------------------------------
function ChestsPanel:ShowChestItems(chest)
  self.current_chest = chest

  self.back_btn:Show()
  self.close_btn:Hide()

  -- Очищаем текущий грид
  self.grid:Clear()

  -- Создаём список слотов для предметов
  local slots = {}
  for _, item in ipairs(chest.items) do
    local slot = self:CreateItemSlot(item)
    table.insert(slots, slot)
  end

  -- Заполняем грид предметами
  self.grid:FillGrid(self.cols, self.coffset, self.roffset, slots)

  -- Центрируем грид
  self:CenterGrid(slots)
end

----------------------------------------------------------
-- Создание Слота для Предмета
----------------------------------------------------------
function ChestsPanel:CreateItemSlot(item)
  local slot = ImageButton("images/hud.xml", "inv_slot.tex")

  local tex = item.name .. ".tex"
  slot.icon = slot:AddChild(Image(GetInventoryItemAtlas(tex), tex))

  if item.count and item.count > 1 then
    slot.count = slot:AddChild(Text(NEWFONT_OUTLINE, 32, tostring(item.count)))
    slot.count:SetPosition(20, -20)
  end

  return slot
end

----------------------------------------------------------
-- Показываем список сундуков
----------------------------------------------------------
function ChestsPanel:ShowChestsList(chests)
  -- Сбрасываем текущий сундук
  self.current_chest = nil

  self.back_btn:Hide()
  self.close_btn:Show()

  -- Обновляем список сундуков
  self:UpdateChests(chests or self.chests)
end

----------------------------------------------------------
-- Центрирование Грида
----------------------------------------------------------
function ChestsPanel:CenterGrid(slots)
  local num_items = #slots
  local rows = math.ceil(num_items / self.cols)

  local width = (self.cols - 1) * self.coffset
  local height = (rows - 1) * self.roffset

  local center_x = -width / 2
  local center_y = height / 2

  self.grid:SetPosition(center_x, center_y)
end

----------------------------------------------------------
-- Открытие Панель
----------------------------------------------------------
function ChestsPanel:Open()
  self:Show()
  self:SetFocus()
end

----------------------------------------------------------
-- Закрытие Панели
----------------------------------------------------------
function ChestsPanel:Close()
  self:Hide()
end

return ChestsPanel
