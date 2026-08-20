-- Panel scroll and scissor offset helpers
local panelScroll = {}

function panelScroll.invalidateScissorCache(panel)
  panel._cachedSox = nil
  panel._cachedSoy = nil
  if panel.children then
    for _, node in pairs(panel.children) do
      if node.invalidateScissorCache then
        node:invalidateScissorCache()
      end
    end
  end
end

function panelScroll.getScissorOffset(panel)
  if panel._cachedSox then
    return panel._cachedSox, panel._cachedSoy
  end
  local parent = panel.parent
  if parent then
    local ox, oy = parent:getScissorOffset()
    panel._cachedSox = panel.ox + ox
    panel._cachedSoy = panel.oy + oy
  else
    panel._cachedSox = panel.ox
    panel._cachedSoy = panel.oy
  end
  return panel._cachedSox, panel._cachedSoy
end

function panelScroll.setScrollX(panel, value)
  value = math.max(0, math.min(value, 1))
  local dx = panel:getActualSizeX() - panel.w
  if dx > 0 then
    panel.ox = dx * value
    panelScroll.invalidateScissorCache(panel)
  end
end

function panelScroll.setScrollY(panel, value)
  value = math.max(0, math.min(value, 1))
  local dy = panel:getActualSizeY() - panel.h
  if dy > 0 then
    panel.oy = dy * value
    panelScroll.invalidateScissorCache(panel)
  end
end

function panelScroll.getScrollX(panel)
  return panel.ox / (panel:getActualSizeX() - panel.w)
end

function panelScroll.getScrollY(panel)
  return panel.oy / (panel:getActualSizeY() - panel.h)
end

return panelScroll
