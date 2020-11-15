local modules = (...):gsub('%.[^%.]+$', '') .. "."
local utils = require(modules .. 'utils')
local class = require(modules .. 'class')

local lovg = love.graphics

local panel 	= require(modules .. 'panel')
local image 	= require(modules .. 'image')
local base_node = require(modules .. 'base_node')
local text 		= require(modules .. 'text')
local multi 	= require(modules .. 'multi')
local slider 	= require(modules .. 'slider')
local toggle 	= require(modules .. 'toggle')
local joy 		= require(modules .. 'joy')

local urutora = class('urutora')
urutora.utils = utils

function urutora.setDefaultFont(font)
	utils.default_font = font
end

function urutora.setResolution(w, h)
	utils.sx = lovg.getWidth() / w
	utils.sy = lovg.getHeight() / h
end

function urutora:constructor()
	self.nodes = {}
	self.focused_node = nil
end

function urutora.panel(u, data, nameid)
	local node = panel:new_from(data)
	node.type = utils.nodeTypes.PANEL
	node.nameid = nameid
	if u then
		u.nodes[nameid] = node
	end
	return node
end

function urutora.image(data)
	local node = image:new_from(data)
	node.type = utils.nodeTypes.IMAGE
	return node
end

function urutora.label(data)
	local node = base_node:new_from(data)
	node.type = utils.nodeTypes.LABEL
	return node
end

function urutora.text(data)
	local node = text:new_from(data)
	node.type = utils.nodeTypes.TEXT
	return node
end

function urutora.multi(data)
	local node = multi:new_from(data)
	node.type = utils.nodeTypes.MULTI
	return node
end

function urutora.button(data)
	local node = base_node:new_from(data)
	node.type = utils.nodeTypes.BUTTON
	return node
end

function urutora.slider(data)
	local node = slider:new_from(data)
	node.type = utils.nodeTypes.SLIDER
	return node
end

function urutora.toggle(data)
	local node = toggle:new_from(data)
	node.type = utils.nodeTypes.TOGGLE
	return node
end

function urutora.joy(data)
	local node = joy:new_from(data)
	node.type = utils.nodeTypes.JOY
	return node
end

-------------------------------------------------------------
-------------------------------------------------------------

function urutora:activatePanels()
	for k, v in pairs(self.nodes) do
		v:activate()
	end
	return self
end

function urutora:deactivatePanels()
	for k, v in pairs(self.nodes) do
		v:deactivate()
	end
	return self
end

function urutora:activatePanel(...)
	for i, v in ipairs({...}) do
		local node = self.nodes[v]
		node:activate()
	end
	return self
end

function urutora:deactivatePanel(...)
	for i, v in ipairs({...}) do
		local node = self.nodes[v]
		node:deactivate()
	end
	return self
end

function urutora:setFocusedNode(node)
	for _, v in pairs(self.nodes) do
		v:forEach(function (_node)
			_node.focused = false
		end)
	end
	if node then node.focused = true end
end

function urutora:draw()
	lovg.push('all')

	lovg.setLineWidth(1)
	lovg.setLineStyle('rough')
	lovg.setFont(utils.default_font)

	for _, p in pairs(self.nodes) do
		p:draw()
	end

	lovg.pop()
end

function urutora:update(dt)
	for _, p in pairs(self.nodes) do
		p:update()
	end
end

local function performPressedAction(node, data)
	local x = data.x
	local y = data.y
	local urutora = data.urutora
	if node.enabled then
		if utils.isPanel(node) then
			performPressedAction(node, data)
		elseif node.pointed then
			node.pressed = true
			urutora.focused_node = node

			-- special cases
			if utils.isSlider(node) then
				node:update()
			end
		end
	end
end

local function performKeyboardAction(node, data)
	if node.type == utils.nodeTypes.TEXT then
		if node.focused then
			local previousText = data.text
			node:textInput(data.text, data.scancode)
			node.callback({ target = node, value = {
				previousText = previousText,
				newText = node.text,
				scancode = data.scancode,
				textAdded = data.text
			}})
		end
	end
end

local function performMovedAction(node, data)
	if not node.enabled then return end

	if node.type == utils.nodeTypes.SLIDER then
		if node.focused then
			node.callback({ target = node, value = node.value })
		end
	elseif node.type == utils.nodeTypes.JOY then
		if node.pressed then
			node.joyX = node.joyX + data.dx / utils.sx
			node.joyY = node.joyY + data.dy / utils.sx
			node:limitMovement()
		end
	end
end

local function performReleaseAction(node, data)
	if not node.enabled then return end

	if node.pressed then
		if node.pointed then
			if node.type == utils.nodeTypes.BUTTON then
				node.callback({ target = node })
			elseif node.type == utils.nodeTypes.TOGGLE then
				node:change()
				node.callback({ target = node, value = node.value })
			elseif node.type == utils.nodeTypes.MULTI then
				node:change()
				node.callback({ target = node, value = node.text })
			end
		end

		if node.type == utils.nodeTypes.JOY then
			node.callback({ target = node, value = {
				lastX = node.joyX,
				lastY = node.joyY
			}})
			node.joyX, node.joyY = 0, 0
		end
	end

	node.pressed = false
end

function urutora:pressed()
	return function(x, y)
		self.focused_node = nil
		for _, v in pairs(self.nodes) do
			if v.enabled then
				v:forEach(function (node)
					performPressedAction(node, { x = x, y = y, urutora = self })
				end)
			end
		end
		self:setFocusedNode(self.focused_node)
	end
end

function urutora:moved()
	return function(x, y, dx, dy)
		for _, v in pairs(self.nodes) do
			v:forEach(function (node)
				performMovedAction(node, {
					x = x,
					y = y,
					dx = dx,
					dy = dy
				})
			end)
		end
	end
end

function urutora:released()
	return function(x, y)
		for _, v in pairs(self.nodes) do
			v:forEach(function (node)
				performReleaseAction(node, {
					x = x,
					y = y
				})
			end)
		end
	end
end

function urutora:textinput()
	return function(text)
		for _, v in pairs(self.nodes) do
			v:forEach(function (node)
				performKeyboardAction(node, {
					text = text
				})
			end)
		end
	end
end

function urutora:keypressed()
	return function(k, scancode, isrepeat)
		for _, v in pairs(self.nodes) do
			v:forEach(function (node)
				performKeyboardAction(node, {
					scancode = scancode,
					isrepeat = isrepeat
				})
			end)
		end
	end
end

return urutora