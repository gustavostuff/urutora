local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')
local panelLayout = require(modules .. 'panelLayout')
local panelScroll = require(modules .. 'panelScroll')

local panel = baseNode:extend('panel')

local DEFAULT_SPACING = 4
local DEFAULT_SCROLL_SPEED = 0.1
local DEBUG_CONTRAST = 0.3

function panel:constructor()
  panel.super.constructor(self)
  self.children = {}
  self.customSpacings = {}
  self.rows = self.rows or 1
  self.cols = self.cols or 1
  self.rowspans = {}
  self.colspans = {}
  self.spacing = self.spacing or DEFAULT_SPACING
  self.ox = self.ox or 0
  self.oy = self.oy or 0
  self.scrollSpeed = self.scrollSpeed or DEFAULT_SCROLL_SPEED
  self.sliderOpacity = 0

  self.cellWidth = self.cellWidth or self.csx
  self.csx = self.cellWidth
  self._maxx = self.cols * (self.cellWidth or 0)
  self._maxy = self.rows * (self.cellHeight or 0)

  self:initDebugGrid()
end

function panel:initDebugGrid()
  self.debugGrid = {}
  for y = 1, self.rows do
    for x = 1, self.cols do
      table.insert(self.debugGrid, {
        x = x,
        y = y,
        color = ((x + y) % 2 == 0) and
          { DEBUG_CONTRAST, DEBUG_CONTRAST, DEBUG_CONTRAST, 0.3 } or
          { 1 - DEBUG_CONTRAST, 1 - DEBUG_CONTRAST, 1 - DEBUG_CONTRAST, 0.3 }
      })
    end
  end
end

function panel:setStyle(style, nodeType)
  for _, v in pairs(self.children) do
    if (v.type == nodeType) or (not nodeType) then
      v:setStyle(style, nodeType)
    end
  end
  self:updateNodesPosition()
  return self
end

function panel:clear()
  self.children = {}
  self.rowspans = {}
  self.colspans = {}
  self.ox = 0
  self.oy = 0
  self._maxx = 0
  self._maxy = 0
  panelScroll.invalidateScissorCache(self)
end

function panel:calculateRect(row, col)
  return panelLayout.calculateRect(self, row, col)
end

function panel:updateDimensions(newNode)
  newNode:updateNodesPosition()
  newNode:initDebugGrid()
end

function panel:addAt(row, col, newNode)
  if utils.isPanel(newNode) then
    self.customSpacings[panelLayout.spacingKey(row, col)] = 0
  end
  local x, y, w, h = self:calculateRect(row, col)
  newNode:setBounds(x, y, w, h)
  utils.fixToggleBounds(newNode)
  newNode.parent = self
  newNode._row = row
  newNode._col = col
  self.children[row * self.cols + col] = newNode

  if utils.isPanel(newNode) then
    self:updateDimensions(newNode)
  end
  return self
end

function panel:getChildren(row, col)
  return self.children[row * self.cols + col]
end

function panel:findFromTag(tag)
  for _, v in pairs(self.children) do
    if v.tag and v.tag == tag then
      return v
    end

    if utils.isPanel(v) then
      local ret = v:findFromTag(tag)
      if ret then
        return ret
      end
    end
  end
end

function panel:getActualSizeX()
  if self.csx then
    return self._maxx
  end
  return self.w
end

function panel:getActualSizeY()
  if self.cellHeight then
    return self._maxy
  end
  return self.h
end

function panel:setScrollX(value)
  panelScroll.setScrollX(self, value)
end

function panel:setScrollY(value)
  panelScroll.setScrollY(self, value)
end

function panel:getScrollX()
  return panelScroll.getScrollX(self)
end

function panel:getScrollY()
  return panelScroll.getScrollY(self)
end

function panel:spacingAt(row, col, size)
  self.customSpacings[panelLayout.spacingKey(row, col)] = size
  return self
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
  self:updateNodesPosition()
end

function panel:updateNodesPosition()
  panelLayout.updateNodesPosition(self)
end

function panel:invalidateScissorCache()
  panelScroll.invalidateScissorCache(self)
end

function panel:getScissorOffset()
  return panelScroll.getScissorOffset(self)
end

function panel:showSlider()
  self.sliderOpacity = 1
end

