local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local lovg = love.graphics

local joy = baseNode:extend('joy')

function joy:constructor()
  joy.super.constructor(self)
  self.joyX = 0
  self.joyY = 0
  self.activateOn = self.activateOn or 0.5
end

function joy:limitMovement()
  if self.joyX >=  self:stickRadius() then self.joyX =  self:stickRadius() end
  if self.joyX <= -self:stickRadius() then self.joyX = -self:stickRadius() end
  if self.joyY >=  self:stickRadius() then self.joyY =  self:stickRadius() end
  if self.joyY <= -self:stickRadius() then self.joyY = -self:stickRadius() end
end

function joy:getDirection()
  local direction = ''

  if self:getX() < -self.activateOn then
    direction = direction .. 'l'
  elseif self:getX() > self.activateOn then
    direction = direction .. 'r'
  end

  if self:getY() < -self.activateOn then
    direction = direction .. 'u'
  elseif self:getY() > self.activateOn then
    direction = direction .. 'd'
  end

  return direction
end

function joy:getX() return self.joyX / self:stickRadius() end
function joy:getY() return self.joyY / self:stickRadius() end

function joy:draw()
  lg.setColor(1, 1, 1)
  if not self.enabled then
    lovg.setShader(utils.disabledImgShader)
  end
  if self.layer1 then
    utils.draw(self.layer1, self:centerX(), self:centerY(), {centered = true})
  end

  if self.layer2 then
    utils.draw(self.layer2,
      math.floor(self:centerX() + self.joyX / 5),
      math.floor(self:centerY() + self.joyY / 5),
      {centered = true}
    )
  end

  if self.layer3 then
    utils.draw(self.layer3,
      math.floor(self:centerX() + self.joyX),
      math.floor(self:centerY() + self.joyY),
      {centered = true}
    )
  else
    local _, fgc = self:getLayerColors()
    lovg.setColor(fgc)
    local lsBkp = lovg.getLineStyle()
    lovg.setLineStyle('smooth')
    lovg.circle('line', self:centerX() + self.joyX, self:centerY() + self.joyY, self:stickRadius())
    lovg.setLineStyle(lsBkp)
  end
  if not self.enabled then
    lovg.setShader()
  end
end

function joy:stickRadius() return math.min(self.w, self.h) * 0.25 end

return joy
