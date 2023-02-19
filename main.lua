_G.lg = love.graphics
_G.lm = love.mouse

local urutora = require('urutora')
local u
local styleManager = require('styleManager')

-- todos:

-- fix slider movement inside scrolled panels                - done
-- fix padding for panels                                    - done
-- add modals for messages and questions (yes/no)            
-- add scroll indicators (not sliders)                       - done
-- make images and animations gray when disabled             - done
-- link sliders to panel's scrolling
-- digital joystick (8-directional)                          - done
-- multitouch support
-- style hot swap                                            - done
-- blinking cursor in text fields and cursor displacement
-- disable/enable elements recursively                       - done
-- custom 'fixed' images for bgs and fgs


-- NOTES:

-- When using setStyle, all the previous styles is deleted first (reset to default)

local bgColor = { 0.2, 0.1, 0.3 }
for _, bg in ipairs(bgs) do bg:setFilter('nearest', 'nearest') end 
bgIndex = 1
bgRotation = 0

local function initCanvasStuff()
  w, h = 320 * 1, 180 * 1
  canvas = lg.newCanvas(w, h)
  canvas:setFilter('nearest', 'nearest')
  canvasX, canvasY = 0, 0
  sx = lg.getWidth() / canvas:getWidth()
  sy = lg.getHeight() / canvas:getHeight()
end

local function doResizeStuff(w, h)
  sx = math.floor(w / canvas:getWidth())
  sx = sx < 1 and 1 or sx
  sy = sx

  if (canvas:getHeight() * sy) > h then
    sy = math.floor(h / canvas:getHeight())
    sy = sy < 1 and 1 or sy
    sx = sy
  end

  canvasX = w / 2 - (canvas:getWidth() / 2) * sx
  canvasY = h / 2 - (canvas:getHeight() / 2) * sy

  u.setDimensions(canvasX, canvasY, sx, sy)
end

local function initFontStuff()
  font1 = lg.newFont('fonts/proggy/proggy-tiny.ttf', 16)
  font2 = lg.newFont('fonts/proggy/proggy-square-rr.ttf', 16)
  font3 = lg.newFont('fonts/roboto/Roboto-Bold.ttf', 11)
  font1:setFilter('nearest', 'nearest')
  font2:setFilter('nearest', 'nearest')
  u.setDefaultFont(font1)
  doResizeStuff(lg.getDimensions())
end

local function initStuff()
  u = urutora:new()

  initCanvasStuff()
  initFontStuff()
  transparentCursorImg = love.image.newImageData(1, 1)
  lm.setCursor(lm.newCursor(transparentCursorImg))
  -- lm.setRelativeMode(true)
end

local function initPanelC()
  local panelC = u.panel({
    -- debug = true,
    rows = 8, cols = 1,
    verticalScale = 2,
    tag = 'panelc',
    -- bgColor = {0, 1, 0, 0.3},
    -- move 1/16 of the vewport for every mousewheel event
    -- this is relative to the number of rows within the panel
    scrollSpeed = 1/16 -- 16 wheel steps to fully scroll
  })

  local function toggleDebug(evt)
    evt.target.parent.debug = not evt.target.parent.debug
  end
  for i = 1, panelC.rows do
    panelC:addAt(i, 1, u.button({ text = 'Button ' .. i }):action(toggleDebug))
  end
  return panelC
end

local function initPanelB(anotherPanel)
  return u.panel({
    -- debug = true,
    rows = 10, cols = 2,
    verticalScale = 2,
    tag = 'panelb',
    -- bgColor = {1, 0, 0, 0.3},
    scrollSpeed = 1/10 -- 10 wheel steps to fully scroll
  })
  :colspanAt(1, 1, 2) -- panel label
  :colspanAt(6, 2, 0.2) -- vertical slider
  :rowspanAt(6, 2, 4) -- vertical slider
  :rowspanAt(6, 1, 4) -- panel C
  :addAt(2, 1, u.multi({ items = { 'Blue', 'Olive', 'Neon' } })
    :action(function(evt)
      bgIndex = bgIndex == 3 and 1 or bgIndex + 1
      styleManager.handleStyleChanges(u, evt, font1, font2, font3)
    end))
  :addAt(2, 2, u.toggle()
    :action(function (evt)
      evt.target.parent.debug = evt.value
    end))
  :addAt(3, 1, u.toggle())
  :addAt(3, 2, u.toggle():center())
  :addAt(1, 1, u.label({ text = 'Panel B (scroll)' }))
  :addAt(6, 2, u.slider({ axis = 'y' }))
  :addAt(4, 2, u.label({ text = 'joyX: 0', tag = 'xLabel' }):left())
  :addAt(5, 2, u.label({ text = 'joyY: 0', tag = 'yLabel' }):left())
  :addAt(4, 1, u.label({ text = '', tag = 'directionLabel' }))
  :addAt(5, 1, u.label({ text = '', tag = 'lastCoordLabel' }))
  :addAt(6, 1, anotherPanel)
