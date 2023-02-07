local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local lovg = love.graphics

local panel = baseNode:extend('panel')

function panel:constructor()
  panel.super.constructor(self)
  self.children = {}
  self.rows = self.rows or 1
  self.cols = self.cols or 1
  self.rowspans = {}
  self.colspans = {}
  self.spacing = self.spacing or 4
  self.ox = self.ox or 0
  self.oy = self.oy or 0

  self._maxx = (self.cols - 1) * (self.csx or 0)
  self._maxy = (self.rows - 1) * (self.csy or 0)

  self.debugGrid = {}
  for y = 1, self.rows do
    for x = 1, self.cols do
      table.insert(self.debugGrid, {
        x = x,
        y = y,
        color = ((x + y) % 2 == 0) and {.2, .2, .2, 0.5} or {.8, .8, .8, 0.5}
      })
    end
  end
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
  self._maxx = 0
  self._maxy = 0
end

function panel:calculateRect(row, col)
  local w, h = self.csx or (self.w / self.cols), self.csy or (self.h / self.rows)
  local x, y = w * (col - 1), h * (row - 1)
  local s = self.spacing
  local rs = (self.rowspans[col] or {})[row] or 1
  local cs = (self.colspans[col] or {})[row] or 1

  local widthColspan = (w * cs)
  local heightRowspan = (h * rs)

  local mx = x + widthColspan
  local my = y + heightRowspan
  if self._maxx < mx then self._maxx = mx end
  if self._maxy < my then self._maxy = my end

  -- if self.tag == 'PanelA' then
  --   local realItemW = (self.w - (self.cols + 1) * s) / self.cols
  --   local realItemH = (self.h - (self.rows + 1) * s) / self.rows
  --   print('w:', realItemW, 'h:', realItemH)
  -- end

  x, y = self.x + x + s / 2, self.y + y + s / 2
  w, h = widthColspan - s, heightRowspan - s
  return x, y, w, h
end

function panel:addAt(row, col, newNode)
  local x, y, w, h = self:calculateRect(row, col)
  newNode:setBounds(x, y, w, h)
  newNode.parent = self
  newNode._row = row
  newNode._col = col
  self.children[row * self.cols + col] = newNode

  --recalculate panel nodes position
  if utils.isPanel(newNode) then newNode:updateNodesPosition() end
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
  if self.csy then
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
  if dy > 0 then self.oy = math.floor(dy * value) end
end

function panel:getScrollX()
  return self.ox / (self:getActualSizeX() - self.w)
end

function panel:getScrollY()
  return self.oy / (self:getActualSizeY() - self.h)
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
  for _, node in pairs(self.children) do
    local x, y, w, h = self:calculateRect(node._row, node._col)
    node:setBounds(x, y, w, h)
    if utils.isPanel(node) then
      node:updateNodesPosition()
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

local function _drawBg(panel)
  local colorBkp = {love.graphics.getColor()}
  if panel.bgColor then
    love.graphics.setColor(panel.bgColor)
    if not panel.enabled then
      love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    end
    love.graphics.rectangle('fill', panel.x, panel.y, panel.w, panel:getActualSizeY())
  end
  love.graphics.setColor(colorBkp)
end

local function _drawScrollIndicator(panel, offsetX, offsetY)
  if not panel.csy then return end
  local _, fgColor = panel:getLayerColors()
  local sliderW = panel.spacing / 2
  lovg.setColor(fgColor)

  lovg.rectangle('fill',
    panel.x + panel.w - sliderW,
    panel.y,
    sliderW,
    10
  )
end

local function _drawDebug(panel)
  if not panel.debug then return end
  local cellW = (panel.w / panel.cols)
  local cellH = (panel:getActualSizeY() / panel.rows)
  for _, cell in ipairs(panel.debugGrid) do
    love.graphics.setColor(cell.color)
    love.graphics.rectangle('fill',
      panel.x + (cell.x - 1) * cellW,
      panel.y + (cell.y - 1) * cellH,
      cellW,
      cellH
    )
  end
end

function panel:draw()
  local scx, scy, scsx, scsy = love.graphics.getScissor()

  local x = self.x
  local y = self.y
  local ox, oy = 0, 0
  if self.parent then
    ox, oy = self.parent:_get_scissor_offset()
  end
  lovg.push()
  lovg.translate(math.floor(-self.ox), math.floor(-self.oy))
  lovg.intersectScissor(x - ox, y - oy, self.w, self.h)
  _drawBg(self)
  for _, node in pairs(self.children) do
    if node.visible then
      if utils.needsBase(node) then node:drawBaseRectangle() end
      if node.draw then node:draw() end
      node:drawText()
    end
  end
  _drawScrollIndicator(self, x - ox, y - oy)
  _drawDebug(self)

  if self.dragX then
    lovg.circle('fill', self.dragX, self.dragY, 10)
  end

  lovg.setScissor(scx, scy, scsx, scsy)
  lovg.pop()
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
  if not self.enabled then return end
  local function recursiveDisable(panel)
    panel:setEnabled(false)
    for k, v in pairs(panel.children) do
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
