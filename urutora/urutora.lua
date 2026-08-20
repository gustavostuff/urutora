local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local utils = require(modules .. 'utils')
local class = require(modules .. 'class')

local panel       = require(modules .. 'panel')
local button      = require(modules .. 'button')
local image       = require(modules .. 'image')
local animation   = require(modules .. 'animation')
local label       = require(modules .. 'label')
local text        = require(modules .. 'text')
local multi       = require(modules .. 'multi')
local slider      = require(modules .. 'slider')
local toggle      = require(modules .. 'toggle')
local progressBar = require(modules .. 'progressBar')
local joy         = require(modules .. 'joy')

local kat = require(modules .. 'katsudo')

local urutora = class('urutora')
urutora.utils = utils
urutora.katsudo = kat

function urutora.setDefaultFont(font)
  utils.default_font = font
  if font and not utils.style.padding then
    utils.style.padding = font:getHeight() / 2
  end
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
  self._lastFocused = nil
  self._event = {}
end

local function make(cls, typeId, data, nameid)
  local node = cls:newFrom(data)
  node.type = typeId
  if nameid ~= nil then
    node.nameid = nameid
  end
  return node
end

function urutora.panel(data, nameid)
  return make(panel, utils.nodeTypes.PANEL, data, nameid)
end

function urutora.image(data)
  return make(image, utils.nodeTypes.IMAGE, data)
end

function urutora.animation(data)
  return make(animation, utils.nodeTypes.ANIMATION, data)
end

function urutora.label(data)
  return make(label, utils.nodeTypes.LABEL, data)
end

function urutora.text(data)
  return make(text, utils.nodeTypes.TEXT, data)
end

function urutora.multi(data)
  return make(multi, utils.nodeTypes.MULTI, data)
end

function urutora.button(data)
  return make(button, utils.nodeTypes.BUTTON, data)
end

function urutora.slider(data)
  return make(slider, utils.nodeTypes.SLIDER, data)
end

function urutora.toggle(data)
  return make(toggle, utils.nodeTypes.TOGGLE, data)
end

function urutora.progressBar(data)
  return make(progressBar, utils.nodeTypes.PROGRESS_BAR, data)
end

function urutora.joy(data)
  return make(joy, utils.nodeTypes.JOY, data)
end

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

function urutora:eachNode(fn)
  for _, v in ipairs(self.nodes) do
    fn(v)
    if utils.isPanel(v) then
      v:forEach(fn)
    end
  end
end

function urutora:findNode(predicate)
  for _, v in ipairs(self.nodes) do
    if predicate(v) then
      return v
    end
    if utils.isPanel(v) then
      local found
      v:forEach(function (node)
        if not found and predicate(node) then
          found = node
        end
      end)
      if found then
        return found
      end
    end
  end
end

function urutora:getByTag(tag)
  return self:findNode(function (node)
    return node.tag and node.tag == tag
  end)
end

function urutora:activateByTag(tag)
  self:eachNode(function (node)
    if node.tag and node.tag == tag then
      node:activate()
    end
  end)
  return self
end

function urutora:deactivateByTag(tag)
  self:eachNode(function (node)
    if node.tag and node.tag == tag then
      node:deactivate()
    end
  end)
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
  self:eachNode(function (node)
    if (node.type == nodeType) or (not nodeType) then
      node:setStyle(style, nodeType)
    end
  end)
  return self
end

function urutora:setFocusedNode(node)
  local prev = self._lastFocused
  if prev and prev ~= node then
    prev.focused = false
  end
  if node then
    node.focused = true
    if utils.isTextField(node) then
      node:resetCursor()
    end
  end
  self._lastFocused = node
  self.focused_node = node
end

function urutora:draw()
  lg.push('all')
  lg.setFont(utils.getDefaultFont())
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
      if v.update then v:update(dt, x, y) end
    end
  end
  self.katsudo.update(dt)
end

function urutora:pressed(x, y, button)
  if not (button == utils.mouseButtons.LEFT) then return end
  self.focused_node = nil
  local e = self._event
  e.x, e.y, e.dx, e.dy, e.text, e.scancode, e.isrepeat = x, y, nil, nil, nil, nil, nil
  e.urutora = self
  e.button = button
  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v:performPressedAction(e)
    end
  end
  self:setFocusedNode(self.focused_node)
end

function urutora:moved(x, y, dx, dy)
  local e = self._event
  e.x, e.y, e.dx, e.dy = x, y, dx, dy
  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v:performMovedAction(e)
    end
  end
end

function urutora:released(x, y)
  local e = self._event
  e.x, e.y = x, y
  for _, v in ipairs(self.nodes) do
    if v.enabled then
      v:performReleaseAction(e)
    end
  end
end

function urutora:textinput(text)
  local e = self._event
  e.text = text
  e.scancode = nil
  e.isrepeat = nil
  for _, v in ipairs(self.nodes) do
    v:performKeyboardAction(e)
  end
end

function urutora:keypressed(k, scancode, isrepeat)
  local e = self._event
  e.text = nil
  e.scancode = scancode
  e.isrepeat = isrepeat
  for _, v in ipairs(self.nodes) do
    v:performKeyboardAction(e)
  end
end

local function findNestedPointed(node)
  local t
  if node.pointed then
    if utils.isPanel(node) then
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
    local e = self._event
    e.x, e.y = x, y
    element:performMouseWheelAction(e)
  end
end

return urutora
