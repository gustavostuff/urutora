local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local base_node = require(modules .. 'base_node')

local toggle = base_node:extend('toggle')

function toggle:draw()
	if self.value then
	  	self:drawBaseRectangle()
	else
	  	self:drawBaseRectangle(self.style.disablebgColor)
	end
end

function toggle:change()
	self.value = not self.value
	return self
end

return toggle