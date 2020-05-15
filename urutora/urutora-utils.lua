local utils = {}

function utils.isLabel(node) return node.type == urutora.nodeTypes.LABEL end
function utils.isToggle(node) return node.type == urutora.nodeTypes.TOGGLE end
function utils.isPanel(node) return node.type == urutora.nodeTypes.PANEL end
function utils.isMulti(node) return node.type == urutora.nodeTypes.MULTI_OPTION end
function utils.isButton(node) return node.type == urutora.nodeTypes.BUTTON end
function utils.isTextField(node) return node.type == urutora.nodeTypes.TEXT end
function utils.isJoy(node) return node.type == urutora.nodeTypes.JOY end
function utils.textWidth(node)
  if not node.text then return 0 end
  return node.font:getWidth(node.text)
end
function utils.textHeight(node)
  if not node.text then return 0 end
  return node.font:getHeight()
end

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

function utils.brighter(color, amount)
  amount = amount or 0.2
  local r, g, b = color[1], color[2], color[3]
  r = r + ((1 - r) * amount)
  g = g + ((1 - g) * amount)
  b = b + ((1 - b) * amount)

  return { r, g, b, color[4] }
end

--------------------------------------------------------------

function utils.getCommons(nodeType, data)
  data = data or {}
  local node = {}
  node.callback = urutora.defaults.cb
  node.type = nodeType
  node.textAlign = data.textAlign or urutora.textAlignments.CENTER

  node.text = data.text
  utils.setBounds(
    node,
    data.x or 1,
    data.y or 1,
    data.w or urutora.defaults.w,
    data.h
  )

  node.bgColor, node.fgColor = urutora.style.bgColor, urutora.style.fgColor
  node.font = urutora.font

  function node:setGroup(g)
    self.group = g

    if self.children then
      for _, child in ipairs(self.children) do
        child.group = g
      end
    end

    return self
  end

  function node:setStyle(style)
    self.bgColor = style.bgColor or urutora.style.bgColor
    self.fgColor = style.fgColor or urutora.style.fgColor
    self.font = style.font or urutora.font

    if self.children then
      for _, child in ipairs(self.children) do
        child:setStyle(style)
      end
    end

    return self
  end

  function node:setEnabled(value)
    self.enabled = value

    if self.children then
      for _, child in ipairs(self.children) do
        child.enabled = value
      end
    end

    return self
  end

  function node:setVisible(value)
    self.visible = value

    if self.children then
      for _, child in ipairs(self.children) do
        child.visible = value
      end
    end

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

  function node:left() self.textAlign = urutora.textAlignments.LEFT; return self end
  function node:center() self.textAlign = urutora.textAlignments.CENTER; return self end
  function node:right() self.textAlign = urutora.textAlignments.RIGHT; return self end

  node.enabled = true
  node.visible = true

  return node, data
end

function utils.needsBase(node)
  return not (
    utils.isToggle(node) or
    utils.isPanel(node) or
    utils.isLabel(node) or
    utils.isTextField(node) or
    utils.isJoy(node)
  )
end

function utils.p(text, x, y)
  love.graphics.print(
    text,
    math.floor(x),
    math.floor(y)
  )
end

function utils.rect(mode, a, b, c, d)
  love.graphics.rectangle(mode, math.floor(a), math.floor(b), math.floor(c), math.floor(d))
end

function utils.line(a, b, c, d)
  love.graphics.line(math.floor(a), math.floor(b), math.floor(c), math.floor(d))
end

function utils.circ(mode, a, b, c)
  love.graphics.circle(mode, math.floor(a), math.floor(b), math.floor(c))
end

function utils.getLayerColors(node)
  if not node.enabled then
    return utils.colors.GRAY, utils.colors.DARK_GRAY
  else
    if node.pointed then
      return utils.brighter(node.bgColor), node.fgColor
    else
      return node.bgColor, node.fgColor
    end
  end
end

function utils.drawBaseRectangle(node, color, ...)
  local bgc, _ = utils.getLayerColors(node)
  love.graphics.setColor(color or bgc)
  local x, y, w, h = node.x, node.y, node.w, node.h

  if ... then x, y, w, h = ... end
  utils.rect('fill', x, y, w, h)
end

function utils.drawText(node, extra)
  local text = node.text

  if (not text) or (#text == 0) then
    return
  end

  local _, fgc = utils.getLayerColors(node)
  local x = node:centerX() - utils.textWidth(node) / 2
  local y = node:centerY() - utils.textHeight(node) / 2
  if node.type == urutora.nodeTypes.TEXT then
    x = math.floor(node.x)
  elseif node.textAlign == urutora.textAlignments.LEFT then
    x = math.floor(node.px)
  elseif node.textAlign == urutora.textAlignments.RIGHT then
    x = math.floor(node.px + node.npw - utils.textWidth(node))
  end

  love.graphics.setFont(node.font)
  love.graphics.setColor(fgc)
  utils.p(text, x, y)
end

function utils.setFocusedNode(node)
  for _, node in ipairs(urutora.nodes) do
    node.focused = false
  end

  if node then node.focused = true end
end

function utils.getMouse()
  return love.mouse.getX() / urutora.sx, love.mouse.getY() / urutora.sy
end

function utils.isPointInsideNode(x, y, node)
  if not (x or y) then return end
  x, y = utils.getMouse()

  return not (
    x < node.x or
    x > (node.x + node.w) or
    y < node.y or
    y > (node.y + node.h)
  )
end

function utils.setBounds(node, x, y, w, h)
  local f = urutora.font
  node.p = urutora.style.p -- padding

  node.x = x
  node.y = y
  node.w = w or f:getWidth(node.text) + node.p * 2
  node.h = h or f:getHeight() + node.p * 2
  node.px = node.x + node.p
  node.py = node.y + node.p
  function node:centerX() return self.x + self.w / 2 end
  function node:centerY() return self.y + self.h / 2 end
  node.npw = node.w - node.p * 2
  node.nph = node.h - node.p * 2
end

return function(u)
  urutora = u
  return utils
end
