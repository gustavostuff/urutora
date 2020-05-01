local urutora = {
  nodes = {},
  sx = 1,
  sy = 1,
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
    PANEL = 7,
    JOY = 8
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

local path = ( ... ):match("(.+)%.[^%.]+$") or ( ... )
local utils = require(path .. '-utils')(urutora)

urutora.style = {
  p = urutora.font:getHeight() / 2, -- padding
  bgColor = utils.colors.LOVE_BLUE,
  fgColor = utils.colors.WHITE,
}

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.label(data)
  local node, data = utils.getCommons(urutora.nodeTypes.LABEL, data)
  node.textAlign = data.textAlign
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.button(data)
  local node, data = utils.getCommons(urutora.nodeTypes.BUTTON, data)
  node.textAlign = data.textAlign
  function node:draw() end
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.slider(data)
  local node, data = utils.getCommons(urutora.nodeTypes.SLIDER, data)

  function node:draw()
    local _, fgc = utils.getLayerColors(self)
    love.graphics.setColor(fgc)
    local x = self.x + (self.w - self.h / 2) * self.value
    utils.rect('fill', x, self.y, self.h / 2, self.h)
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
  local node, data = utils.getCommons(urutora.nodeTypes.TOGGLE, data)

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
  node.textAlign = data.textAlign
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.multi(data)
  local node, data = utils.getCommons(urutora.nodeTypes.MULTI, data)

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
  function node:setValue(text)
    local index = 1
    for i = 1, #self.items do
      index = i
      if self.items[i] == text then break end
    end

    self.index = index
    self.text = self.items[self.index]
  end

  node.textAlign = data.textAlign
  node.items = data.items or {}
  node.index = 1
  node.text = node.items[node.index]
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function urutora.text(data)
  local node, data = utils.getCommons(urutora.nodeTypes.TEXT, data)

  function node:draw()
    local _, fgc = utils.getLayerColors(self)
    local y = self.y + self.h
    local textY = self:centerY() - utils.textHeight(self) / 2
    love.graphics.setColor(fgc)
    love.graphics.line(self.x, y, self.x + self.w, y)

    if self.focused then
      utils.p('_', self.x + utils.textWidth(self), textY)
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
function urutora.joy(data)
  local node, data = utils.getCommons(urutora.nodeTypes.JOY, data)

  function node:limitMovement()
    if self.joyX >=  self:stickRadius() then self.joyX =  self:stickRadius() end
    if self.joyX <= -self:stickRadius() then self.joyX = -self:stickRadius() end
    if self.joyY >=  self:stickRadius() then self.joyY =  self:stickRadius() end
    if self.joyY <= -self:stickRadius() then self.joyY = -self:stickRadius() end
  end

  function node:getX() return self.joyX / self:stickRadius() end
  function node:getY() return self.joyY / self:stickRadius() end

  function node:draw()
    local _, fgc = utils.getLayerColors(self)
    love.graphics.setColor(fgc)
    utils.circ('fill',
      self:centerX() + self.joyX, self:centerY() + self.joyY, self:stickRadius())
  end

  node.joyX, node.joyY = 0, 0
  node.h = node.w
  function node:stickRadius() return self.h / 2 end
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.panel(data)
  local node, data = utils.getCommons(urutora.nodeTypes.PANEL, data)
  
  function node:addAt(row, col, newNode)
    local w, h = (self.w / self.cols), (self.h / self.rows)
    local x, y = self.x + w * (col - 1), self.y + h * (row - 1)
    local s = self.spacing / 2
    local rs = (self.rowspans[col] or {})[row] or 1
    local cs = (self.colspans[col] or {})[row] or 1
    x, y = x + s, y + s
    w, h = ((w * cs) - s * 2), ((h * rs) - s * 2)

    utils.setBounds(newNode, x, y, w, h)
    table.insert(self.children, newNode)
    return self
  end

  function node:rowspanAt(row, col, size)
    if not self.rowspans[col] then
      self.rowspans[col] = {}
    end

    self.rowspans[col][row] = size
    return self
  end

  function node:colspanAt(row, col, size)
    if not self.colspans[col] then
      self.colspans[col] = {}
    end

    self.colspans[col][row] = size
    return self
  end

  node.children = {}
  node.rows = data.rows or 1
  node.cols = data.cols or 1
  node.rowspans = {}
  node.colspans = {}
  node.spacing = data.spacing or 4
  
  table.insert(urutora.nodes, node)
  return node
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------

function urutora.setResolution(w, h)
  urutora.sx = love.graphics.getWidth() / w
  urutora.sy = love.graphics.getHeight() / h
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
    if node.update then node:update(dt) end

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
    if utils.needsBase(node) then utils.drawBaseRectangle(node)end
    if node.draw then node:draw() end
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

function urutora.moved(x, y, dx, dy)
  for _, node in ipairs(urutora.nodes) do
    urutora.performMovedAction({
      node = node,
      x = x, y = y,
      dx = dx, dy = dy
    })
  end
end

function urutora.released(x, y)
  for _, node in ipairs(urutora.nodes) do
    urutora.performReleaseAction({
      node = node,
      x = x,
      y = y
    })
  end
end

function urutora.textinput(text)
  for _, node in ipairs(urutora.nodes) do
    urutora.performKeyboardAction({
      node = node,
      text = text
    })
  end
end

function urutora.keypressed(k, scancode, isrepeat)
  for _, node in ipairs(urutora.nodes) do
    urutora.performKeyboardAction({
      node = node,
      scancode = scancode,
      isrepeat = isrepeat
    })
  end
end

function urutora.performKeyboardAction(data)
  local node = data.node -- "mandatory" field in data

  if node.type == urutora.nodeTypes.TEXT then
    if node.focused then
      local previousText = data.text
      node:textInput(data.text, data.scancode)
      node.callback({ target = node, value = {
        previousText = previousText,
        newText = node.text,
        scancode = data.scancode,
        textAdded = data.text
      }})
    end
  end
end

function urutora.performMovedAction(data)
  local node = data.node
  if not node.enabled then return end

  if node.type == urutora.nodeTypes.SLIDER then
    if node.focused then
      node.callback({ target = node, value = node.value })
    end
  elseif node.type == urutora.nodeTypes.JOY then
    if node.pressed then
      node.joyX = node.joyX + data.dx / urutora.sx
      node.joyY = node.joyY + data.dy / urutora.sx
      node:limitMovement()
    end
  end
end

function urutora.performReleaseAction(data)
  local node = data.node
  if not node.enabled then return end

  if node.pressed then
    if utils.isPointInsideNode(data.x, data.y, node) then
      if node.type == urutora.nodeTypes.BUTTON then
        node.callback({ target = node })
      elseif node.type == urutora.nodeTypes.TOGGLE then
        node:change()
        node.callback({ target = node, value = node.value })
      elseif node.type == urutora.nodeTypes.MULTI then
        node:change()
        node.callback({ target = node, value = node.text })
      end    
    end

    if node.type == urutora.nodeTypes.JOY then
      node.callback({ target = node, value = {
        lastX = node.joyX,
        lastY = node.joyY
      }})
      node.joyX, node.joyY = 0, 0
    end
  end

  node.pressed = false
end

return urutora
