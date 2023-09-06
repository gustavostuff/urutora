local modules = (...):gsub('%.[^%.]+$', '') .. "."
local utils = require(modules .. 'utils')
local class = require(modules .. 'class')

local panel 	    = require(modules .. 'panel')
local button 	    = require(modules .. 'button')
local image 	    = require(modules .. 'image')
local animation   = require(modules .. 'animation')
local baseNode    = require(modules .. 'baseNode')
local text 		    = require(modules .. 'text')
local multi 	    = require(modules .. 'multi')
local slider 	    = require(modules .. 'slider')
local toggle 	    = require(modules .. 'toggle')
local progressBar = require(modules .. 'progressBar')
local joy 		    = require(modules .. 'joy')

local kat = require(modules .. 'katsudo') 

local urutora = class('urutora')
urutora.utils = utils
urutora.katsudo = kat

function urutora.setDefaultFont(font)
  utils.default_font = font
end

function urutora.setDimensions(x, y, scaleX, scaleY)
  utils.x = x
  utils.y = y
  utils.sx = scaleX
  utils.sy = scaleY
end
urutora.setDimensions(0, 0, 1, 1)

function urutora:constructor()
  self.nodes = {}
  self.focused_node = nil
end

function urutora.panel(data, nameid)
  local node = panel:newFrom(data)
  node.type = utils.nodeTypes.PANEL
  node.nameid = nameid
  return node
end

function urutora.image(data)
  local node = image:newFrom(data)
  node.type = utils.nodeTypes.IMAGE
  return node
end

function urutora.animation(data)
  local node = animation:newFrom(data)
  node.type = utils.nodeTypes.ANIMATION
  return node
end

function urutora.label(data)
  local node = baseNode:newFrom(data)
  node.type = utils.nodeTypes.LABEL
  return node
end

function urutora.text(data)
  local node = text:newFrom(data)
  node.type = utils.nodeTypes.TEXT
  return node
end

function urutora.multi(data)
  local node = multi:newFrom(data)
  node.type = utils.nodeTypes.MULTI
  return node
end

function urutora.button(data)
  local node = button:newFrom(data)
  node.type = utils.nodeTypes.BUTTON
  return node
end

function urutora.slider(data)
  local node = slider:newFrom(data)
  node.type = utils.nodeTypes.SLIDER
  return node
end

function urutora.toggle(data)
  local node = toggle:newFrom(data)
  node.type = utils.nodeTypes.TOGGLE
  return node
end

function urutora.progressBar(data)
  local node = progressBar:newFrom(data)
  node.type = utils.nodeTypes.PROGRESS_BAR
  return node
end

function urutora.joy(data)
  local node = joy:newFrom(data)
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

function urutora:getByTag(tag)
  for _, v in ipairs(self.nodes) do
    if v.tag and v.tag == tag then
      return v
    end
    if utils.isPanel(v) then
      local nested
      v:forEach(function (node)
        if node.tag and node.tag == tag then
          nested = node
        end
      end)
      return nested
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
          node:deactivate()
        end
      end)
    end
  end
  return self
end

function urutora:activateGroup(g)
  for _, v in ipairs(self.nodes) do
    if v.group and v.group == g then
      v:activateGroup(g)
    end
  end
end

function urutora:deactivateGroup(g)
  for _, v in ipairs(self.nodes) do
    if v.group and v.group == g then
      v:deactivateGroup(g)
    end
  end
end

function urutora:setGroupVisible(g, value)
  for _, v in ipairs(self.nodes) do
    if v.group and v.group == g then
      v:setVisible(value)
    end
  end
end

function urutora:setGroupEnabled(g, value)
  for _, v in ipairs(self.nodes) do
    if v.group and v.group == g then
      v:setEnabled(value)
    end
  end
end

function urutora:setStyle(style, nodeType)
  for _, v in ipairs(self.nodes) do
    if (v.type == nodeType) or (not nodeType) then
      v:setStyle(style, nodeType)
    end

    if utils.isPanel(v) then
      v:forEach(function (node)
        if (node.type == nodeType) or (not nodeType) then
          node:setStyle(style, nodeType)
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
  if node then
    node.focused = true
    if utils.isTextField(node) then
      node:resetCursor()
    end
  end
end

function urutora:draw()
  lg.push('all')
  lg.setFont(utils.default_font)
  lg.setLineStyle(utils.style.lineStyle)
  lg.setLineWidth(utils.style.lineWidth)

  for _, v in ipairs(self.nodes) do
    if v.visible then
      if utils.needsBase(v) then
        v:drawBaseRectangle()
      else
        if v.draw then
          v:draw()
        end
      end

      if not utils.isPanel(v) then
        v:drawText()
      end
    end
  end

  lg.pop()
end

function urutora:update(dt)
  local x, y = utils:getMouse()

  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v.pointed = v:pointInsideNode(x, y) and not utils.isLabel(v)
      if v.update then v:update(dt) end
    end
  end
  self.katsudo.update(dt)
end

function urutora:pressed(x, y, button)
  if not (button == utils.mouseButtons.LEFT) then return end
  self.focused_node = nil
  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v:performPressedAction({ x = x, y = y, urutora = self, button = button })
    end
  end
  self:setFocusedNode(self.focused_node)
end

function urutora:moved(x, y, dx, dy)
  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v:performMovedAction({
        x = x,
        y = y,
        dx = dx,
        dy = dy
      })
    end
  end
end

function urutora:released(x, y)
  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v:performReleaseAction({
        x = x,
        y = y
      })
    end
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

local function findNestedPointed(node)
  local t
  if node.pointed then
    if utils.isPanel(node) then
      -- check panel overflow
      if node:getActualSizeY() > node.h then
        t = node
      end
      for _, v in pairs(node.children) do
        local ret = findNestedPointed(v)
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
    element = findNestedPointed(v) or element
  end
  if element then
    element:performMouseWheelAction({
      x = x,
      y = y,
    })
  end
end

return urutora
