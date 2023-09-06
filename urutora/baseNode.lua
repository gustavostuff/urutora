local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local class = require(modules .. 'class')
local utils = require(modules .. 'utils')

local baseNode = class('baseNode')

function baseNode:constructor()
  self.callback = function () end
  self.align = self.align or utils.alignments.CENTER

  local f = utils.default_font
  local p = self.padding or utils.style.padding
  self:setBounds(
    self.x or 0,
    self.y or 0,
    (self.w or (self.text and f:getWidth(self.text)) or 20),
    (self.h or (self.text and f:getHeight()) or 20)
  )

  self.style = utils.style

  self.enabled = true
  self.visible = true
  self.maskShapeStencil = function()
    local r = math.min(self.w, self.h) * (self.style.cornerRadius or 0)
    utils.rect('fill',
      self.x, self.y, self.w, self.h,
      r or 0,
      r or 0,
      utils.defaultCurveSegments
    )
  end
end

function baseNode:setGroup(g)
  self.group = g

  if self.children then
    for _, child in ipairs(self.children) do
      child:setGroup(g)
    end
  end

  return self
end

function baseNode:deactivateGroup(g)
  self:deactivate()
  if self.children then
    for _, child in ipairs(self.children) do
      child:deactivateGroup()
    end
  end

  return self
end

function baseNode:activateGroup(g)
  self:activate()
  if self.children then
    for _, child in ipairs(self.children) do
      child:activateGroup()
    end
  end

  return self
end

function baseNode:centerX()
  return self.x + self.w / 2
end
function baseNode:centerY()
  return self.y + self.h / 2
end

function baseNode:setBounds(x, y, w, h)
  local f = utils.default_font
  self.padding = utils.style.padding

  self.x = x
  self.y = y
  self.w = w or f:getWidth(self.text) + self.padding * 2
  self.h = h or f:getHeight() + self.padding * 2
  self.px  = self.x + self.padding
  self.py  = self.y + self.padding
  self.npw = self.w - self.padding * 2
  self.nph = self.h - self.padding * 2
end

function baseNode:setStyle(style, nodeType)
  if (self.type == nodeType) or (not nodeType) then
    self.style = utils.style
    local t = {}
    for k, v in pairs(self.style) do
      t[k] = v
    end
    for k, v in pairs(style) do
      t[k] = v
    end
    self.style = t
  end

  return self
end

function baseNode:setEnabled(value)
  self.enabled = value
  return self
end

function baseNode:setVisible(value)
  self.visible = value
  return self
end

function baseNode:activate()
  self:setEnabled(true)
  self:setVisible(true)
  return self
end

function baseNode:deactivate()
  self:setEnabled(false)
  self:setVisible(false)
  return self
end

function baseNode:disable()
  self:setEnabled(false)
  self.pointed = false
  return self
end
function baseNode:enable()
  self:setEnabled(true)
  return self
end

function baseNode:hide()
  self:setVisible(false)
  return self
end
function baseNode:show()
  self:setVisible(true)
  return self
end

function baseNode:action(f)
  if type(f) == 'function' then
    self.callback = f
  else
    error('A function is required.')
  end
  return self
end

function baseNode:left()
  self.align = utils.alignments.LEFT
  return self
end

function baseNode:center()
  self.align = utils.alignments.CENTER
  return self
end

function baseNode:right()
  self.align = utils.alignments.RIGHT
  return self
end

function baseNode:pointInsideNode(x, y)
  local parent = self.parent
  local ox, oy = 0, 0
  if parent then
    ox, oy = parent:getScissorOffset()
  end

  return utils.pointInsideRect(x, y, self.x - ox, self.y - oy, self.w, self.h)
end

function baseNode:getLayerColors()
  local bgColor, fgColor
  if not self.enabled then
    bgColor = self.style.disableBgColor
    fgColor = self.style.disableFgColor
  else
    if self.pressed then
      bgColor = self.style.pressedBgColor or utils.darker(self.style.bgColor)
      fgColor = self.style.pressedFgColor or self.style.fgColor
    elseif self.pointed then
      bgColor = self.style.hoverBgColor or utils.brighter(self.style.bgColor)
      fgColor = self.style.hoverFgColor or self.style.fgColor
    else
      bgColor = self.style.bgColor
      fgColor = self.style.fgColor
    end
  end
  return bgColor, fgColor
end

