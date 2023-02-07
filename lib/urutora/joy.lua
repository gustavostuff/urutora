local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local lovg = love.graphics

local joy = baseNode:extend('joy')

function joy:constructor()
  joy.super.constructor(self)
  self.joyX = 0
  self.joyY = 0
end

function joy:limitMovement()
  if self.joyX >=  self:stickRadius() then self.joyX =  self:stickRadius() end
  if self.joyX <= -self:stickRadius() then self.joyX = -self:stickRadius() end
  if self.joyY >=  self:stickRadius() then self.joyY =  self:stickRadius() end
  if self.joyY <= -self:stickRadius() then self.joyY = -self:stickRadius() end
end

function joy:getX() return self.joyX / self:stickRadius() end
function joy:getY() return self.joyY / self:stickRadius() end

function joy:draw()
  if self.image then
    love.graphics.setColor(1, 1, 1)
    if not self.enabled then
      lovg.setShader(utils.disabledImgShader)
    end
    lovg.draw(self.image,
    math.floor(self:centerX() + self.joyX), math.floor(self:centerY() + self.joyY),
    0, 1, 1,
    math.floor(self.image:getWidth() / 2),
    math.floor(self.image:getHeight() / 2))
    if not self.enabled then
      lovg.setShader()
    end
  else
    local _, fgc = self:getLayerColors()
    lovg.setColor(fgc)
    utils.circ('fill', self:centerX() + self.joyX, self:centerY() + self.joyY, self:stickRadius())
  end
end

function joy:stickRadius() return math.min(self.w, self.h) * 0.25 end

return joy
