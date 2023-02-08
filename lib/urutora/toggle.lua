local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local baseNode = require(modules .. 'baseNode')
local utils = require(modules .. 'utils')

local toggle = baseNode:extend('toggle')

local base_drawText = toggle.super.drawText
local base_drawBaseRectangle = toggle.super.drawBaseRectangle

function toggle:constructor()
  toggle.super.constructor(self)
  self.align = utils.alignments.LEFT
  self.switchPadding = 2
end

function toggle:drawBaseRectangle()
  if self.value then
    base_drawBaseRectangle(self)
  else
    base_drawBaseRectangle(self, self.style.disablebgColor)
  end
end

function toggle:draw()
  if self.value or self.pointed then
    base_drawText(self)
  else
    base_drawText(self, self.style.disablefgColor)
  end
  love.graphics.setColor(self.style.fgColor)
  local x = self.x + self.switchPadding
  x = x + ((self.value and self.w / 2) or 0)
  love.graphics.rectangle('fill',
    x,
    self.y + self.switchPadding,
    self.w / 2 - self.switchPadding * 2,
    self.h - self.switchPadding * 2
  )
end

function toggle:change()
  self.value = not self.value
  return self
end

return toggle
