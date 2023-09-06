local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local panel = baseNode:extend('panel')

function panel:constructor()
  panel.super.constructor(self)
  self.children = {}
  self.customSpacings = {}
  self.rows = self.rows or 1
  self.cols = self.cols or 1
  self.rowspans = {}
  self.colspans = {}
  self.spacing = self.spacing or 4
  self.ox = self.ox or 0
  self.oy = self.oy or 0
  self.scrollSpeed = self.scrollSpeed or 0.1
  self.sliderOpacity = 0

  self._maxx = (self.cols) * (self.csx or 0)
  self._maxy = (self.rows) * (self.cellHeight or 0)

  self:initDebugGrid()
end

function panel:initDebugGrid()
  self.debugGrid = {}
  local contrastRatio = 0.3
  for y = 1, self.rows do
    for x = 1, self.cols do
      table.insert(self.debugGrid, {
        x = x,
        y = y,
        color = ((x + y) % 2 == 0) and
          {contrastRatio, contrastRatio, contrastRatio, 0.3} or
          {1 - contrastRatio, 1 - contrastRatio, 1 - contrastRatio, 0.3}
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
end

function panel:calculateRect(row, col)
  local w, h = self.csx or (self.w / self.cols), self.cellHeight or (self.h / self.rows)
  local x, y = w * (col - 1), h * (row - 1)
  local s = self.customSpacings[row .. ',' .. col] or self.spacing
  local rs = (self.rowspans[col] or {})[row] or 1
  local cs = (self.colspans[col] or {})[row] or 1

  local widthColspan = (w * cs)
  local heightRowspan = (h * rs)

  local mx = x + widthColspan
  local my = y + heightRowspan
  if self._maxx < mx then self._maxx = mx end
  if self._maxy < my then self._maxy = my end

  x, y = self.x + x + s / 2, self.y + y + s / 2
  w, h = widthColspan - s, heightRowspan - s
  return x, y, w, h
end

function panel:updateDimensions(newNode)
  newNode:updateNodesPosition()
  newNode:initDebugGrid()
end

function panel:setGroup(g)
  self.group = g

  if self.children then
    for _, child in ipairs(self.children) do
      child:setGroup(g)
    end
  end

  return self
end

function panel:addAt(row, col, newNode)
  if utils.isPanel(newNode) then
    self.customSpacings[row .. ',' .. col] = 0
  end
  local x, y, w, h = self:calculateRect(row, col)
  newNode:setBounds(x, y, w, h)
  utils.fixToggleBounds(newNode)
  newNode.parent = self
  newNode._row = row
  newNode._col = col
  self.children[row * self.cols + col] = newNode

  --recalculate panel nodes position
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
  else
    return self.w
  end
end

function panel:getActualSizeY()
  if self.cellHeight then
    return self._maxy
  else
    return self.h
  end
end

function panel:setScrollX(value)
  value = math.max(0, math.min(value, 1))
  local dx = self:getActualSizeX() - self.w
  if dx > 0 then self.ox = dx * value end
end

function panel:setScrollY(value)
  value = math.max(0, math.min(value, 1))
  local dy = self:getActualSizeY() - self.h
  if dy > 0 then self.oy = (dy * value) end
end

function panel:getScrollX()
  return self.ox / (self:getActualSizeX() - self.w)
end

function panel:getScrollY()
  return self.oy / (self:getActualSizeY() - self.h)
end

function panel:spacingAt(row, col, size)
  self.customSpacings[row .. ',' .. col] = size
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
  self.cellWidth = self.w / self.cols * (self.horizontalScale or 1)
  self.cellHeight = self.h / self.rows * (self.verticalScale or 1)
  self._maxx = self.w * (self.horizontalScale or 1)
  self._maxy = self.h * (self.verticalScale or 1)

  for _, node in pairs(self.children) do
    local x, y, w, h = self:calculateRect(node._row, node._col)
    node:setBounds(x, y, w, h)
    if utils.isPanel(node) then
      node:updateNodesPosition()
    end
    utils.fixToggleBounds(node)
  end
end

function panel:getScissorOffset()
  local parent = self.parent
  if parent then
    local ox, oy = parent:getScissorOffset()
    return self.ox + ox, self.oy + oy
  else
    return self.ox, self.oy
  end
end

function panel:showSlider()
  self.sliderOpacity = 1
end

local function _drawBg(panel)
  local colorBkp = {lg.getColor()}
  if panel.bgColor then
    lg.setColor(panel.bgColor)
    if not panel.enabled then
      lg.setColor(0.5, 0.5, 0.5, 0.5)
    end
    lg.rectangle('fill', panel.x, panel.y, panel.w, panel:getActualSizeY())
  end
  lg.setColor(colorBkp)
end

local function _drawScrollIndicator(panel, offsetX, offsetY)
  if not panel.cellHeight then return end
  local _, fgColor = panel:getLayerColors()
  fgColor = utils.withOpacity(fgColor, panel.sliderOpacity or 0)
  local sliderW = panel.spacing / 2
  local sliderH = (panel.h / panel:getActualSizeY()) * panel.h
  lg.setColor(fgColor)

  lg.rectangle('fill',
    panel.x + panel.w - sliderW,
    panel.y + (panel:getScrollY() * (panel.h - sliderH)),
    sliderW,
    sliderH
  )
end

local function _drawDebug(panel)
  if not panel.debug then return end
  local cellW = (panel.w / panel.cols)
  local cellH = (panel:getActualSizeY() / panel.rows)
  for _, cell in ipairs(panel.debugGrid) do
    lg.setColor(cell.color)
    lg.rectangle('fill',
      panel.x + (cell.x - 1) * cellW,
      panel.y + (cell.y - 1) * cellH,
      cellW,
      cellH
    )
  end
end

function panel:draw()
  local scx, scy, csx, cellHeight = lg.getScissor()
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

  _drawBg(self)
  for _, node in pairs(self.children) do
    if node.visible then
      if utils.needsBase(node) then node:drawBaseRectangle() end
      if node.draw then node:draw() end
      node:drawText()
    end
  end
  _drawDebug(self)
  lg.translate(-tx, -ty)
  _drawScrollIndicator(self, ox, oy)

  if true or self.parent then
    love.graphics.setColor(1,1,1)
  end

  lg.setScissor(scx, scy, csx, cellHeight)
  lg.pop()
end

function panel:update(dt)
  local x, y = utils:getMouse()

  for _, node in pairs(self.children) do
    if node.enabled then
      node.pointed = self.pointed and node:pointInsideNode(x, y) and not utils.isLabel(node)
      if node.update then node:update(dt) end
    end
  end
  self.sliderOpacity = (self.sliderOpacity > 0) and (self.sliderOpacity - dt) or 0
end

function panel:pointInsideNode(x, y)
  local parent = self.parent
  local ox, oy = 0, 0
  if parent then
    ox, oy = parent:getScissorOffset()
  end

  return utils.pointInsideRect(x, y, self.x - ox, self.y - oy, self.w, self.h)
end

function panel:disable()
  self.pointed = false
  local function recursiveDisable(panel)
    panel:setEnabled(false)
    for k, v in pairs(panel.children) do
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
  local function recursiveEnable(panel)
    panel:setEnabled(true)
    for k, v in pairs(panel.children) do
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

return panel
