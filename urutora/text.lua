local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local base_node = require(modules .. 'base_node')
local utf8 = require('utf8')

local lovg = love.graphics

local text = base_node:extend('text')

function text:constructor()
	text.super.constructor(self)
	self.textAlign = utils.textAlignments.LEFT
	self.text = self.text or ''
end

function text:draw()
	local _, fgc = self:getLayerColors()
	local y = self.y + self.h - self.parent.spacing
	local textY = self:centerY() - utils.textHeight(self) / 2
	lovg.setColor(self.style.fgColor)
	lovg.line(self.x, y, self.x + self.w, y)

	if self.focused then
		utils.print('_', self.x + utils.textWidth(self), textY)
	end
end

function text:textInput(text, scancode)
	if scancode == 'backspace' then
		local byteoffset = utf8.offset(self.text, -1)
		if byteoffset then
			self.text = string.sub(self.text, 1, byteoffset - 1)
		end
	else
		if utils.textWidth(self) <= self.npw then
			self.text = self.text .. (text or '')
		end
	end

	if scancode == 'return' then
		self.focused = false
	end
end

return text