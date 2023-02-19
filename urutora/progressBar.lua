local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local progressbar = baseNode:extend('progressbar')

function progressbar:constructor()
  progressbar.super.constructor(self)
  self.value = self.value or 0
  self.direction = self.direction or 1
  self.speed = self.speed or 0.1
end

function progressbar:update(dt)
  self.value = self.value + dt * self.direction * self.speed

  if self.value >= 1 then
    self.value = 1
    self.callback({
      target = self,
      type = 'full'
    })
  end
  if self.value <= 0 then
    self.value = 0
    self.callback({
      target = self,
      type = 'empty'
    })
  end
end

function progressbar:setValue(value)
  self.value = value and value <= 1 and value >= 0
end

function progressbar:draw()
  local _, fgc = self:getLayerColors()
  local mode = self.style.outline and 'line' or 'fill'
  local r = math.min(self.w, self.h) * (self.style.cornerRadius or 0)

  if self.value <= 0 then return end -- avoids a glitch
  lg.setColor(fgc)
  lg.rectangle(mode,
    self.x,
    self.y,
    self.w * self.value,
    self.h,
    r,
    r,
    utils.defaultCurveSegments
  )
end

return progressbar
