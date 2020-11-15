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
		local w = math.min(self.w, self.h) / math.max(self.w, self.h) * self.w
		local x = self.x + (self.w - w) * self.value
		if w < 1 then w = 1 end
		utils.rect('fill', x, self.y, w, self.h)
	else
		local h = math.min(self.w, self.h) / math.max(self.w, self.h) * self.h
		local y = self.y + (self.h - h) * self.value
		if h < 1 then h = 1 end
		utils.rect('fill', self.x, y, self.w, h)
	end
end

function slider:update(dt)
	local x, y = utils.getMouse()

	if self.pressed then
		if self.axis == 'x' then
			self.value = (x - (self.px)) / (self.w - self.padding * 2)
		else
			self.value = (y - (self.py)) / (self.h - self.padding * 2)
		end
		if self.value > self.maxValue then self.value = self.maxValue end
		if self.value < self.minValue then self.value = self.minValue end
	end
end

return slider