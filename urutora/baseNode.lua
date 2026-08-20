local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local class = require(modules .. 'class')
local utils = require(modules .. 'utils')

local baseNode = class('baseNode')

function baseNode:constructor()
  self.callback = function () end
  self.align = self.align or utils.alignments.CENTER

  local f = utils.getDefaultFont()
  local p = self.padding or utils.style.padding or (f:getHeight() / 2)
  self:setBounds(
    self.x or 0,
    self.y or 0,
    (self.w or (self.text and f:getWidth(self.text)) or utils.DEFAULT_NODE_SIZE),
    (self.h or (self.text and f:getHeight()) or utils.DEFAULT_NODE_SIZE)
  )

  self.style = utils.style
  self.enabled = true
  self.visible = true
  self.maskShapeStencil = function()
    local r = self:cornerRadius()
    utils.rect('fill',
      self.x, self.y, self.w, self.h,
      r or 0,
      r or 0,
      utils.defaultCurveSegments
    )
  end
end

function baseNode:cornerRadius()
  return math.min(self.w, self.h) * (self.style.cornerRadius or 0)
end

function baseNode:getLayers()
  return utils.getLayers(self)
end

function baseNode:setGroup(g)
  self.group = g

  if self.children then
    for _, child in pairs(self.children) do
      child:setGroup(g)
    end
  end

  return self
end

function baseNode:deactivateGroup(g)
  if (not g) or (self.group == g) then
    self:deactivate()
  end
  if self.children then
    for _, child in pairs(self.children) do
      child:deactivateGroup(g)
    end
  end
  return self
end

function baseNode:activateGroup(g)
  if (not g) or (self.group == g) then
    self:activate()
  end
  if self.children then
    for _, child in pairs(self.children) do
      child:activateGroup(g)
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
  local f = utils.getDefaultFont()
  self.padding = utils.style.padding or (f:getHeight() / 2)

  self.x = x
  self.y = y
  self.w = w or f:getWidth(self.text) + self.padding * 2
  self.h = h or f:getHeight() + self.padding * 2
  self.px  = self.x + self.padding
  self.py  = self.y + self.padding
  self.npw = self.w - self.padding * 2
  self.nph = self.h - self.padding * 2
end

function baseNode:invalidateColorCache()
  self._hoverBg = nil
  self._pressedBg = nil
end

function baseNode:setStyle(style, nodeType)
  if (self.type == nodeType) or (not nodeType) then
    local t = {}
    for k, v in pairs(utils.style) do
      t[k] = v
    end
    for k, v in pairs(style) do
      t[k] = v
    end
    if style.customLayers then
      local layers = {}
      for k, v in pairs(style.customLayers) do
        layers[k] = v
      end
      t.customLayers = layers
    end
    self.style = t
    self:invalidateColorCache()
    self._textW = nil
    self._textH = nil
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
      bgColor = self.style.pressedBgColor or self._pressedBg
      if not bgColor then
        self._pressedBg = utils.darker(self.style.bgColor)
        bgColor = self._pressedBg
      end
      fgColor = self.style.pressedFgColor or self.style.fgColor
    elseif self.pointed then
      bgColor = self.style.hoverBgColor or self._hoverBg
      if not bgColor then
        self._hoverBg = utils.brighter(self.style.bgColor)
        bgColor = self._hoverBg
      end
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

  local bgc = self:getLayerColors()
  local x, y, w, h = self.x, self.y, self.w, self.h
  local c = color or bgc

  if ... then x, y, w, h = ... end

  local r = self:cornerRadius()
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
  local textW = utils.textWidth(self)
  local x = self:centerX() - textW / 2
  local y = self:centerY() - utils.textHeight(self) / 2
  if self.type == utils.nodeTypes.TEXT then
    x = math.floor(self.x)
  elseif self.align == utils.alignments.LEFT then
    x = math.floor(self.px)
  elseif self.align == utils.alignments.RIGHT then
    x = math.floor(self.px + self.npw - textW)
  end

  lg.setFont(self.style.font or utils.getDefaultFont())
  lg.setColor(color or fgc)
  utils.print(text, x, y)
end

-- Default input: press sets pressed/focused. Widgets override for special behavior.
function baseNode:performPressedAction(data)
  if not self.enabled then return end
  if self.pointed then
    self.pressed = true
    data.urutora.focused_node = self
  end
end

function baseNode:performKeyboardAction(data)
end

function baseNode:performMovedAction(data)
end

function baseNode:performReleaseAction(data)
  if not self.enabled then return end
  self.pressed = false
end

function baseNode:performMouseWheelAction(data)
end

return baseNode