end

local function initPanelA(anotherPanel)
  -- rowspanAt(row, col) 1-base indexed
  -- addAt(row, col) 1-base indexed
  return u.panel({
    -- debug = true,
    rows = 9, cols = 4,
    w = w, h = h,
    tag = 'panela'
  })
  :rowspanAt(8, 2, 2) -- 2 rows for the joystick
  :rowspanAt(2, 3, 2) -- love2d logo
  :rowspanAt(2, 4, 2) -- Animation
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
  :addAt(3, 2, u.slider({ value = 0.2, tag = 'slider1' }))
  :addAt(4, 1, u.label({ text = 'Text field:' }):right())
  :addAt(4, 2, u.text({ text = 'привт', tag = 'russian' })
    :setStyle({ font = font2 }))
  :addAt(5, 1, u.label({ text = 'Multi:' }):right())
  :addAt(5, 2, u.multi({ index = 3, items = { 'One', 'Two', 'Three' }, tag = 'multi1' }))
  :addAt(6, 1, u.label({ text = 'Toggle:' }):right())
  :addAt(6, 2, u.toggle():right()
  :action(function (evt)
    evt.target.parent.debug = not evt.target.parent.debug
  end))
  :addAt(7, 1, u.label({ text = 'Prog. bar:' }):right())
  :addAt(7, 2, u.progressBar({ speed = 0.25, value = 0.4, direction = -1 }):action(function (evt)
    if evt.type == 'full' then
      evt.target.direction = evt.target.direction * -1 
    elseif evt.type == 'empty' then
      evt.target.direction = evt.target.direction * -1
    end
  end))
  :addAt(8, 1, u.label({ text = 'Joystick:' }):right())
  :addAt(8, 2, u.joy({
    layer1 = joyLayer1,
    layer2 = joyLayer2,
    layer3 = joyLayer3,
    activateOn = 0.7, -- percent
    tag = 'joy'
  }):action(function(evt)
    local directionLabel = u:getByTag('directionLabel')
    local lastCoordLabel = u:getByTag('lastCoordLabel')
    local xLabel = u:getByTag('xLabel')
    local yLabel = u:getByTag('yLabel')

    if evt.type == 'moved' then
      local x, y = u.utils.toFixed(evt.value.x, 2), u.utils.toFixed(evt.value.y, 2)
      xLabel.text = 'joyX: ' .. x
      yLabel.text = 'joyY: ' .. y
      directionLabel.text = evt.value.direction
    elseif evt.type == 'released' then
      local lx = u.utils.toFixed(evt.value.lastX, 2)
      local ly = u.utils.toFixed(evt.value.lastY, 2)

      xLabel.text = 'joyX: 0'
      yLabel.text = 'joyY: 0'
      directionLabel.text = ''
      lastCoordLabel.text = lx .. ', ' .. ly
    end
  end))

  :addAt(1, 3, u.label({ text = 'Image:' }))
  :addAt(1, 4, u.label({ text = 'Animation:' }))
  :addAt(2, 3, u.image({ image = logo })
    :action(function(evt)
      evt.target.keepAspectRatio = not evt.target.keepAspectRatio
    end))
  :addAt(2, 4, u.animation({
      image = anim,
      frameWidth = 80,
      frameHeight = 70,
      frameDelay = 0.05
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
  panelA = initPanelA(panelB)

  u:add(panelA)
  panelA:setStyle({
    hoverBgColor = u.utils.colors.LOVE_PINK
  })
  u:getByTag('russian'):setStyle({ font = font2 })

  --activation and deactivation elements by tag
  --u:deactivateByTag('panela')
end

local x = 0
local y = 0

function love.update(dt)
  u:update(dt)
  bgRotation = bgRotation + dt * 5
  if bgRotation >= 360 then bgRotation = 0 end
end

local function drawBg()
  local bg = bgs[bgIndex]
  lg.draw(bg,
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
  if lm.isDown(1) then
    lg.setColor(1, 0, 0)
  end
  local x, y = u.utils:getMouse()
  lg.draw(arrow, math.floor(x), math.floor(y))
end

function love.draw()
  lg.setCanvas({ canvas, stencil = true })
  lg.clear(bgColor)
  lg.setColor(1, 1, 1)
  drawBg() -- spinning squares
  u:draw()
  drawCursor()
  lg.setColor(1, 1, 1)
  lg.setCanvas()

  lg.draw(canvas, math.floor(canvasX), math.floor(canvasY), 0, sx, sy)
  lg.print('FPS: ' .. love.timer.getFPS())
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
    lm.setRelativeMode(not lm.getRelativeMode())
  end
  if k == 'f9' then
    if not panelA.enabled then
      panelA:enable()
    else
      panelA:disable()
    end
  end
end

function love.resize(w, h)
  doResizeStuff(w, h)
end
