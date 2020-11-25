local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local base_node = require(modules .. 'base_node')

local lovg = love.graphics

local joy = base_node:extend('joy')

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
	local _, fgc = self:getLayerColors()
	lovg.setColor(fgc)
	utils.circ('fill', self:centerX() + self.joyX, self:centerY() + self.joyY, self:stickRadius())
end

function joy:stickRadius() return math.min(self.w, self.h) * 0.25 end

return joy