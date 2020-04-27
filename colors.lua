local function toRGB(hex)
  local hex = hex:gsub("#", "")

  local color = {
    tonumber("0x" .. hex:sub(1, 2)) / 255,
    tonumber("0x" .. hex:sub(3, 4)) / 255,
    tonumber("0x" .. hex:sub(5, 6)) / 255
  }

  return color
end

colors = {
  BLACK = toRGB('#000000'),
  WHITE = toRGB('#ffffff'),
  GRAY = toRGB('#777777'),
  LOVE_BLUE = toRGB('#599ddc'),
  LOVE_BLUE_LIGHT = toRGB('#63aff5'),
  RED = toRGB('#ac3232'),
}

colors.withOpacity = function(color, alpha)
  local newColor = { unpack(color) }
  table.insert(newColor, alpha)

  return newColor
end

return colors
