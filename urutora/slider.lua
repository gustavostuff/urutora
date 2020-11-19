local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local base_node = require(modules .. 'base_node')

local lovg = love.graphics

local slider = base_node:extend('slider')

function slider:constructor()
	slider.super.constructor(self)
	self.maxValue = self.maxValue or 1
	self.minValue = self.minValue or 0
	self.value = self.value or 0.5
	self.axis = self.axis or 'x'
end

function slider:draw()
	local _, fgc = self:getLayerColors()
	lovg.setColor(fgc)

	if self.axis == 'x' then
		local w = 24
		local x = self.x + (self.w - w) * self.value
		utils.rect('fill', x, self.y, w, self.h)
	else
		local h = 24
		local y = self.y + (self.h - h) * self.value
		utils.rect('fill', self.x, y, self.w, h)
	end
end

function slider:setValue(value)
	self.value = value
	if self.value > self.maxValue then self.value = self.maxValue end
	if self.value < self.minValue then self.value = self.minValue end
end

function slider:update(dt)
	local x, y = utils.getMouse()

	if self.pressed then
		if self.axis == 'x' then
			self:setValue((x - (self.px)) / (self.w - self.padding * 2))
		else
			self:setValue((y - (self.py)) / (self.h - self.padding * 2))
		end
	end
end

return slider