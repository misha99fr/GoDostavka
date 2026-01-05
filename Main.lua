local GUI = require("GUI")
local system = require("System")
local screen = require("Screen")

-- Цвета (Яндекс-стиль)
local COLOR_BG = 0x1E1E1E
local COLOR_YELLOW = 0xFFD700
local COLOR_BUTTON = 0x2A2A2A
local COLOR_TEXT = 0xFFFFFF
local COLOR_ERROR = 0xFF5555
local COLOR_OK = 0x55FF55

local sw, sh = screen.getResolution()

local workspace, window = system.addWindow(
  GUI.window(1, 1, sw, sh, COLOR_BG)
)

window:addChild(GUI.panel(1, 1, sw, sh, COLOR_BG))

-- ===== ЗАГОЛОВОК =====
window:addChild(
  GUI.label(1, 2, sw, 1, COLOR_YELLOW, "GoDostavka")
):setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_TOP)

window:addChild(
  GUI.label(1, 4, sw, 1, COLOR_TEXT, "Прием заказов")
):setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_TOP)

-- ===== ВВОД =====
window:addChild(GUI.label(4, 6, 30, 1, COLOR_TEXT, "Введите 4 цифры:"))

window:addChild(GUI.panel(4, 8, 24, 3, 0x000000))

local code = ""
local codeLabel = window:addChild(
  GUI.label(4, 8, 24, 3, COLOR_YELLOW, "----")
)
codeLabel:setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_CENTER)

local statusLabel = window:addChild(
  GUI.label(4, 12, sw - 8, 1, COLOR_TEXT, "")
)

-- ===== КЛАВИАТУРА (ПОДНЯТА) =====
-- было: sh - 13
local keypadY = 14
local x0, y0 = 4, keypadY
local n = 1

for row = 0, 2 do
  for col = 0, 2 do
    local digit = tostring(n)
    window:addChild(
      GUI.button(
        x0 + col * 7,
        y0 + row * 3,
        6, 3,
        COLOR_BUTTON, COLOR_TEXT,
        COLOR_YELLOW, 0x000000,
        digit
      )
    ).onTouch = function()
      if #code < 4 then
        code = code .. digit
        codeLabel.text = code .. string.rep("-", 4 - #code)
        workspace:draw()
      end
    end
    n = n + 1
  end
end

-- 0
window:addChild(
  GUI.button(
    x0 + 7, y0 + 9,
    6, 3,
    COLOR_BUTTON, COLOR_TEXT,
    COLOR_YELLOW, 0x000000,
    "0"
  )
).onTouch = function()
  if #code < 4 then
    code = code .. "0"
    codeLabel.text = code .. string.rep("-", 4 - #code)
    workspace:draw()
  end
end

-- Сброс
window:addChild(
  GUI.button(
    x0 + 14, y0 + 9,
    12, 3,
    0x444444, COLOR_TEXT,
    0x666666, COLOR_TEXT,
    "Сброс"
  )
).onTouch = function()
  code = ""
  codeLabel.text = "----"
  statusLabel.text = ""
  workspace:draw()
end

-- Принять
window:addChild(
  GUI.button(
    x0 + 14, y0,
    12, 3,
    COLOR_YELLOW, 0x000000,
    0xFFE766, 0x000000,
    "Принять"
  )
).onTouch = function()
  if #code ~= 4 then
    statusLabel.text = "Введите ровно 4 цифры"
    statusLabel.color = COLOR_ERROR
  elseif code == "1999" then
    statusLabel.text = "❗ Код неправильный"
    statusLabel.color = COLOR_ERROR
  else
    statusLabel.text = "✅ Заказ принят: " .. code
    statusLabel.color = COLOR_OK
  end
  workspace:draw()
end

-- ===== ИСТОРИЯ =====
window:addChild(GUI.label(4, keypadY + 13, 30, 1, COLOR_YELLOW, "История заказов:"))

window:addChild(
  GUI.panel(
    4,
    keypadY + 14,
    sw - 8,
    sh - (keypadY + 16),
    0x111111
  )
)

local historyBox = window:addChild(
  GUI.textBox(
    4,
    keypadY + 14,
    sw - 8,
    sh - (keypadY + 16),
    0x111111,
    COLOR_TEXT,
    {},
    1,
    0,
    0
  )
)

local history = {}

local function addHistory(text)
  table.insert(history, 1, text)
  historyBox.lines = history
  workspace:draw()
end

-- Вставка истории при принятии
local oldAccept = window.children[#window.children - 3].onTouch

window.children[#window.children - 3].onTouch = function()
  if #code ~= 4 then
    statusLabel.text = "Введите ровно 4 цифры"
    statusLabel.color = COLOR_ERROR
  elseif code == "1999" then
    statusLabel.text = "❗ Код неправильный"
    statusLabel.color = COLOR_ERROR
    addHistory("❌ Неверный код: 1999")
  else
    statusLabel.text = "✅ Заказ принят: " .. code
    statusLabel.color = COLOR_OK
    addHistory("✔ Заказ принят: " .. code)
  end
  code = ""
  codeLabel.text = "----"
  workspace:draw()
end

workspace:draw()

