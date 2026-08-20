-- Panel grid layout helpers
local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')

local panelLayout = {}

local function spacingKey(row, col)
  return row * 65536 + col
end

function panelLayout.spacingKey(row, col)
  return spacingKey(row, col)
end

function panelLayout.calculateRect(panel, row, col)
  local cellW = panel.cellWidth or panel.csx or (panel.w / panel.cols)
  local cellH = panel.cellHeight or (panel.h / panel.rows)
  local x, y = cellW * (col - 1), cellH * (row - 1)
  local s = panel.customSpacings[spacingKey(row, col)] or panel.spacing
  local rs = (panel.rowspans[col] or {})[row] or 1
  local cs = (panel.colspans[col] or {})[row] or 1

  local widthColspan = cellW * cs
  local heightRowspan = cellH * rs

  local mx = x + widthColspan
  local my = y + heightRowspan
  if panel._maxx < mx then panel._maxx = mx end
  if panel._maxy < my then panel._maxy = my end

  x, y = panel.x + x + s / 2, panel.y + y + s / 2
  local w, h = widthColspan - s, heightRowspan - s
  return x, y, w, h
end

function panelLayout.updateNodesPosition(panel)
  if panel.csx then
    panel.cellWidth = panel.csx
  else
    panel.cellWidth = panel.w / panel.cols * (panel.horizontalScale or 1)
  end
  panel.cellHeight = panel.h / panel.rows * (panel.verticalScale or 1)
  panel._maxx = panel.w * (panel.horizontalScale or 1)
  panel._maxy = panel.h * (panel.verticalScale or 1)

  for _, node in pairs(panel.children) do
    local x, y, w, h = panelLayout.calculateRect(panel, node._row, node._col)
    node:setBounds(x, y, w, h)
    if utils.isPanel(node) then
      node:updateNodesPosition()
    end
    utils.fixToggleBounds(node)
  end
end

return panelLayout
