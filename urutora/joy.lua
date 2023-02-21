local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

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

function joy:getDirections()
  local directions = {}

  if self:getX() < -self.activateOn then
    directions.left = true
  elseif self:getX() > self.activateOn then
    directions.right = true
  end

  if self:getY() < -self.activateOn then
    directions.up = true
  elseif self:getY() > self.activateOn then
    directions.down = true
  end

  return directions
end

function joy:getX() return self.joyX / self:stickRadius() end
function joy:getY() return self.joyY / self:stickRadius() end

function joy:draw()
  lg.setColor(1, 1, 1)
  if not self.enabled then
    lg.setShader(utils.disabledImgShader)
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
    lg.setColor(fgc)
    local lsBkp = lg.getLineStyle()
    lg.setLineStyle('smooth')
    lg.circle('line', self:centerX() + self.joyX, self:centerY() + self.joyY, self:stickRadius())
    lg.setLineStyle(lsBkp)
  end
  if not self.enabled then
    lg.setShader()
  end
end

function joy:stickRadius() return math.min(self.w, self.h) * 0.25 end

return joy
