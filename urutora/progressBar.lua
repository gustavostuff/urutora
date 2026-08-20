local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
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
  local prev = self.value
  self.value = self.value + dt * self.direction * self.speed

  if self.value >= 1 then
    self.value = 1
    if prev < 1 then
      self.callback({
        target = self,
        type = 'full'
      })
    end
  elseif self.value <= 0 then
    self.value = 0
    if prev > 0 then
      self.callback({
        target = self,
        type = 'empty'
      })
    end
  end
end

function progressbar:setValue(value)
  self.value = math.max(0, math.min(1, value or 0))
end

function progressbar:draw()
  local layers = self:getLayers()
  self:drawBaseRectangle()
  local _, fgc = self:getLayerColors()
  local progress = self.w * self.value

  lg.stencil(self.maskShapeStencil, 'replace', 1)
  lg.setStencilTest('greater', 0)

  if layers.bgProgressbar then
    utils.drawWithShader(self, layers.bgProgressbar, self.x, self.y)
  end
  lg.setColor(self.enabled and self.style.progressBarGooColor or fgc)
  lg.rectangle('fill', self.x, self.y, progress, self.h)

  if layers.fgProgressbar then
    utils.drawWithShader(self, layers.fgProgressbar, self.x, self.y)
  end
  if self.style.outline then
    self:drawBaseRectangle()
  end

  lg.setStencilTest()
end

return progressbar
