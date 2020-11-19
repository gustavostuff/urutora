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

function urutora.panel(data, nameid)
	local node = panel:new_from(data)
	node.type = utils.nodeTypes.PANEL
	node.nameid = nameid
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

function urutora:add(component)
	table.insert(self.nodes, component)
end

function urutora:remove(component)
	for i, v in ipairs(self.nodes) do
		if component == v then
			table.remove(self.nodes, i)
			break
		end
	end
end

function urutora:activateByTag(tag)
	for _, v in ipairs(self.nodes) do
		if v.tag and v.tag == tag then
			v:activate()
		end
		if utils.isPanel(v) then
			v:forEach(function (node)
				if node.tag and node.tag == tag then
					node:activate()
				end
			end)
		end
	end
	return self
end

function urutora:deactivateByTag(tag)
	for _, v in ipairs(self.nodes) do
		if v.tag and v.tag == tag then
			v:deactivate()
		end
		if utils.isPanel(v) then
			v:forEach(function (node)
				if node.tag and node.tag == tag then
					print(node)
					node:deactivate()
				end
			end)
		end
	end
	return self
end

function urutora:setFocusedNode(node)
	for _, v in ipairs(self.nodes) do
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

	for _, p in ipairs(self.nodes) do
		p:draw()
	end

	lovg.pop()
end

function urutora:update(dt)
	for _, p in ipairs(self.nodes) do
		p:update()
	end
end

local function performPressedAction(node, data)
	local urutora = data.urutora
	if node.enabled then
		if node.pointed then
			node.pressed = true
			urutora.focused_node = node

			-- special cases
			if utils.isSlider(node) then
				node:update()
				node.callback({ target = node, value = node.value })
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
			node.joyY = node.joyY + data.dy / utils.sy
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

local function performMouseWheelAction(node, data)
	if not node.enabled then return end

	if node.pointed then
		if node.type == utils.nodeTypes.PANEL then
			local v = node:getScrollY()
			node:setScrollY(v + (-data.y) * utils.scroll_speed)
		elseif node.type == utils.nodeTypes.SLIDER then
			node:setValue(node.value + (-data.y) * utils.scroll_speed)
			node.callback({ target = node, value = node.value })
		end
	end
end

function urutora:pressed(x, y)
	self.focused_node = nil
	for _, v in ipairs(self.nodes) do
		if v.enabled then
			v:forEach(function (node)
				performPressedAction(node, { x = x, y = y, urutora = self })
			end)
		end
	end
	self:setFocusedNode(self.focused_node)
end

function urutora:moved(x, y, dx, dy)
	for _, v in ipairs(self.nodes) do
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

function urutora:released(x, y)
	for _, v in ipairs(self.nodes) do
		v:forEach(function (node)
			performReleaseAction(node, {
				x = x,
				y = y
			})
		end)
	end
end

function urutora:textinput(text)
	for _, v in ipairs(self.nodes) do
		v:forEach(function (node)
			performKeyboardAction(node, {
				text = text
			})
		end)
	end
end

function urutora:keypressed(k, scancode, isrepeat)
	for _, v in ipairs(self.nodes) do
		v:forEach(function (node)
			performKeyboardAction(node, {
				scancode = scancode,
				isrepeat = isrepeat
			})
		end)
	end
end

local function find_nested_pointed(node)
	local pp, pe
	if node.pointed then
		if utils.isPanel(node) then
			pp = node
			for _, v in pairs(node.children) do
				local pp_temp, pe_temp = find_nested_pointed(v)
				if pp_temp then pp = pp_temp end
				if pe_temp then pe = pe_temp end
			end
		else
			pe = node
		end
	end
	return pp, pe
end

function urutora:wheelmoved(x, y)
	local pointed_panel, pointed_element
	for _, v in ipairs(self.nodes) do
		pointed_panel, pointed_element = find_nested_pointed(v)
	end
	if pointed_panel then
		performMouseWheelAction(pointed_panel, {
			x = x,
			y = y,
		})
	end
	if pointed_element then
		performMouseWheelAction(pointed_element, {
			x = x,
			y = y,
		})
	end
end

return urutora