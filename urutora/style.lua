local styleModule = {}

styleModule.colors = {
  BLACK           = { love.math.colorFromBytes(0, 0, 0) },
  WHITE           = { love.math.colorFromBytes(255, 255, 255) },
  GRAY            = { love.math.colorFromBytes(78, 74, 78) },
  DARK_GRAY       = { love.math.colorFromBytes(20, 12, 28) },
  LOVE_BLUE       = { love.math.colorFromBytes(39, 170, 225) },
  LOVE_BLUE_LIGHT = { love.math.colorFromBytes(87, 183, 225) },
  LOVE_PINK       = { love.math.colorFromBytes(231, 74, 153) },
  RED             = { love.math.colorFromBytes(208, 70, 72) },
}

styleModule.COLOR_DELTA = 0.2

styleModule.style = {
  bgColor = styleModule.colors.LOVE_BLUE,
  fgColor = styleModule.colors.WHITE,
  lineStyle = 'rough',
  lineWidth = 1,
  disableBgColor = { 0.5, 0.5, 0.5, 0.5 },
  disableFgColor = { 0.35, 0.35, 0.35 },
}

function styleModule.darker(color, amount)
  amount = 1 - (amount or styleModule.COLOR_DELTA)
  local r, g, b = color[1], color[2], color[3]
  return { r * amount, g * amount, b * amount, color[4] }
end

function styleModule.brighter(color, amount)
  amount = amount or styleModule.COLOR_DELTA
  local r, g, b = color[1], color[2], color[3]
  return {
    r + ((1 - r) * amount),
    g + ((1 - g) * amount),
    b + ((1 - b) * amount),
    color[4]
  }
end

local opacityScratch = { 0, 0, 0, 1 }

-- Returns a shared scratch table; do not store the result across calls.
function styleModule.withOpacity(color, alpha)
  opacityScratch[1] = color[1]
  opacityScratch[2] = color[2]
  opacityScratch[3] = color[3]
  opacityScratch[4] = alpha or 1
  return opacityScratch
end

return styleModule
