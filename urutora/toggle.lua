local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local base_node = require(modules .. 'base_node')

local toggle = base_node:extend('toggle')

local base_drawText = toggle.super.drawText
local base_drawBaseRectangle = toggle.super.drawBaseRectangle

function toggle:drawBaseRectangle()
	if self.value then
		base_drawBaseRectangle(self)
	else
		base_drawBaseRectangle(self, self.style.disablebgColor)
	end
end

function toggle:drawText()
	if self.value or self.pointed then
		base_drawText(self)
	else
		base_drawText(self, self.style.disablefgColor)
	end
end

function toggle:change()
	self.value = not self.value
	return self
end

return toggle