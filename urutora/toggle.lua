local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
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
    base_drawBaseRectangle(self, self.style.disableBgColor)
  end
end

function toggle:draw()
  if self.value or self.pointed then
    base_drawText(self)
  else
    base_drawText(self, self.style.disableFgColor)
  end

  local _, fgc = self:getLayerColors()
  local r = self:cornerRadius()
  local mode = self.style.outline and 'line' or 'fill'
  local x = self.x + self.switchPadding
  x = x + ((self.value and self.w / 2) or 0)
  local mark = self.style.toggleMark

  local layers = self:getLayers()
  if layers.bgToggle then
    utils.drawWithShader(self, layers.bgToggle, self.x, self.y)
  end
  if layers.fgToggle then
    local img = self.value and layers.fgToggleOn and layers.fgToggleOn or layers.fgToggle
    utils.drawWithShader(self, img, self.x, self.y)
  end

  lg.setColor(fgc)
  if mark then
    local mx = self.value and (self.x + self.w * 3 / 4) or (self.x + self.w / 4)
    utils.draw(mark, mx, self.y + self.h / 2, utils.CENTERED)
  elseif not layers.fgToggle then
    lg.rectangle(mode,
      x,
      self.y + self.switchPadding,
      self.w / 2 - self.switchPadding * 2,
      self.h - self.switchPadding * 2,
      r, r, utils.defaultCurveSegments
    )
  end
end

function toggle:change()
  self.value = not self.value
  return self
end

function toggle:performReleaseAction(data)
  if not self.enabled then return end
  if self.pressed and self.pointed then
    self:change()
    self.callback({ target = self, value = self.value })
  end
  self.pressed = false
end

return toggle
