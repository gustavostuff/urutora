local modules = (...):gsub('%.[^%.]+$', '') .. '.'
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
  local bgc, fgc = self:getLayerColors()
  local mode = self.style.outline and 'line' or 'fill'
  local r = math.min(self.w, self.h) * (self.style.cornerRadius or 0)
  local mark = self.style.sliderMark
  local layers = self.customLayers or self.style.customLayers or {}
  lg.setColor(bgc)
  if self.axis == 'x' then
    local n = self.h / 2
    local x = self.x + n / 2 + (self.w - self.h) * self.value
    
    -- bg
    if layers.bgSlider then
      utils.drawWithShader(self, layers.bgSlider, self.x, self.y)
    end

    -- fg
    lg.setColor(fgc)
    local img = layers.fgSlider
    img = mark or (self.pointed and layers.fgSliderOn or img)
    if img then
      utils.drawWithShader(self, img , x + n / 2, self.y + self.h / 2, {centered = true})
    else
      lg.setColor(fgc)
      utils.rect(mode, x, self.y, n, self.h, r, r, utils.defaultCurveSegments)
    end
  else
    local n = self.w / 2
    local y = self.y + n + (self.h - self.w) * self.value

    -- bg
    if layers.bgSliderVertical then
      utils.drawWithShader(self, layers.bgSliderVertical, self.x, self.y)
    end

    -- fg
    lg.setColor(fgc)
    local img = layers.fgSliderVertical
    img = mark or (self.pointed and layers.fgSliderVerticalOn or img)
    if img then
      utils.drawWithShader(self, img, self.x + n, y, {centered = true})
    else
      utils.rect(mode, self.x, y - n / 2, self.w, n, r, r, utils.defaultCurveSegments)
    end
  end
end

function slider:setValue(value)
  self.value = value
  if self.value > self.maxValue then self.value = self.maxValue end
  if self.value < self.minValue then self.value = self.minValue end
end

function slider:update(dt)
  local x, y = utils:getMouse()
  local ox = self.parent and self.parent.ox or 0
  local oy = self.parent and self.parent.oy or 0

  if self.pressed then
    if self.axis == 'x' then
      self:setValue(((x + oy) - self.px) / (self.w - self.padding * 2))
    else
      self:setValue(((y + oy) - self.py) / (self.h - self.padding * 2))
    end
  end
end

return slider
