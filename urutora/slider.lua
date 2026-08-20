local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local slider = baseNode:extend('slider')

function slider:constructor()
  slider.super.constructor(self)
  self.maxValue = self.maxValue or 1
  self.minValue = self.minValue or 0
  self.value = self.value or 0.5
  self.axis = self.axis or 'x'
  self.padding = 0
end

function slider:draw()
  local _, fgc = self:getLayerColors()
  local mode = self.style.outline and 'line' or 'fill'
  local r = self:cornerRadius()
  local mark = self.style.sliderMark
  local layers = self:getLayers()
  if self.axis == 'x' then
    local n = self.h / 2
    local x = self.x + n / 2 + (self.w - self.h) * self.value

    if layers.bgSlider then
      utils.drawWithShader(self, layers.bgSlider, self.x, self.y)
    end

    local img = layers.fgSlider
    img = mark or (self.pointed and layers.fgSliderOn or img)
    if img then
      utils.drawWithShader(self, img, x + n / 2, self.y + self.h / 2, utils.CENTERED)
    else
      lg.setColor(fgc)
      utils.rect(mode, x, self.y, n, self.h, r, r, utils.defaultCurveSegments)
    end
  else
    local n = self.w / 2
    local y = self.y + n + (self.h - self.w) * self.value

    if layers.bgSliderVertical then
      utils.drawWithShader(self, layers.bgSliderVertical, self.x, self.y)
    end

    local img = layers.fgSliderVertical
    img = mark or (self.pointed and layers.fgSliderVerticalOn or img)
    if img then
      utils.drawWithShader(self, img, self.x + n, y, utils.CENTERED)
    else
      lg.setColor(fgc)
      utils.rect(mode, self.x, y - n / 2, self.w, n, r, r, utils.defaultCurveSegments)
    end
  end
end

function slider:setValue(value)
  self.value = value
  if self.value > self.maxValue then self.value = self.maxValue end
  if self.value < self.minValue then self.value = self.minValue end
end

function slider:update(dt, mx, my)
  if not mx then
    mx, my = utils:getMouse()
  end
  local ox, oy = 0, 0
  if self.parent then
    ox, oy = self.parent:getScissorOffset()
  end

  if self.pressed then
    if self.axis == 'x' then
      self:setValue(((mx + ox) - self.px) / (self.w - self.padding * 2))
    else
      self:setValue(((my + oy) - self.py) / (self.h - self.padding * 2))
    end
  end
end

function slider:performPressedAction(data)
  if not self.enabled then return end
  if self.pointed then
    self.pressed = true
    data.urutora.focused_node = self
    self:update()
    self.callback({ target = self, value = self.value })
  end
end

function slider:performMovedAction(data)
  if not self.enabled then return end
  if self.focused then
    self.callback({ target = self, value = self.value })
  end
end

function slider:performMouseWheelAction(data)
  if not self.enabled or not self.pointed then return end
  self:setValue(self.value + (-data.y) * utils.scrollSpeed)
  self.callback({ target = self, value = self.value })
end

return slider
