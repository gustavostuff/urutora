local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local types = require(modules .. 'types')

local media = {}

-- Fit content into node bounds and call drawFn(x, y, sx, sy).
function media.fitAndDraw(node, contentW, contentH, drawFn)
  local sx = node.w / contentW
  local sy = node.h / contentH
  local x = node.x
  local y = node.y

  if node.keepAspectRatio then
    sx = math.min(sx, sy)
    sy = sx
    x = x + (node.w - (contentW * sx)) / 2
    y = y + (node.h - (contentH * sy)) / 2

    if node.align == types.alignments.LEFT then
      x = node.x
    elseif node.align == types.alignments.RIGHT then
      x = node.x + node.w - contentW * sx
    end
  end

  if node.keepOriginalSize then
    x = node.x + node.w / 2 - contentW / 2
    y = node.y + node.h / 2 - contentH / 2
    sx, sy = 1, 1
  end

  drawFn(math.floor(x), math.floor(y), sx, sy)
end

return media
