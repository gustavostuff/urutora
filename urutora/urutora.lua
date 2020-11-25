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
		if utils.isPanel(v) then
			v:forEach(function (_node)
				_node.focused = false
			end)
		else
			v.focused = false
		end
	end
	if node then node.focused = true end
end

function urutora:draw()
	lovg.push('all')

	lovg.setLineWidth(1)
	lovg.setLineStyle('rough')
	lovg.setFont(utils.default_font)

	for _, v in ipairs(self.nodes) do
		if v.visible then
			if utils.needsBase(v) then v:drawBaseRectangle() end
			if v.draw then v:draw() end

			if not utils.isPanel(v) then
				v:drawText()
			end
		end
	end

	lovg.pop()
end

function urutora:update(dt)
	local x, y = utils.getMouse()

	for _, v in ipairs(self.nodes) do
		if v.enabled then
			v.pointed = v:pointInsideNode(x, y) and not utils.isLabel(v)
			if v.update then v:update(dt) end
		end
	end
end

function urutora:pressed(x, y)
	self.focused_node = nil
	for _, v in ipairs(self.nodes) do
		if v.enabled then
			v:performPressedAction({ x = x, y = y, urutora = self })
		end
	end
	self:setFocusedNode(self.focused_node)
end

function urutora:moved(x, y, dx, dy)
	for _, v in ipairs(self.nodes) do
		v:performMovedAction({
			x = x,
			y = y,
			dx = dx,
			dy = dy
		})
	end
end

function urutora:released(x, y)
	for _, v in ipairs(self.nodes) do
		v:performReleaseAction({
			x = x,
			y = y
		})
	end
end

function urutora:textinput(text)
	for _, v in ipairs(self.nodes) do
		v:performKeyboardAction({
			text = text
		})
	end
end

function urutora:keypressed(k, scancode, isrepeat)
	for _, v in ipairs(self.nodes) do
		v:performKeyboardAction({
			scancode = scancode,
			isrepeat = isrepeat
		})
	end
end

local function find_nested_pointed(node)
	local t
	if node.pointed then
		if utils.isPanel(node) then
			-- check panel overflow
			if node:getActualSizeY() > node.h then
				t = node
			end
			for _, v in pairs(node.children) do
				local ret = find_nested_pointed(v)
				if ret then
					t = ret
					break
				end
			end
		elseif utils.isSlider(node) then
			t = node
		end
	end
	return t
end

function urutora:wheelmoved(x, y)
	local element
	for _, v in ipairs(self.nodes) do
		element = find_nested_pointed(v) or element
	end
	if element then
		element:performMouseWheelAction({
			x = x,
			y = y,
		})
	end
end

return urutora