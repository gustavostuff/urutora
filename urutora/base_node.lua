local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local class = require(modules .. 'class')
local utils = require(modules .. 'utils')

local lovg = love.graphics

local base_node = class('base_node')

function base_node:constructor()
	self.callback = function () end
	self.textAlign = self.textAlign or utils.textAlignments.CENTER

	self:setBounds(
		self.x or 1,
		self.y or 1,
		self.w or 16,
		self.h or 16
	)

	self.style = utils.style

	self.enabled = true
	self.visible = true
end

function base_node:centerX()
	return self.x + self.w / 2
end
function base_node:centerY()
	return self.y + self.h / 2
end

function base_node:setBounds(x, y, w, h)
	local f = utils.default_font
	self.padding = utils.style.padding

	self.x = x
	self.y = y
	self.w = w or f:getWidth(self.text) + self.padding * 2
	self.h = h or f:getHeight() + self.padding * 2
	self.px  = self.x + self.padding
	self.py  = self.y + self.padding
	self.npw = self.w - self.padding * 2
	self.nph = self.h - self.padding * 2
end

function base_node:setStyle(style, lock)
	if self.style.lock and not lock then return end

	local t = { lock = lock }
	for k, v in pairs(self.style) do
		t[k] = v
	end
	for k, v in pairs(style) do
		t[k] = v
	end
	self.style = t
	return self
end

function base_node:setEnabled(value)
	self.enabled = value
	return self
end

function base_node:setVisible(value)
	self.visible = value
	return self
end

function base_node:activate()
	self:setEnabled(true)
	self:setVisible(true)
	return self
end

function base_node:deactivate()
	self:setEnabled(false)
	self:setVisible(false)
	return self
end

function base_node:disable()
	self:setEnabled(false)
	return self
end
function base_node:enable()
	self:setEnabled(true)
	return self
end

function base_node:hide()
	self:setVisible(false)
	return self
end
function base_node:show()
	self:setVisible(true)
	return self
end

function base_node:action(f)
	if type(f) == 'function' then
		self.callback = f
	end
	return self
end

function base_node:left()
	self.textAlign = utils.textAlignments.LEFT
	return self
end

function base_node:center()
	self.textAlign = utils.textAlignments.CENTER
	return self
end

function base_node:right()
	self.textAlign = utils.textAlignments.RIGHT
	return self
end

function base_node:pointInsideNode(x, y)
	local parent = self.parent
	local ox, oy = 0, 0
	if parent then
		ox, oy = parent:_get_scissor_offset()
	end

	return utils.pointInsideRect(x, y, self.x - ox, self.y - oy, self.w, self.h)
end

function base_node:getLayerColors()
	local bgColor, fgColor
	if not self.enabled then
		bgColor = self.style.disablebgColor
		fgColor = self.style.disablefgColor
	else
		if self.pressed then
			bgColor = self.style.pressedbgColor or utils.darker(self.style.bgColor)
			fgColor = self.style.pressedfgColor or self.style.fgColor
		elseif self.pointed then
			bgColor = self.style.hoverbgColor or utils.brighter(self.style.bgColor)
			fgColor = self.style.hoverfgColor or self.style.fgColor
		else
			bgColor = self.style.bgColor
			fgColor = self.style.fgColor
		end
	end
	return bgColor, fgColor
end

function base_node:drawBaseRectangle(color, ...)
	local bgc, _ = self:getLayerColors()
	lovg.setColor(color or bgc)
	local x, y, w, h = self.x, self.y, self.w, self.h

	if ... then x, y, w, h = ... end
	utils.rect('fill', x, y, w, h)
end

function base_node:drawText(color)
	local text = self.text

	if (not text) or (#text == 0) then
		return
	end

	local _, fgc = self:getLayerColors()
	local x = self:centerX() - utils.textWidth(self) / 2
	local y = self:centerY() - utils.textHeight(self) / 2
	if self.type == utils.nodeTypes.TEXT then
		x = math.floor(self.x)
	elseif self.textAlign == utils.textAlignments.LEFT then
		x = math.floor(self.px)
	elseif self.textAlign == utils.textAlignments.RIGHT then
		x = math.floor(self.px + self.npw - utils.textWidth(self))
	end

	lovg.setFont(self.style.font or utils.default_font)
	lovg.setColor(color or fgc)
	utils.print(text, x, y)
end

function base_node:performPressedAction(data)
	if not self.enabled then return end

	local urutora = data.urutora
	if self.pointed then
		self.pressed = true
		urutora.focused_node = self

		-- special cases
		if utils.isSlider(self) then
			self:update()
			self.callback({ target = self, value = self.value })
		end
	end
end

function base_node:performKeyboardAction(data)
	if self.type == utils.nodeTypes.TEXT then
		if self.focused then
			local previousText = data.text
			self:textInput(data.text, data.scancode)
			self.callback({ target = self, value = {
				previousText = previousText,
				newText = self.text,
				scancode = data.scancode,
				textAdded = data.text
			}})
		end
	end
end

function base_node:performMovedAction(data)
	if not self.enabled then return end

	if self.type == utils.nodeTypes.SLIDER then
		if self.focused then
			self.callback({ target = self, value = self.value })
		end
	elseif self.type == utils.nodeTypes.JOY then
		if self.pressed then
			self.joyX = self.joyX + data.dx / utils.sx
			self.joyY = self.joyY + data.dy / utils.sy
			self:limitMovement()
		end
	end
end

function base_node:performReleaseAction(data)
	if not self.enabled then return end

	if self.pressed then
		if self.pointed then
			if self.type == utils.nodeTypes.BUTTON then
				self.callback({ target = self })
			elseif self.type == utils.nodeTypes.TOGGLE then
				self:change()
				self.callback({ target = self, value = self.value })
			elseif self.type == utils.nodeTypes.MULTI then
				self:change()
				self.callback({ target = self, value = self.text })
			end
		end

		if self.type == utils.nodeTypes.JOY then
			self.callback({ target = self, value = {
				lastX = self.joyX,
				lastY = self.joyY
			}})
			self.joyX, self.joyY = 0, 0
		end
	end

	self.pressed = false
end

function base_node:performMouseWheelAction(data)
	if not self.enabled then return end

	if self.pointed then
		if self.type == utils.nodeTypes.PANEL then
			local v = self:getScrollY()
			self:setScrollY(v + (-data.y) * utils.scroll_speed)
		elseif self.type == utils.nodeTypes.SLIDER then
			self:setValue(self.value + (-data.y) * utils.scroll_speed)
			self.callback({ target = self, value = self.value })
		end
	end
end

return base_node