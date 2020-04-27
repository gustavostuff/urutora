local colors = require 'colors'

local urutora = {
  nodes = {},
  stateStack = {},
  font = love.graphics.newFont(),
  defaults = {
    cb = function() end,
    w = 100,
    sliderValue = 0.5
  },
  nodeTypes = {
    LABEL = 1,
    BUTTON = 2,
    SLIDER = 3,
    CHECKBOX = 4,
    TEXT_FIELD = 5,
    MULTI_OPTION = 6,
    PANEL = 7
  },
  scanCodes = {
    BACKSPACE = 'backspace'
  },
  mouseButtons = {
    LEFT = 1
  },
  textAlignments = {
    LEFT = 'left'
  }
}

urutora.style = {
  padding = urutora.font:getHeight() / 2,
  bgColor = colors.LOVE_BLUE,
  hoverBgColor = colors.LOVE_BLUE_LIGHT,
  fgColor = colors.WHITE,
  hoverFgColor = colors.WHITE,
  cornerRadius = 0
}

---------------------------------------------------------------------------
---------------------------------------------------------------------------

local function isLabel(node) return node.type == urutora.nodeTypes.LABEL end
local function isPanel(node) return node.type == urutora.nodeTypes.PANEL end
local function isMulti(node) return node.type == urutora.nodeTypes.MULTI_OPTION end
local function isButton(node) return node.type == urutora.nodeTypes.BUTTON end
local function isTextField(node) return node.type == urutora.nodeTypes.TEXT_FIELD end
local function textWidth(t) return love.graphics.getFont():getWidth(t) end
local function textHeight(t) return love.graphics.getFont():getHeight() end
local function needsBase(node)
  return not (
    isPanel(node) or
    isLabel(node) or
    isTextField(node)
  )
end

local function saveState()
  local s = {}
  s.color = { love.graphics.getColor() }
  s.lineWidth = love.graphics.getLineWidth()
  s.lineStyle = love.graphics.getLineStyle()
  s.font = love.graphics.getFont()

  table.insert(urutora.stateStack, s)
end

