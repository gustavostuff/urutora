local urutora = require('lib/urutora')
local u

-- todos:

-- fix slider movement inside scrolled panels
-- fix padding for panels
-- add modals for messages and questions (yes/no)
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
-- adjust scroll speed to the size of the panel

local bgColor = { 0.2, 0.1, 0.3 }
local canvas
local marco = love.graphics.newImage('img/marco.png')
local unnamed = love.graphics.newImage('img/unnamed.png')
local arrow = love.graphics.newImage('img/arrow.png')
local kitana = love.graphics.newImage('img/clickbait_kitana.png')
local bgs = {
  love.graphics.newImage('img/bg1.png'),
  love.graphics.newImage('img/bg2.png'),
  love.graphics.newImage('img/bg3.png')
}
for _, bg in ipairs(bgs) do bg:setFilter('nearest', 'nearest') end 
bgIndex = 1
bgRotation = 0

local function initStuff()
  u = urutora:new()
  canvas = love.graphics.newCanvas(320, 180)
  canvas:setFilter('nearest', 'nearest')
  sx = love.graphics.getWidth() / canvas:getWidth()
  sy = love.graphics.getHeight() / canvas:getHeight()
  font1 = love.graphics.newFont('fonts/proggy/proggy-tiny.ttf', 16)
  font2 = love.graphics.newFont('fonts/proggy/proggy-square-rr.ttf', 16)
  font3 = love.graphics.newFont('fonts/roboto/Roboto-Bold.ttf', 11)

  -- love.mouse.setRelativeMode(true)
  u.setDefaultFont(font1)
  u.setResolution(canvas:getWidth(), canvas:getHeight())
end

local function handleStyleChanges(evt)
  if evt.index == 1 then
    evt.target.parent.parent:setStyle({
      lineWidth = 1,
      lineStyle = 'rough',
      outline = false,
      cornerRadius = 0, -- percent
      bgColor = urutora.utils.colors.LOVE_BLUE,
      fgColor = urutora.utils.colors.WHITE,
      font = font1
    })
    u:getByTag('russian'):setStyle({ font = font2 })
  end
  if evt.index == 2 then
    evt.target.parent.parent:setStyle({
      outline = false,
      cornerRadius = 0.2, -- percent
      bgColor = {0, 0.2, 0.3, 0.5},
      fgColor = urutora.utils.colors.DARK_GRAY,
      disableFgColor = {.5, .5, .5},
      font = font3
    })
  end
  if evt.index == 3 then
    evt.target.parent.parent:setStyle({
      lineWidth = 2,
      lineStyle = 'smooth',
      cornerRadius = 0.5, -- percent
      outline = true,
      bgColor = {1, 0.6, 0},
      fgColor = {1, 0.6, 0},
      font = font3
    })
  end
end

local function initPanelC()

end

local function initPanelB()
  return u.panel({
    -- debug = true,
    rows = 10, cols = 2,
    tag = 'panelb',
    csy = 20
  })
  :colspanAt(1, 1, 2) -- panel label
  :colspanAt(4, 1, 0.25) -- vertical slider
  :rowspanAt(4, 1, 4) -- vertical slider
  :addAt(2, 1, u.multi({ items = { 'Style 1', 'Style 2', 'Style 3' } }):action(function(evt)
    bgIndex = bgIndex == 3 and 1 or bgIndex + 1
    handleStyleChanges(evt)
  end))
  :addAt(2, 2, u.toggle()
    :action(function (evt)
      evt.target.parent.debug = evt.value
    end))
  :addAt(3, 1, u.toggle()
    :action(function (evt)
      evt.target.parent.parent.debug = evt.value
    end))
  :addAt(3, 2, u.toggle():center())
  :addAt(1, 1, u.label({ text = 'Panel B (scroll)' }))
  :addAt(4, 1, u.slider({ axis = 'y' }))
  :addAt(4, 2, u.slider())
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
  :addAt(1, 2, u.label({ text = 'Panel A' }))
  :addAt(2, 1, u.label({ text = 'Button:' }):right())
  :addAt(2, 2, u.button({ text = 'Exit' })
    :setStyle({ bgColor = {0.7, 0.2, 0.2} })
    :action(function(evt)
      love.event.quit()
    end))
  :addAt(3, 1, u.label({ text = 'Slider:' }):right())
  :addAt(3, 2, u.slider({ value = 0.2 }))
  :addAt(4, 1, u.label({ text = 'Text field:' }):right())
  :addAt(4, 2, u.text({ text = 'привт', tag = 'russian' })
    :setStyle({ font = font2 }))
  :addAt(5, 1, u.label({ text = 'Multi:' }):right())
  :addAt(5, 2, u.multi({ index = 3, items = { 'One', 'Two', 'Three' } }))
  :addAt(6, 1, u.label({ text = 'Toggle:' }):right())
  :addAt(6, 2, u.toggle():right())
  :addAt(7, 1, u.label({ text = 'Diable B:' }):right())
  :addAt(7, 2, u.toggle({ value = true })
    :action(function(evt)
      if evt.value then
        anotherPanel:enable()
      else
        anotherPanel:disable()
      end
    end))
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
  local panelC = initPanelC()
  local panelB = initPanelB(panelC)
  local panelA = initPanelA(panelB)

  u:add(panelA)

  --activation and deactivation elements by tag
  --u:deactivateByTag('panela')
end

local x = 0
local y = 0

function love.update(dt)
  u:update(dt)
  bgRotation = bgRotation + dt * 10
  if bgRotation >= 360 then bgRotation = 0 end
end

local function drawBg()
  local bg = bgs[bgIndex]
  love.graphics.draw(bg,
    canvas:getWidth() / 2,
    canvas:getHeight() / 2,
    math.rad(bgRotation),
    canvas:getWidth() / bg:getWidth() * 3,
    canvas:getHeight() / bg:getHeight() * 3,
    bg:getWidth() / 2,
    bg:getHeight() / 2
  )
end

function drawCursor()
  if love.mouse.isDown(1) then
    love.graphics.setColor(1, 0, 0)
  end
  love.graphics.draw(arrow,
    math.floor(love.mouse.getX() / sx),
    math.floor(love.mouse.getY() / sy)
  )
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear(bgColor)
  love.graphics.setColor(1, 1, 1)
  drawBg()
  u:draw()
  drawCursor()
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
  if k == 'm' then
    love.mouse.setRelativeMode(not love.mouse.getRelativeMode())
  end
end