local function drawBg(p)
  local r, g, b, a = lg.getColor()
  if p.bgColor then
    lg.setColor(p.bgColor)
    if not p.enabled then
      lg.setColor(0.5, 0.5, 0.5, 0.5)
    end
    lg.rectangle('fill', p.x, p.y, p.w, p:getActualSizeY())
  end
  lg.setColor(r, g, b, a)
end

local function drawScrollIndicator(p)
  if not p.cellHeight then return end
  local _, fgColor = p:getLayerColors()
  fgColor = utils.withOpacity(fgColor, p.sliderOpacity or 0)
  local sliderW = p.spacing / 2
  local sliderH = (p.h / p:getActualSizeY()) * p.h
  lg.setColor(fgColor)

  lg.rectangle('fill',
    p.x + p.w - sliderW,
    p.y + (p:getScrollY() * (p.h - sliderH)),
    sliderW,
    sliderH
  )
end

local function drawDebug(p)
  if not p.debug then return end
  local cellW = p.w / p.cols
  local cellH = p:getActualSizeY() / p.rows
  for _, cell in ipairs(p.debugGrid) do
    lg.setColor(cell.color)
    lg.rectangle('fill',
      p.x + (cell.x - 1) * cellW,
      p.y + (cell.y - 1) * cellH,
      cellW,
      cellH
    )
  end
end

function panel:draw()
  local scx, scy, scw, sch = lg.getScissor()
  local tx, ty = math.floor(-self.ox), math.floor(-self.oy)

  local x = self.x
  local y = self.y
  local ox, oy = 0, 0
  if self.parent then
    ox, oy = self.parent:getScissorOffset()
  end
  lg.push()
  lg.translate(tx, ty)
  lg.intersectScissor(x - ox, y - oy, self.w, self.h)

  drawBg(self)
  for _, node in pairs(self.children) do
    if node.visible then
      if utils.needsBase(node) then node:drawBaseRectangle() end
      if node.draw then node:draw() end
      node:drawText()
    end
  end
  drawDebug(self)
  lg.translate(-tx, -ty)
  drawScrollIndicator(self)

  lg.setScissor(scx, scy, scw, sch)
  lg.pop()
end

function panel:update(dt, mx, my)
  if not mx then
    mx, my = utils:getMouse()
  end

  for _, node in pairs(self.children) do
    if node.enabled then
      node.pointed = self.pointed and node:pointInsideNode(mx, my) and not utils.isLabel(node)
      if node.update then node:update(dt, mx, my) end
    end
  end
  self.sliderOpacity = (self.sliderOpacity > 0) and (self.sliderOpacity - dt) or 0
end

function panel:disable()
  self.pointed = false
  local function recursiveDisable(p)
    p:setEnabled(false)
    for _, v in pairs(p.children) do
      v.pointed = false
      v:setEnabled(false)
      if utils.isPanel(v) then
        recursiveDisable(v)
      end
    end
  end
  recursiveDisable(self)
  return self
end

function panel:enable()
  if self.enabled then return end
  local function recursiveEnable(p)
    p:setEnabled(true)
    for _, v in pairs(p.children) do
      v:setEnabled(true)
      if utils.isPanel(v) then
        recursiveEnable(v)
      end
    end
  end
  recursiveEnable(self)
  return self
end

function panel:deactivate()
  self:disable()
  self:hide()
end

function panel:activate()
  self:enable()
  self:show()
end

function panel:hide()
  self:setVisible(false)
  self:forEach(function (node)
    node:setVisible(false)
  end)
  return self
end

function panel:show()
  self:setVisible(true)
  self:forEach(function (node)
    node:setVisible(true)
  end)
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
    for _, node in pairs(self.children) do
      node:performPressedAction(data)
    end
  end
end

function panel:performKeyboardAction(data)
  if self.enabled then
    for _, node in pairs(self.children) do
      node:performKeyboardAction(data)
    end
  end
end

function panel:performMovedAction(data)
  if self.enabled then
    for _, node in pairs(self.children) do
      node:performMovedAction(data)
    end
  end
end

function panel:performReleaseAction(data)
  if self.enabled then
    for _, node in pairs(self.children) do
      node:performReleaseAction(data)
    end
  end
end

function panel:performMouseWheelAction(data)
  if not self.enabled or not self.pointed then return end
  self:showSlider()
  local v = self:getScrollY()
  self:setScrollY(v + (-data.y) * (self.scrollSpeed or utils.scrollSpeed))
end

return panel
