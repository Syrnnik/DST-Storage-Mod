local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local TEMPLATES = require("widgets/templates")
local Grid = require("widgets/grid")
local ImageButton = require("widgets/imagebutton")

----------------------------------------------------------
-- Панель Списка Сундуков и их Предметов
----------------------------------------------------------
local StoragePanel = Class(Widget, function(self, chests)
  Widget._ctor(self, "StoragePanel")
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
  self.panel = self:AddChild(TEMPLATES.CenterPanel())
  self.panel:SetPosition(0, 0)

  self.title = self.panel:AddChild(Text(NEWFONT_OUTLINE, 56, "Склад"))
  self.title:SetPosition(0, 240)

  ------------------------------------------------------
  -- Грид с Сундуками
  ------------------------------------------------------
  self.grid = self.panel:AddChild(Grid())
  self.grid:SetPosition(0, 0)

  ------------------------------------------------------
  -- Кнопка Назад/Закрыть
  ------------------------------------------------------
  self.back_btn = self.panel:AddChild(TEMPLATES.BackButton(function()
    if not self.current_chest then
      self:Close()
    end
    self:ShowChestsList(self.chests)
  end, ""))
  self.back_btn:SetPosition(-360, 240)

  ------------------------------------------------------
  -- Лоадер
  ------------------------------------------------------
  self.loader =
    self.panel:AddChild(Text(NEWFONT_OUTLINE, 36, "Загружаем.."))
  self.loader:SetPosition(0, 0)

  ------------------------------------------------------
  -- Первичное заполнение
  ------------------------------------------------------
  self:ShowChestsList(self.chests)
end)

----------------------------------------------------------
-- Создание Слотов для Каждого Сундука
----------------------------------------------------------
function StoragePanel:CreateChestsSlots()
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
function StoragePanel:CreateChestSlot(item, chest)
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
function StoragePanel:ShowChestItems(chest)
  self.current_chest = chest

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
function StoragePanel:CreateItemSlot(item)
  local slot = ImageButton("images/hud.xml", "inv_slot.tex")

  local tex = item.name .. ".tex"
  slot.icon = slot:AddChild(Image(GetInventoryItemAtlas(tex), tex))

  if item.count and item.count > 1 then
    slot.count = slot:AddChild(Text(NUMBERFONT, 32, tostring(item.count)))
    slot.count:SetPosition(0, 16)
  end

  return slot
end

----------------------------------------------------------
-- Обновляем и Показываем Список Сундуков
----------------------------------------------------------
function StoragePanel:ShowChestsList(chests)
  -- Сбрасываем текущий сундук
  self.current_chest = nil

  self.loader:Hide()

  -- Обновляем Список Сундуков
  self.chests = chests or {}

  -- Собираем Список Слотов
  local slots = self:CreateChestsSlots()

  -- Очищаем Текущий Грид
  self.grid:Clear()
  -- Перезаполняем Грид Сундуками
  self.grid:FillGrid(self.cols, self.coffset, self.roffset, slots)

  -- Центрируем Грид
  self:CenterGrid(slots)
end

----------------------------------------------------------
-- Центрирование Грида
----------------------------------------------------------
function StoragePanel:CenterGrid(slots)
  local num_items = #slots
  local rows = math.ceil(num_items / self.cols)

  local width = (self.cols - 1) * self.coffset
  local height = (rows - 1) * self.roffset

  local center_x = -width / 2
  local center_y = height / 2

  self.grid:SetPosition(center_x, center_y)
  self.grid:Show()
end

----------------------------------------------------------
-- Открытие Панель
----------------------------------------------------------
function StoragePanel:Open()
  self:Show()
  self:SetFocus()

  self.loader:Show()
  self.grid:Hide()
end

----------------------------------------------------------
-- Закрытие Панели
----------------------------------------------------------
function StoragePanel:Close()
  self:Hide()
end

return StoragePanel
