local urutora = {
  nodes = {},
  stateStack = {},
  sx = love.graphics.getWidth(),
  sy = love.graphics.getHeight(),
  font = love.graphics.newFont(14),
  defaults = {
    cb = function() end,
    w = 100,
    sliderValue = 0.5
  },
  nodeTypes = {
    LABEL = 1,
    BUTTON = 2,
    SLIDER = 3,
    TOGGLE = 4,
    TEXT = 5,
    MULTI = 6,
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

local utils = require('urutora-utils')(urutora)

urutora.style = {
  p = urutora.font:getHeight() / 2, -- padding
  bgColor = utils.colors.LOVE_BLUE,
  fgColor = utils.colors.WHITE,
}

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.label(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  function node:update() end
  function node:draw() end

  node.type = urutora.nodeTypes.LABEL
  node.callback = urutora.defaults.cb
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.button(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  function node:update() end
  function node:draw() end

  node.type = urutora.nodeTypes.BUTTON
  node.callback = urutora.defaults.cb
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.slider(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  node.callback = urutora.defaults.cb
  node.type = urutora.nodeTypes.SLIDER
  
  function node:draw()
    local _, fgc = utils.getLayerColors(self)
    love.graphics.setColor(fgc)
    local x = self.px + (self.w - self.p * 2) * self.value
    local y = self.y + self.h / 2

    utils.rect('fill',
      x - self.p / 2,
      y - self.p,
      self.p,
      self.p * 2
    )
  end
  
  function node:update(dt)
    local x, y = utils.getMouse()

    if self.pressed then
      self.value = (x - (self.px)) / (self.w - self.p * 2)
      if self.value > 1 then self.value = 1 end
      if self.value < 0 then self.value = 0 end
    end
  end

  node.value = data.value or urutora.defaults.sliderValue
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.toggle(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  node.callback = urutora.defaults.cb
  node.type = urutora.nodeTypes.TOGGLE

  function node:update() end
  function node:draw()
    if self.value then
      utils.drawBaseRectangle(self)
    else
      utils.drawBaseRectangle(self, utils.colors.GRAY)
    end
  end
  function node:change()
    self.value = not self.value
  end

  node.value = data.value
  node.text = data.text
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.multi(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  node.callback = urutora.defaults.cb
  node.type = urutora.nodeTypes.MULTI

  function node:update() end
  function node:draw()
    local text = self.items[self.index]
    local _, fgc = utils.getLayerColors(node)
    love.graphics.setColor(fgc)
    utils.drawText(node, text)
  end
  function node:change()
    self.index = self.index + 1
    if self.index > #self.items then self.index = 1 end
    self.text = self.items[self.index]
  end

  node.items = data.items or {}
  node.index = 1
  node.text = node.items[node.index]
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function urutora.text(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  node.callback = urutora.defaults.cb
  node.type = urutora.nodeTypes.TEXT

  function node:update() end
  function node:draw()
    local _, fgc = utils.getLayerColors(self)
    love.graphics.setColor(fgc)
    local y = self.centerY + self.p
    love.graphics.line(self.x, y, self.x + self.w, y)

    if self.focused then
      utils.p('_',
        self.x + utils.textWidth(self),
        self.centerY - utils.textHeight(self) / 2
      )
    end
  end
  function node:textInput(text, scancode)
    if scancode == urutora.scanCodes.BACKSPACE then
      self.text = self.text:sub(1, #self.text - 1)
    else
      if utils.textWidth(self) <= self.npw then
        self.text = self.text .. (text or '')
      end
    end
  end

  node.textAlign = urutora.textAlignments.LEFT
  node.text =  data.text or ''
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.panel(data)
  data = data or {}
  local node = {}
  utils.initNode(node, data)
  node.callback = urutora.defaults.cb
  node.type = urutora.nodeTypes.PANEL
  
  function node:update() end
  function node:draw() end
  function node:addAt(row, col, newNode)
    local w, h = (self.w / self.cols), (self.h / self.rows)
    local x, y = self.x + w * (col - 1), self.y + h * (row - 1)
    local s = self.spacing / 2
    x, y = x + s, y + s
    w, h = w - s * 2, h - s * 2

    utils.setBounds(newNode, x, y, w, h)
    table.insert(self.children, newNode)
    return self
  end

  node.children = {}
  node.rows = data.rows or 1
  node.cols = data.cols or 1
  node.spacing = data.spacing or 4
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.setResolution(canvas)
  urutora.canvas = canvas
  urutora.w, urutora.h = canvas:getWidth(), canvas:getHeight()
  urutora.sx = love.graphics.getWidth() / urutora.w
  urutora.sy = love.graphics.getHeight() / urutora.h
end

function urutora.setGroupEnabled(g, value)
  for _, node in ipairs(urutora.nodes) do
    if node.group == g then
      node.enabled = value
    end
  end
end

function urutora.setGroupVisible(g, value)
  for _, node in ipairs(urutora.nodes) do
    if node.group == g then
      node.visible = value
    end
  end
end

function urutora.enableGroup(g) urutora.setGroupEnabled(g, true) end
function urutora.disableGroup(g) urutora.setGroupEnabled(g, false) end

function urutora.showGroup(g) urutora.setGroupVisible(g, true) end
function urutora.hideGroup(g) urutora.setGroupVisible(g, false) end

function urutora.activateGroup(g)
  urutora.setGroupEnabled(g, true)
  urutora.setGroupVisible(g, true)
  return urutora
end

function urutora.deactivateGroup(g)
  urutora.setGroupEnabled(g, false)
  urutora.setGroupVisible(g, false)
  return urutora
end

function urutora.update(dt)
  for _, node in ipairs(urutora.nodes) do
    local x, y = utils.getMouse()
    if not node.enabled then goto continue end

    node.pointed = utils.isPointInsideNode(x, y, node) and not utils.isLabel(node)
    node:update(dt)

    ::continue::
  end
end

function urutora.draw()
  love.graphics.push('all')

  love.graphics.setFont(urutora.font)
  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle('rough')
  love.graphics.setFont(urutora.font)
  
  for _, node in ipairs(urutora.nodes) do
    if not node.visible then goto continue end

    if utils.needsBase(node) then
      utils.drawBaseRectangle(node)
    end

    node:draw()
    utils.drawText(node)

    ::continue::
  end
  
  love.graphics.pop()
end

function urutora.pressed(x, y)
  local pressedOnNode = false

  for _, node in ipairs(urutora.nodes) do
    if not node.enabled then goto continue end

    if utils.isPointInsideNode(x, y, node) then
      node.pressed = true
      pressedOnNode = true
      utils.setFocusedNode(node)
    end

    ::continue::
  end

  if not pressedOnNode then
    utils.setFocusedNode()
  end
end

function urutora.moved(x, y) end

function urutora.released(x, y)
  for _, node in ipairs(urutora.nodes) do
    urutora.performAction({
      node = node,
      x = x,
      y = y
    })
  end
end

function urutora.textinput(text)
  for _, node in ipairs(urutora.nodes) do
    urutora.performAction({
      node = node,
      text = text
    })
  end
end

function urutora.keypressed(k, scancode, isrepeat)
  for _, node in ipairs(urutora.nodes) do
    urutora.performAction({
      node = node,
      scancode = scancode,
      isrepeat = isrepeat
    })
  end
end

function urutora.performAction(data)
  local node = data.node -- "mandatory" field in data

  if not node.enabled then return end

  if node.type == urutora.nodeTypes.BUTTON then
    if node.pressed and utils.isPointInsideNode(data.x, data.y, node) then
      node.callback({ target = node })
    end
  elseif node.type == urutora.nodeTypes.TOGGLE then
    if utils.isPointInsideNode(data.x, data.y, node) then
      node:change()
      node.callback({ target = node, value = node.value })
    end
  elseif node.type == urutora.nodeTypes.TEXT then
    if node.focused then
      node:textInput(data.text, data.scancode)
      if data.isrepeat then
        love.event.quit()
      end
    end
  elseif node.type == urutora.nodeTypes.MULTI then
    if utils.isPointInsideNode(data.x, data.y, node) then
      node:change()
    end
  end

  node.pressed = false
end

return urutora