function baseNode:drawBaseRectangle(color, ...)
  if self.style.customLayers then return end

  local bgc, _ = self:getLayerColors()
  local x, y, w, h = self.x, self.y, self.w, self.h
  local c = color or bgc
  
  if ... then x, y, w, h = ... end
  
  local r = math.min(self.w, self.h) * (self.style.cornerRadius or 0)
  lg.setLineWidth(self.style.lineWidth or 1)
  lg.setLineStyle(self.style.lineStyle or 'rough')
  lg.setColor(c)
  utils.rect(self.style.outline and 'line' or 'fill',
    x, y, w, h,
    self.style.cornerRadius and r or 0,
    self.style.cornerRadius and r or 0,
    utils.defaultCurveSegments
  )
end

function baseNode:drawText(color)
  local text = self.text

  if (not text) or (#text == 0) then
    return
  end

  local _, fgc = self:getLayerColors()
  local x = self:centerX() - utils.textWidth(self) / 2
  local y = self:centerY() - utils.textHeight(self) / 2
  if self.type == utils.nodeTypes.TEXT then
    x = math.floor(self.x)
  elseif self.align == utils.alignments.LEFT then
    x = math.floor(self.px)
  elseif self.align == utils.alignments.RIGHT then
    x = math.floor(self.px + self.npw - utils.textWidth(self))
  end

  lg.setFont(self.style.font or utils.default_font)
  lg.setColor(color or fgc)
  utils.print(text, x, y)
end

function baseNode:performPressedAction(data)
  if not self.enabled then return end

  local urutora = data.urutora
  if self.pointed then
    self.pressed = true
    urutora.focused_node = self
    -- special cases
    if utils.isSlider(self) then
      self:update()
      self.callback({ target = self, value = self.value })
    end
  end
end

function baseNode:performKeyboardAction(data)
  if self.type == utils.nodeTypes.TEXT then
    if self.focused then
      local previousText = data.text
      self:textInput(data.text, data.scancode)
      self.callback({ target = self, value = {
        previousText = previousText,
        newText = self.text,
        scancode = data.scancode,
        textAdded = data.text
      }})
    end
  end
end

function baseNode:performMovedAction(data)
  if not self.enabled then return end

  if self.type == utils.nodeTypes.SLIDER then
    if self.focused then
      self.callback({ target = self, value = self.value })
    end
  elseif self.type == utils.nodeTypes.JOY then
    if self.pressed then
      self.joyX = self.joyX + data.dx / utils.sx
      self.joyY = self.joyY + data.dy / utils.sy
      self:limitMovement()
      self.callback({
        target = self,
        type = 'moved',
        value = {
          x = self:getX(),
          y = self:getY(),
          directions = self:getDirections()
        }
      })
    end
  elseif self.type == utils.nodeTypes.PANEL then
    if lm.isDown(utils.mouseButtons.RIGHT) then
      -- drag panels pending
    end
  end
end

function baseNode:performReleaseAction(data)
  if not self.enabled then return end

  if self.pressed then
    if self.pointed then
      if self.type == utils.nodeTypes.BUTTON or
      self.type == utils.nodeTypes.IMAGE or
      self.type == utils.nodeTypes.ANIMATION then
        self.callback({ target = self })
      elseif self.type == utils.nodeTypes.TOGGLE then
        self:change()
        self.callback({ target = self, value = self.value })
      elseif self.type == utils.nodeTypes.MULTI then
        self:change()
        self.callback({
          target = self,
          value = self.text,
          index = self.index
        })
      end
    end

    if self.type == utils.nodeTypes.JOY then
      local lastX, lastY = self:getX(), self:getY()
      self.callback({ target = self, type = 'released', value = {
        lastX = lastX,
        lastY = lastY
      }})
      self.joyX, self.joyY = 0, 0
    end
  end

  self.pressed = false
end

function baseNode:performMouseWheelAction(data)
  if not self.enabled then return end

  if self.pointed then
    if self.type == utils.nodeTypes.PANEL then
      self:showSlider()
      local v = self:getScrollY()
      self:setScrollY(v + (-data.y) * (self.scrollSpeed or utils.scrollSpeed))
    elseif self.type == utils.nodeTypes.SLIDER then
      self:setValue(self.value + (-data.y) * utils.scrollSpeed)
      self.callback({ target = self, value = self.value })
    end
  end
end

return baseNode
