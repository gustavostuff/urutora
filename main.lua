local urutora = require('lib/urutora')
local u

-- todos:

-- fix padding for panels
-- add scroll indicators (not sliders)
-- make images and animations gray when disabled             - done
-- link sliders to panel's scrolling
-- digital joystick (8-directional)
-- multitouch support
-- style hot swap
-- blinking cursor in text fields and cursor displacement
-- disable/enable elements recursively                       - done
-- change naming of some methods (addAt, colspanAt, etc)
-- custom images for buttons (background and label icons)
-- custom images for sliders

local bgColor = { 0.2, 0.1, 0.3 }
local canvas
local marco = love.graphics.newImage('img/marco.png')
local unnamed = love.graphics.newImage('img/unnamed.png')
local arrow = love.graphics.newImage('img/arrow.png')
local kitana = love.graphics.newImage('img/clickbait_kitana.png')

local function initStuff()
  u = urutora:new()
  canvas = love.graphics.newCanvas(320, 180)
  canvas:setFilter('nearest', 'nearest')
  sx = love.graphics.getWidth() / canvas:getWidth()
  sy = love.graphics.getHeight() / canvas:getHeight()
  local font1 = love.graphics.newFont('fonts/proggy/proggy-tiny.ttf', 16)
  font2 = love.graphics.newFont('fonts/proggy/proggy-square-rr.ttf', 16)

  love.mouse.setRelativeMode(true)
  u.setDefaultFont(font1)
  u.setResolution(canvas:getWidth(), canvas:getHeight())
end

local function initPanelB()
  return u.panel({
    debug = true,
    rows = 10, cols = 2,
    tag = 'panelb',
    csy = 20
  })
  :colspanAt(1, 1, 2)
  :addAt(1, 1, u.label({ text = 'Panel B - scroll' }))
  :addAt(2, 1, u.multi({ items = { 'Style 1', 'Style 2', 'Style 3' } }))
  :addAt(2, 2, u.button({ text = 'Button' }))
end

local function initPanelA(anotherPanel)
  -- rowspanAt(row, col) 1-base indexed
  -- addAt(row, col) 1-base indexed
  return u.panel({
    -- debug = true,
    rows = 9, cols = 4,
    w = 320, h = 180,
    tag = 'panela'
  })
  :spacingAt(5, 3, 0)
  :rowspanAt(8, 2, 2) -- 2 rows for the joystick
  :rowspanAt(2, 3, 2) -- love2d logo
  :rowspanAt(2, 4, 2) -- Kitana
  :colspanAt(4, 3, 2) -- Click label
  :colspanAt(5, 3, 2) -- panel B
  :rowspanAt(5, 3, 5) -- panel B
  :addAt(1, 1, u.label({ text = 'Label:' }):right())
  :addAt(1, 2, u.label({ text = 'Panel B' }))
  :addAt(2, 1, u.label({ text = 'Button:' }):right())
  :addAt(2, 2, u.button({ text = 'Exit' })
    :setStyle({ bgColor = {0.7, 0.2, 0.2} })
    :action(function(evt)
      love.event.quit()
    end))
  :addAt(3, 1, u.label({ text = 'Slider:' }):right())
  :addAt(3, 2, u.slider({ value = 0.2 }))
  :addAt(4, 1, u.label({ text = 'Text field:' }):right())
  :addAt(4, 2, u.text({ text = 'привт' })
    :setStyle({ font = font2 }))
  :addAt(5, 1, u.label({ text = 'Multi:' }):right())
  :addAt(5, 2, u.multi({ index = 3, items = { 'One', 'Two', 'Three' } }))
  :addAt(6, 1, u.label({ text = 'Toggle:' }):right())
  :addAt(6, 2, u.toggle():right())
  :addAt(7, 1, u.label({ text = 'Toggle:' }):right())
  :addAt(7, 2, u.toggle({ value = true }))
  :addAt(8, 1, u.label({ text = 'Joystick:' }):right())
  :addAt(8, 2, u.joy({ image = love.graphics.newImage('img/ball.png') }))

  :addAt(1, 3, u.label({ text = 'Image:' }))
  :addAt(1, 4, u.label({ text = 'Animation:' }))
  :addAt(2, 3, u.image({ image = unnamed })
    :action(function(evt)
      evt.target.keepAspectRatio = not evt.target.keepAspectRatio
    end))
  :addAt(2, 4, u.animation({
      image = kitana,
      frames = 21,
      frameWidth = 80,
      frameHeight = 60,
      frameDelay = 0.2
    })
    :action(function(evt)
      evt.target.keepOriginalSize = not evt.target.keepOriginalSize
    end))
  :addAt(4, 3, u.label({ text = 'Click on the images^' }))
  :addAt(5, 3, anotherPanel)
end

function love.load()
  initStuff()
  local panelB = initPanelB()
  local panelA = initPanelA(panelB)

  u:add(panelA)

  --activation and deactivation elements by tag
  --u:deactivateByTag('panela')
end

local x = 0
local y = 0

function love.update(dt)
  u:update(dt)
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear(bgColor)
  love.graphics.setColor(1, 1, 1)
  u:draw()
  if love.mouse.isDown(1) then
    love.graphics.setColor(1, 0, 0)
  end
  love.graphics.draw(arrow,
    math.floor(love.mouse.getX() / sx),
    math.floor(love.mouse.getY() / sy)
  )
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, 0, 0, 0, sx, sy)
  love.graphics.print('FPS: ' .. love.timer.getFPS())
end

function love.mousepressed(x, y, button) u:pressed(x, y, button) end
function love.mousemoved(x, y, dx, dy) u:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) u:released(x, y) end
function love.textinput(text) u:textinput(text) end
function love.wheelmoved(x, y) u:wheelmoved(x, y) end

function love.keypressed(k, scancode, isrepeat)
  u:keypressed(k, scancode, isrepeat)

  if k == 'escape' then
    love.event.quit()
  end
  if k == 'space' then
    panelA:enable()
    enableAToggle:change()
    enableAToggle.callback({ target = enableAToggle, value = enableAToggle.value })
  end
  if k == 'm' then
    love.mouse.setRelativeMode(not love.mouse.getRelativeMode())
  end
end
