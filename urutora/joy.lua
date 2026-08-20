local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local joy = baseNode:extend('joy')

local ACTIVATE_DEFAULT = 0.5
local PARALLAX_FACTOR = 5
local STICK_RADIUS_FACTOR = 0.25

function joy:constructor()
  joy.super.constructor(self)
  self.joyX = 0
  self.joyY = 0
  self.activateOn = self.activateOn or ACTIVATE_DEFAULT
  self._directions = {}
  self._moveValue = { x = 0, y = 0, directions = self._directions }
  self._moveEvent = { target = self, type = 'moved', value = self._moveValue }
  self._releaseValue = { lastX = 0, lastY = 0 }
  self._releaseEvent = { target = self, type = 'released', value = self._releaseValue }
end

function joy:stickRadius()
  if not self._stickRadius then
    self._stickRadius = math.min(self.w, self.h) * STICK_RADIUS_FACTOR
  end
  return self._stickRadius
end

function joy:setBounds(x, y, w, h)
  joy.super.setBounds(self, x, y, w, h)
  self._stickRadius = nil
end

function joy:limitMovement()
  local r = self:stickRadius()
  if self.joyX >=  r then self.joyX =  r end
  if self.joyX <= -r then self.joyX = -r end
  if self.joyY >=  r then self.joyY =  r end
  if self.joyY <= -r then self.joyY = -r end
end

function joy:getDirections()
  local directions = self._directions
  directions.left = nil
  directions.right = nil
  directions.up = nil
  directions.down = nil

  local jx, jy = self:getX(), self:getY()
  if jx < -self.activateOn then
    directions.left = true
  elseif jx > self.activateOn then
    directions.right = true
  end

  if jy < -self.activateOn then
    directions.up = true
  elseif jy > self.activateOn then
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
    utils.draw(self.layer1, self:centerX(), self:centerY(), utils.CENTERED)
  end

  if self.layer2 then
    utils.draw(self.layer2,
      math.floor(self:centerX() + self.joyX / PARALLAX_FACTOR),
      math.floor(self:centerY() + self.joyY / PARALLAX_FACTOR),
      utils.CENTERED
    )
  end

  if self.layer3 then
    utils.draw(self.layer3,
      math.floor(self:centerX() + self.joyX),
      math.floor(self:centerY() + self.joyY),
      utils.CENTERED
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

function joy:performMovedAction(data)
  if not self.enabled or not self.pressed then return end

  self.joyX = self.joyX + data.dx / utils.sx
  self.joyY = self.joyY + data.dy / utils.sy
  self:limitMovement()

  local evt = self._moveEvent
  local value = self._moveValue
  value.x = self:getX()
  value.y = self:getY()
  value.directions = self:getDirections()
  self.callback(evt)
end

function joy:performReleaseAction(data)
  if not self.enabled then return end
  if self.pressed then
    local value = self._releaseValue
    value.lastX = self:getX()
    value.lastY = self:getY()
    self.callback(self._releaseEvent)
    self.joyX, self.joyY = 0, 0
  end
  self.pressed = false
end

return joy
