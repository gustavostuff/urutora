local utils = {}

function utils.isLabel(node) return node.type == urutora.nodeTypes.LABEL end
function utils.isToggle(node) return node.type == urutora.nodeTypes.TOGGLE end
function utils.isPanel(node) return node.type == urutora.nodeTypes.PANEL end
function utils.isMulti(node) return node.type == urutora.nodeTypes.MULTI_OPTION end
function utils.isButton(node) return node.type == urutora.nodeTypes.BUTTON end
function utils.isTextField(node) return node.type == urutora.nodeTypes.TEXT end
function utils.textWidth(t) return urutora.font:getWidth(t) end
function utils.textHeight() return urutora.font:getHeight() end

function utils.toRGB(hex)
  local hex = hex:gsub("#", "")

  local color = {
    tonumber("0x" .. hex:sub(1, 2)) / 255,
    tonumber("0x" .. hex:sub(3, 4)) / 255,
    tonumber("0x" .. hex:sub(5, 6)) / 255
  }

  return color
end

utils.colors = {
  BLACK = utils.toRGB('#000000'),
  WHITE = utils.toRGB('#ffffff'),
  GRAY = utils.toRGB('#666666'),
  DARK_GRAY = utils.toRGB('#333333'),
  LOVE_BLUE = utils.toRGB('#599ddc'),
  LOVE_BLUE_LIGHT = utils.toRGB('#63aff5'),
  RED = utils.toRGB('#ac3232'),
}

function utils.withOpacity(color, alpha)
  local newColor = { unpack(color) }
  table.insert(newColor, alpha)

  return newColor
end

function utils.needsBase(node)
  return not (
    utils.isToggle(node) or
    utils.isPanel(node) or
    utils.isLabel(node) or
    utils.isTextField(node)
  )
end

function p(text, x, y)
  love.graphics.print(
    text,
    math.floor(x),
    math.floor(y)
  )
end

function utils.getMouse()
  return love.mouse.getX() / urutora.sx, love.mouse.getY() / urutora.sy
end

function utils.getLayerColors(node)
  if not node.enabled then
    return colors.GRAY, colors.DARK_GRAY
  elseif node.pointed then
    return urutora.style.hoverBgColor, urutora.style.hoverFgColor
  end

  return urutora.style.bgColor, urutora.style.fgColor
end


function utils.drawBaseRectangle(node)
  local bgc, _ = utils.getLayerColors(node)
  love.graphics.setColor(node.bgColor or bgc)

  love.graphics.rectangle(node.baseMode or 'fill',
    math.floor(node.x),
    math.floor(node.y),
    math.floor(node.w),
    math.floor(node.h),
    (urutora.style.cornerRadius),
    (urutora.style.cornerRadius)
  )
end

function utils.drawText(node, alternativeText)
  local text = alternativeText or node.text

  if (not text) or (#text == 0) then
    return
  end

  local _, fgc = utils.getLayerColors(node)
  local x = node.x + node.w / 2 - utils.textWidth(text) / 2
  local y = node.y + node.h / 2 - utils.textHeight() / 2
  
  if node.textAlign == urutora.textAlignments.LEFT then
    x = math.floor(node.px)
  end

  love.graphics.setColor(node.fgColor or fgc)
  p(text, x, y)
end

function utils.setFocusedNode(node)
  for _, node in ipairs(urutora.nodes) do
    node.focused = false
  end

  if node then node.focused = true end
end

function utils.isPointInsideNode(x, y, node)
  if not (x or y) then return end

  x, y = x / urutora.sx, y / urutora.sy

  return not (
    x < node.x or
    x > (node.x + node.w) or
    y < node.y or
    y > (node.y + node.h)
  )
end

function utils.setBounds(node, x, y, w, h)
  local f = urutora.font
  node.padding = urutora.style.padding

  node.x = x
  node.y = y
  node.w = w or f:getWidth(node.text) + node.padding * 2
  node.h = h or f:getHeight() + node.padding * 2
  node.px = node.x + node.padding
  node.py = node.y + node.padding
end

function utils.initNode(node, data)
  node.text = data.text
  utils.setBounds(
    node,
    data.x or 1,
    data.y or 1,
    data.w or urutora.defaults.w,
    data.h
  )

  function node:setGroup(g)
    self.group = g

    if self.childrenReferences then
      for _, child in ipairs(self.childrenReferences) do
        child.group = g
      end
    end

    return self
  end

  function node:setEnabled(value)
    self.enabled = false
    return self
  end

  function node:setVisible(value)
    self.visible = false
    return self
  end

  function node:disable() self:setEnabled(false); return self end
  function node:enable() self:setEnabled(true); return self end

  function node:hide() self:setVisible(false); return self end
  function node:show() self:setVisible(true); return self end

  function node:action(f)
    self.callback = f
    return self
  end

  node.enabled = true
  node.visible = true
end

return function(u)
  urutora = u
  return utils
end
