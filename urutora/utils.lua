local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local lm = love.mouse

local types = require(modules .. 'types')
local styleModule = require(modules .. 'style')
local draw = require(modules .. 'draw')
local shaders = require(modules .. 'shaders')
local media = require(modules .. 'media')

local utils = {
  sx = 1,
  sy = 1,
  x = 0,
  y = 0,
  scrollSpeed = 0.1,
  defaultCurveSegments = draw.defaultCurveSegments,
  DEFAULT_NODE_SIZE = draw.DEFAULT_NODE_SIZE,
  EMPTY = draw.EMPTY,
  CENTERED = draw.CENTERED,
  nodeTypes = types.nodeTypes,
  alignments = types.alignments,
  mouseButtons = types.mouseButtons,
  colors = styleModule.colors,
  style = styleModule.style,
  darker = styleModule.darker,
  brighter = styleModule.brighter,
  withOpacity = styleModule.withOpacity,
  disabledImgShader = shaders.disabledImgShader,
  pointedImgShader = shaders.pointedImgShader,
  pressedImgShader = shaders.pressedImgShader,
  print = draw.print,
  prettyPrint = draw.prettyPrint,
  draw = draw.draw,
  rect = draw.rect,
  line = draw.line,
  circ = draw.circ,
  fitAndDrawMedia = media.fitAndDraw,
}

utils.isLabel = types.isLabel
utils.isPanel = types.isPanel
utils.isMulti = types.isMulti
utils.isImage = types.isImage
utils.isAnimation = types.isAnimation
utils.isToggle = types.isToggle
utils.isProgressBar = types.isProgressBar
utils.isSlider = types.isSlider
utils.isButton = types.isButton
utils.isTextField = types.isTextField
utils.isJoy = types.isJoy

function utils.getDefaultFont()
  if not utils.default_font then
    utils.default_font = lg.newFont(14)
    if not utils.style.padding then
      utils.style.padding = utils.default_font:getHeight() / 2
    end
  end
  return utils.default_font
end

function utils.textWidth(node)
  if not node.text then return 0 end
  local font = node.style.font or utils.getDefaultFont()
  if node._textW and node._cachedText == node.text and node._cachedFont == font then
    return node._textW
  end
  node._cachedText = node.text
  node._cachedFont = font
  node._textW = font:getWidth(tostring(node.text))
  return node._textW
end

function utils.textHeight(node)
  if not node.text then return 0 end
  local font = node.style.font or utils.getDefaultFont()
  if node._textH and node._cachedFontH == font then
    return node._textH
  end
  node._cachedFontH = font
  node._textH = font:getHeight()
  return node._textH
end

local formatCache = {}

function utils.toFixed(value, numberOfDecimals)
  if not value then return '<nil>' end
  local fmt = formatCache[numberOfDecimals]
  if not fmt then
    fmt = '%.' .. numberOfDecimals .. 'f'
    formatCache[numberOfDecimals] = fmt
  end
  return string.format(fmt, value)
end

function utils.needsBase(node)
  return not (
    utils.isAnimation(node) or
    utils.isPanel(node) or
    utils.isLabel(node) or
    utils.isTextField(node) or
    utils.isJoy(node) or
    utils.isImage(node) or
    utils.isProgressBar(node)
  )
end

function utils.split(input, sep)
  sep = sep or '%s'
  local t = {}
  for str in string.gmatch(input, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

function utils.drawWithShader(node, texture, x, y, data)
  lg.setColor(1, 1, 1)
  if not node.enabled then lg.setShader(utils.disabledImgShader) end
  if node.pointed then lg.setShader(utils.pointedImgShader) end
  if node.pressed then lg.setShader(utils.pressedImgShader) end

  utils.draw(texture, x, y, data or utils.CENTERED)

  lg.setShader()
end

function utils:getMouse()
  local x, y = lm.getPosition()
  x = (x - self.x) / self.sx
  y = (y - self.y) / self.sy
  return x, y
end

function utils.pointInsideRect(px, py, x, y, w, h)
  return not (
    px < x or
    px > (x + w) or
    py < y or
    py > (y + h)
  )
end

function utils.fixToggleBounds(node)
  -- toggles keep a 2:1 aspect ratio
  if node.type == utils.nodeTypes.TOGGLE then
    node.originalW = node.w
    node.w = node.h * 2
    if node.align == utils.alignments.RIGHT then
      node.x = node.x + node.originalW - node.w
    elseif node.align == utils.alignments.CENTER then
      node.x = node.x + node.originalW / 2 - node.w / 2
    end
  end
end

function utils.getLayers(node)
  return node.customLayers or (node.style and node.style.customLayers) or utils.EMPTY
end

return utils
