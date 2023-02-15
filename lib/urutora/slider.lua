local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local lovg = love.graphics

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
  lovg.setColor(fgc)
  local mode = self.style.outline and 'line' or 'fill'
  local r = math.min(self.w, self.h) * (self.style.cornerRadius or 0)
  local mark = self.style.sliderMark

  if self.axis == 'x' then
    local w = math.floor(self.h / 2)
    local x = self.x + (self.w - w) * self.value
    if mark then
      utils.draw(mark, x + w / 2, self.y + self.h / 2, {centered = true})
    else
      utils.rect(mode, x, self.y, w, self.h, r, r, utils.defaultCurveSegments)
    end
  else
    local h = math.floor(self.w / 2)
    local y = self.y + (self.h - h) * self.value
    if mark then
      utils.draw(mark, self.x + h, y + h / 2, {centered = true})
    else
      utils.rect(mode, self.x, y, self.w, h, r, r, utils.defaultCurveSegments)
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
