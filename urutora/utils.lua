local utils = {
  default_font = lg.newFont(14),
  nodeTypes = {
    LABEL 	= 1,
    BUTTON 	= 2,
    SLIDER 	= 3,
    TOGGLE 	= 4,
    TEXT 	  = 5,
    MULTI 	= 6,
    PANEL 	= 7,
    JOY 	  = 8,
    IMAGE   = 9,
    ANIMATION = 10,
    PROGRESS_BAR = 11
  },
  alignments = {
    LEFT	= 'left',
    CENTER 	= 'center',
    RIGHT 	= 'right'
  },
  mouseButtons = {
    LEFT = 1,
    RIGHT = 2
  },
  sx = 1,
  sy = 1,
  scrollSpeed = 0.1,
  defaultCurveSegments = 100
}

function utils.isLabel(node)       return node.type == utils.nodeTypes.LABEL end
function utils.isPanel(node)       return node.type == utils.nodeTypes.PANEL end
function utils.isMulti(node)       return node.type == utils.nodeTypes.MULTI_OPTION end
function utils.isImage(node)       return node.type == utils.nodeTypes.IMAGE end
function utils.isAnimation(node)   return node.type == utils.nodeTypes.ANIMATION end
function utils.isToggle(node)      return node.type == utils.nodeTypes.TOGGLE end
function utils.isProgressBar(node) return node.type == utils.nodeTypes.PROGRESS_BAR end
function utils.isSlider(node)      return node.type == utils.nodeTypes.SLIDER end
function utils.isButton(node)      return node.type == utils.nodeTypes.BUTTON end
function utils.isTextField(node)   return node.type == utils.nodeTypes.TEXT end
function utils.isJoy(node)         return node.type == utils.nodeTypes.JOY end

function utils.textWidth(node)
  if not node.text then return 0 end
  local font = node.style.font or utils.default_font
  return font:getWidth(tostring(node.text))
end

function utils.textHeight(node)
  if not node.text then return 0 end
  local font = node.style.font or utils.default_font
  return font:getHeight()
end

function utils.darker(color, amount)
  amount = 1 - (amount or 0.2)
  local r, g, b = color[1], color[2], color[3]
  r = r * amount
  g = g * amount
  b = b * amount

  return { r, g, b, color[4] }
end

function utils.brighter(color, amount)
  amount = amount or 0.2
  local r, g, b = color[1], color[2], color[3]
  r = r + ((1 - r) * amount)
  g = g + ((1 - g) * amount)
  b = b + ((1 - b) * amount)

  return { r, g, b, color[4] }
end

utils.colors = {
  BLACK           = { love.math.colorFromBytes(0, 0, 0) },
  WHITE           = { love.math.colorFromBytes(255, 255, 255) },
  GRAY            = { love.math.colorFromBytes(78, 74, 78) },
  DARK_GRAY       = { love.math.colorFromBytes(20, 12, 28) },
  LOVE_BLUE       = { love.math.colorFromBytes(39, 170, 225) },
  LOVE_BLUE_LIGHT = { love.math.colorFromBytes(87, 183, 225) },
  LOVE_PINK        = { love.math.colorFromBytes(231, 74, 153) },
  RED             = { love.math.colorFromBytes(208, 70, 72) },
}

utils.style = {
  padding = utils.default_font:getHeight() / 2,
  bgColor = utils.colors.LOVE_BLUE,
  fgColor = utils.colors.WHITE,
  lineStyle = 'rough',
  lineWidth = 1,
  disableBgColor = {0.5, 0.5, 0.5, 0.5},
  disableFgColor = {0.35, 0.35, 0.35},
}

function utils.toFixed(value, numberOfDecimals)
  if not value then return '<nil>' end
  return string.format('%.' .. numberOfDecimals .. 'f', value)
end

function utils.withOpacity(color, alpha)
  return { color[1], color[2], color[3], alpha or 1 }
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

utils.split = function (input, sep)
  if not sep then
    sep = '%s'
  end

  local t = {}
  for str in string.gmatch(input, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

function utils.print(text, x, y, data)
  lg.print(text, math.floor(x), math.floor(y))
end

function utils.prettyPrint(text, x, y, data)
  data = data or {}
  lg.setColor(data.bgColor or {0, 0, 0})
  lg.print(text, math.floor(x - 1), math.floor(y + 1))
  lg.setColor(data.fgColor or {1, 1, 1})
  lg.print(text, math.floor(x), math.floor(y))
end

function utils.draw(texture, x, y, data)
  data = data or {}
  lg.draw(texture,
    math.floor(x),
    math.floor(y),
    math.rad(data.rotation or 0),
    data.scale or 1,
    data.scale or 1,
    math.floor(data.centered and (texture:getWidth() / 2) or 0),
    math.floor(data.centered and (texture:getHeight() / 2) or 0)
  )
end

function utils.drawWithShader(node, texture, x, y, data)
  lg.setColor(1, 1, 1)
  if not node.enabled then lg.setShader(utils.disabledImgShader) end
  if node.pointed then lg.setShader(utils.pointedImgShader) end
  if node.pressed then lg.setShader(utils.pressedImgShader) end

  utils.draw(texture, x, y, data, {centered = true})

  lg.setShader()
end

function utils.rect(mode, x, y, w, h, rx, ry, segments)
  lg.rectangle(mode,
    math.floor(x),
    math.floor(y),
    math.floor(w),
    math.floor(h),
    rx, ry, segments
  )
end

function utils.line(a, b, c, d)
  lg.line(math.floor(a), math.floor(b), math.floor(c), math.floor(d))
end

function utils.circ(mode, x, y, r)
  lg.circle(mode, math.floor(x), math.floor(y), math.floor(r))
end

function utils:getMouse()
  local x, y = lm.getPosition()
  x = (x - self.x) / self.sx
  y = (y - self.y) / self.sy

  return x, y
end

function utils.pointInsideRect(px, py, x, y, w, h)
  return not (
    px < (x) or
    px > (x + w) or
    py < (y) or
    py > (y + h)
  )
end

function utils.fixToggleBounds(node)
  -- toggles have always the same aspect ratio (2:1)
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

utils.disabledImgShader = lg.newShader([[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    number average = (pixel.r + pixel.b + pixel.g) / 3.0;
    pixel.r = average * 0.4;
    pixel.g = average * 0.4;
    pixel.b = average * 0.4;
    return pixel;
  }
]])

utils.pointedImgShader = lg.newShader([[
  float brightness = 0.1;
  float contrast = 1.2;

  vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec4 pixel = Texel(tex, tex_coords);
      
      // Increase brightness
      pixel.rgb += brightness;
      
      // Increase contrast
      pixel.rgb = (pixel.rgb - 0.5) * contrast + 0.5;

      return pixel * color;
  }
]])

utils.pressedImgShader = lg.newShader([[
  float brightness = 0.1;
  float contrast = 1.1;

  vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec4 pixel = Texel(tex, tex_coords);
      
      // Decrease brightness
      pixel.rgb -= brightness;
      
      // Decrease contrast
      pixel.rgb = (pixel.rgb - 0.5) / contrast + 0.5;

      return pixel * color;
  }
]])

return utils