local function restoreState()
  local s = table.remove(urutora.stateStack, #urutora.stateStack)

  love.graphics.setColor(s.color)
  love.graphics.setLineWidth(s.lineWidth)
  love.graphics.setLineStyle(s.lineStyle)
  love.graphics.setFont(s.font)
end

local function getMouse()
  return love.mouse.getX(), love.mouse.getY()
end

local function getLayerColors(node)
  if node.pointed then
    return urutora.style.hoverBgColor, urutora.style.hoverFgColor
  end

  return urutora.style.bgColor, urutora.style.fgColor
end


local function drawBaseRectangle(node)
  local bgc, _ = getLayerColors(node)
  love.graphics.setColor(node.bgColor or bgc)

  love.graphics.rectangle(node.baseMode or 'fill',
    (node.x),
    (node.y),
    (node.w),
    (node.h),
    (urutora.style.cornerRadius),
    (urutora.style.cornerRadius)
  )
end

local function drawText(node, alternativeText)
  local text = alternativeText or node.text

  if (not text) or (#text == 0) then
    return
  end

  local _, fgc = getLayerColors(node)
  local x = node.x + node.w / 2 - textWidth(text) / 2
  local y = node.y + node.h / 2 - textHeight(text) / 2
  
  if node.textAlign == urutora.textAlignments.LEFT then
    x = math.floor(node.px)
  end

  love.graphics.setColor(node.fgColor or fgc)
  love.graphics.print(text, x, y)
end

local function setFocusedNode(node)
  for _, node in ipairs(urutora.nodes) do
    node.focused = false
  end

  if node then node.focused = true end
end

local function drawBase(node)
  drawBaseRectangle(node)
  drawText(node)
end

local function isPointInsideNode(x, y, node)
  if not (x or y) then return end

  return not (
    x < node.x or
    x > (node.x + node.w) or
    y < node.y or
    y > (node.y + node.h)
  )
end

local function setBounds(node, x, y, w, h)
  local f = urutora.font
  node.padding = urutora.style.padding

  node.x = x
  node.y = y
  node.w = w or f:getWidth(node.text) + node.padding * 2
  node.h = h or f:getHeight() + node.padding * 2
  node.px = node.x + node.padding
  node.py = node.y + node.padding
end

local function initNode(node, data)
  node.text = data.text
  setBounds(
    node,
    data.x or 1,
    data.y or 1,
    data.w or urutora.defaults.w,
    data.h
  )

  function node:seGroup(g)
    self.group = g

    if self.childrenReferences then
      for _, child in ipairs(self.childrenReferences) do
        child.group = g
      end
    end

    return self
  end

  function node:action(f)
    self.callback = f
    return self
  end

  node.enabled = true
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.newLabel(data)
  data = data or {}
  local node = {}
  initNode(node, data)
  function node:update() end
  function node:draw() end

  node.type = urutora.nodeTypes.LABEL
  node.callback = urutora.defaults.cb
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.newButton(data)
  data = data or {}
  local node = {}
  initNode(node, data)
  function node:update() end
  function node:draw() end

  node.type = urutora.nodeTypes.BUTTON
  node.callback = urutora.defaults.cb
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.newSlider(data)
  data = data or {}
  local node = {}
  initNode(node, data)
  
  function node:draw()
    local _, fgc = getLayerColors(self)
    love.graphics.setColor(fgc)
    
    love.graphics.circle('fill',
      self.px + (self.w - self.padding * 2) * self.value,
      self.y + self.h / 2,
      self.padding
    )
  end
  
  function node:update(dt)
    local x, y = getMouse()

    if self.pressed then
      self.value = (x - (self.px)) / (self.w - self.padding * 2)
      if self.value > 1 then self.value = 1 end
      if self.value < 0 then self.value = 0 end
    end
  end

  node.type = urutora.nodeTypes.SLIDER
  node.callback = urutora.defaults.cb
  node.value = urutora.defaults.sliderValue
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.newToggle(data)
  data = data or {}
  local node = {}
  initNode(node, data)
  function node:update() end
  function node:draw() end
  function node:change()
    node.value = not node.value

    node.bgColor, node.fgColor = urutora.style.bgColor, urutora.style.fgColor
    if not node.value then
      node.bgColor, node.fgColor = colors.GRAY, colors.BLACK
    end
  end

  node.type = urutora.nodeTypes.CHECKBOX
  node.callback = urutora.defaults.cb
  node.value = true
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.newMulti(data)
  data = data or {}
  local node = {}
  initNode(node, data)
  function node:update() end
  function node:draw()
    local text = self.options[self.index]
    local _, fgc = getLayerColors(node)
    love.graphics.setColor(fgc)
    drawText(node, text)
  end
  function node:change()
    self.index = self.index + 1
    if self.index > #self.options then self.index = 1 end
  end

  node.type = urutora.nodeTypes.MULTI_OPTION
  node.callback = urutora.defaults.cb
  node.options = data.options or {}
  node.index = 1
  node.value = node.options[node.index]
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function urutora.newTextField(data)
  data = data or {}
  local node = {}
  initNode(node, data)

  function node:update() end
  function node:draw()
    local _, fgc = getLayerColors(self)
    love.graphics.setColor(fgc)
    love.graphics.print(self.value, self.x, self.py)

    if self.focused then
      local x = self.x + textWidth(self.value)
      love.graphics.print('_', x, self.py)
    end

    love.graphics.line(self.x, self.y + self.h, self.x + self.w, self.y + self.h)
  end
  function node:textInput(text, scancode)
    if scancode then
      if scancode == urutora.scanCodes.BACKSPACE then
        self.value = self.value:sub(1, #self.value - 1)
      end
    else
      if textWidth(self.value .. '_') < self.w then
        self.value = self.value .. (text or '')
      end
    end
  end

  node.type = urutora.nodeTypes.TEXT_FIELD
  node.callback = urutora.defaults.cb
  node.baseMode = 'line'
  node.value =  data.value or ''
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.newPanel(data)
  data = data or {}
  local node = {}
  initNode(node, data)

  function node:update() end
  function node:draw() end
  function node:add(newNode, row, col)
    local w, h = (self.w / self.cols), (self.h / self.rows)
    local x, y = self.x + w * (col - 1), self.y + h * (row - 1)
    local s = self.spacing / 2
    x, y = x + s, y + s
    w, h = w - s * 2, h - s * 2

    setBounds(newNode, x, y, w, h)
    table.insert(self.childrenReferences, newNode)
    return self
  end

  node.type = urutora.nodeTypes.PANEL
  node.callback = urutora.defaults.cb
  node.childrenReferences = {}
  node.rows = data.rows or 1
  node.cols = data.cols or 1
  node.spacing = data.spacing or 3
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.setGroupEnabled(g, value)
  for _, node in ipairs(urutora.nodes) do
    if node.group == g then
      node.enabled = value
    end
  end
end

function urutora.disableGroup(g)
  urutora.setGroupEnabled(g, false)
end

function urutora.enableGroup(g)
  urutora.setGroupEnabled(g, true)
end

function urutora.update(dt)
  for _, node in ipairs(urutora.nodes) do
    local x, y = getMouse()

    node.pointed = isPointInsideNode(x, y, node) and not isLabel(node)
    node:update(dt)
  end
end

function urutora.draw()
  saveState()
  love.graphics.setFont(urutora.font)
  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle('rough')
  
  for _, node in ipairs(urutora.nodes) do
    if needsBase(node) then
      drawBaseRectangle(node)
    end

    drawText(node)
    node:draw()
  end

  restoreState()
end

function urutora.pressed(x, y)
  local pressedOnNode = false

  for _, node in ipairs(urutora.nodes) do
    if not node.enabled then break end

    if isPointInsideNode(x, y, node) then
      node.pressed = true
      pressedOnNode = true
      setFocusedNode(node)
    end
  end

  if not pressedOnNode then
    setFocusedNode()
  end
end

function urutora.moved(x, y)
  --[[
  for _, node in ipairs(urutora.nodes) do
    if not node.enabled then break end
    --
  end
  ]]
end

function urutora.released(x, y)
  for _, node in ipairs(urutora.nodes) do
    urutora.doProperAction({
      node = node,
      x = x,
      y = y
    })
  end
end

function urutora.textinput(text)
  for _, node in ipairs(urutora.nodes) do
    urutora.doProperAction({
      node = node,
      text = text
    })
  end
end

function urutora.keypressed(k, scancode)
  for _, node in ipairs(urutora.nodes) do
    urutora.doProperAction({
      node = node,
      scancode = scancode
    })
  end
end

function urutora.doProperAction(data)
  local node = data.node -- "mandatory" field in data

  if not node.enabled then return end

  if node.type == urutora.nodeTypes.BUTTON then
    if isPointInsideNode(data.x, data.y, node) then
      node.callback({
        target = node
      })
    end
  elseif node.type == urutora.nodeTypes.CHECKBOX then
    if isPointInsideNode(data.x, data.y, node) then
      node:change()
    end
  elseif node.type == urutora.nodeTypes.TEXT_FIELD then
    if node.focused then
      node:textInput(data.text, data.scancode)
    end
  elseif node.type == urutora.nodeTypes.MULTI_OPTION then
    if isPointInsideNode(data.x, data.y, node) then
      node:change()
    end
  end

  node.pressed = false
end

return urutora
