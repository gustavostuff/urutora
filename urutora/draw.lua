local lg = love.graphics

local draw = {}

draw.EMPTY = {}
draw.CENTERED = { centered = true }
draw.defaultCurveSegments = 12
draw.DEFAULT_NODE_SIZE = 20

function draw.print(text, x, y)
  lg.print(text, math.floor(x), math.floor(y))
end

function draw.prettyPrint(text, x, y, data)
  data = data or draw.EMPTY
  lg.setColor(data.bgColor or { 0, 0, 0 })
  lg.print(text, math.floor(x - 1), math.floor(y + 1))
  lg.setColor(data.fgColor or { 1, 1, 1 })
  lg.print(text, math.floor(x), math.floor(y))
end

function draw.draw(texture, x, y, data)
  data = data or draw.EMPTY
  local ox = data.ox
  local oy = data.oy
  if ox == nil or oy == nil then
    if data.centered then
      ox = ox or (texture:getWidth() / 2)
      oy = oy or (texture:getHeight() / 2)
    else
      ox = ox or 0
      oy = oy or 0
    end
  end
  lg.draw(
    texture,
    math.floor(x),
    math.floor(y),
    math.rad(data.rotation or 0),
    data.scale or 1,
    data.scale or 1,
    math.floor(ox),
    math.floor(oy)
  )
end

function draw.rect(mode, x, y, w, h, rx, ry, segments)
  lg.rectangle(
    mode,
    math.floor(x),
    math.floor(y),
    math.floor(w),
    math.floor(h),
    rx, ry, segments
  )
end

function draw.line(a, b, c, d)
  lg.line(math.floor(a), math.floor(b), math.floor(c), math.floor(d))
end

function draw.circ(mode, x, y, r)
  lg.circle(mode, math.floor(x), math.floor(y), math.floor(r))
end

return draw
