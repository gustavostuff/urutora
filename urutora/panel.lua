local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local base_node = require(modules .. 'base_node')

local lovg = love.graphics

local panel = base_node:extend('panel')

function panel:constructor()
	panel.super.constructor(self)
	self.children = {}
	self.rows = self.rows or 1
	self.cols = self.cols or 1
	self.rowspans = {}
	self.colspans = {}
	self.spacing = self.spacing or 1
	self.ox = self.ox or 0
	self.oy = self.oy or 0
	self.ow = self.ow or self.w
	self.oh = self.oh or self.h
end

function panel:setStyle(style)
	self.super.setStyle(self, style)
	for _, v in pairs(self.children) do
		v:setStyle(style)
	end
	return self
end

function panel:clear()
	self.children = {}
	self.rowspans = {}
	self.colspans = {}
	self.ox = 0
	self.oy = 0
end

function panel:_calculate_rect(row, col)
	local w, h = (self.ow / self.cols), (self.oh / self.rows)
	local x, y = self.x + w * (col - 1), self.y + h * (row - 1)
	local s = self.spacing / 2
	local rs = (self.rowspans[col] or {})[row] or 1
	local cs = (self.colspans[col] or {})[row] or 1
	x, y = x + s, y + s
	w, h = ((w * cs) - s * 2), ((h * rs) - s * 2)
	return x, y, w, h
end

function panel:addAt(row, col, newNode)
	local x, y, w, h = self:_calculate_rect(row, col)
	newNode:setBounds(x, y, w, h)
	newNode.parent = self
	newNode._row = row
	newNode._col = col
	self.children[row * self.cols + col] = newNode
	--recalculate panel nodes position
	if utils.isPanel(newNode) then newNode:_update_nodes_position() end
	return self
end

function panel:remove(row, col)
	self.children[row * self.cols + col] = nil
end

function panel:getChildren(row, col)
	return self.children[row * self.cols + col]
end

function panel:findFromTag(tag)
	for k, v in pairs(self.children) do
		if v.tag and v.tag == tag then
			return v
		end
	end
end

function panel:setScrollX(value)
	value = math.max(0, math.min(value, 1))
	local dx = self.ow - self.w
	if dx > 0 then self.ox = dx * value end
end

function panel:setScrollY(value)
	value = math.max(0, math.min(value, 1))
	local dy = self.oh - self.h
	if dy > 0 then self.oy = dy * value end
end

function panel:getScrollX()
	return self.ox / (self.ow - self.w)
end

function panel:getScrollY()
	return self.oy / (self.oh - self.h)
end

function panel:rowspanAt(row, col, size)
	self.rowspans[col] = self.rowspans[col] or {}
	self.rowspans[col][row] = size
	return self
end

function panel:colspanAt(row, col, size)
	self.colspans[col] = self.colspans[col] or {}
	self.colspans[col][row] = size
	return self
end

function panel:moveTo(x, y)
	self.x = math.floor(x)
	self.y = math.floor(y)
	self:_update_nodes_position()
end

function panel:_update_nodes_position()
	for _, node in pairs(self.children) do
		local x, y, w, h = self:_calculate_rect(node._row, node._col)
		node:setBounds(x, y, w, h)
		if utils.isPanel(node) then
			node:_update_nodes_position()
		end
	end
end

function panel:_get_scissor_offset()
	local parent = self.parent
	if parent then
		local ox, oy = parent:_get_scissor_offset()
		return self.ox + ox, self.oy + oy
	else
		return self.ox, self.oy
	end
end

function panel:draw()
	local scx, scy, scsx, scsy = love.graphics.getScissor()

	local x = self.x
	local y = self.y
	local s = self.spacing
	local ox, oy = 0, 0
	if self.parent then
		ox, oy = self.parent:_get_scissor_offset()
	end
	lovg.push()
	lovg.translate(math.floor(-self.ox), math.floor(-self.oy))
	lovg.intersectScissor(x - ox, y - oy, self.w - s, self.h - s)

	for _, node in pairs(self.children) do
		if node.visible then
			if utils.needsBase(node) then node:drawBaseRectangle() end
			if node.draw then node:draw() end
			node:drawText()
		end
	end

	lovg.setScissor(scx, scy, scsx, scsy)
	lovg.pop()

	if self.outline then
		lovg.setColor(self.style.outlineColor)
		utils.rect('line', x + s, y + s, self.w - s * 2, self.h - s * 2)
	end
end

function panel:update(dt)
	local x, y = utils.getMouse()

	for _, node in pairs(self.children) do
		if node.enabled then
			node.pointed = self.pointed and node:pointInsideNode(x, y) and not utils.isLabel(node)
			if node.update then node:update(dt) end
		end
	end
end

function panel:pointInsideNode(x, y)
	local parent = self.parent
	local ox, oy = 0, 0
	if parent then
		ox, oy = parent:_get_scissor_offset()
	end

	return utils.pointInsideRect(x, y, self.x - ox, self.y - oy, self.w, self.h)
end

function panel:disable()
	self:setEnabled(false)
	for k, v in pairs(self.children) do
		v:setEnabled(false)
	end
	return self
end
function panel:enable()
	self:setEnabled(true)
	for k, v in pairs(self.children) do
		v:setEnabled(true)
	end
	return self
end

function panel:hide()
	self:setVisible(false)
	for k, v in pairs(self.children) do
		v:setVisible(false)
	end
	return self
end
function panel:show()
	self:setVisible(true)
	for k, v in pairs(self.children) do
		v:setVisible(true)
	end
	return self
end

function panel:forEach(callback)
	for _, node in pairs(self.children) do
		if utils.isPanel(node) then
		 	callback(node)
			node:forEach(callback)
		else
			callback(node)
		end
	end
end

function panel:performPressedAction(data)
	if self.enabled then
		self:forEach(function (node)
			node:performPressedAction(data)
		end)
	end
end

function panel:performKeyboardAction(data)
	if self.enabled then
		self:forEach(function (node)
			node:performKeyboardAction(data)
		end)
	end
end

function panel:performMovedAction(data)
	if self.enabled then
		self:forEach(function (node)
			node:performMovedAction(data)
		end)
	end
end

function panel:performReleaseAction(data)
	if self.enabled then
		self:forEach(function (node)
			node:performReleaseAction(data)
		end)
	end
end

return panel