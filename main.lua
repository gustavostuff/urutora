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
local panelA, panelB, panelC, panelD
local marco = love.graphics.newImage('img/marco.png')
local kitana = love.graphics.newImage('img/unnamed.png')
local arrow = love.graphics.newImage('img/arrow.png')

local function initStuff()
  u = urutora:new()
	canvas = love.graphics.newCanvas(320, 180)
	canvas:setFilter('nearest', 'nearest')
  sx = love.graphics.getWidth() / canvas:getWidth()
	sy = love.graphics.getHeight() / canvas:getHeight()
	local font1 = love.graphics.newFont('fonts/proggy/proggy-tiny.ttf', 16)
	font2 = love.graphics.newFont('fonts/proggy/proggy-square-rr.ttf', 16)

	u.setDefaultFont(font1)
	u.setResolution(canvas:getWidth(), canvas:getHeight())

  marcoAnimation = u.animation({
    image = marco,
    frames = 6,
    frameWidth = 39,
    frameHeight = 39,
    frameDelay = 0.04,
    keepOriginalSize = true
  })
end

local function initPanelC()
  panelC = u.panel({ bgColor = {1, 0, 0, 0.3}, rows = 20, cols = 6, csy = 18, tag = 'PanelC'})
	panelC
		:colspanAt(1, 1, 6)
	for i = 1, 20 do
		panelC
			:colspanAt(i, 1, 3)
			:colspanAt(i, 4, 3)
			:addAt(i, 1, u.label({ text = tostring(i) }))
			:addAt(i, 4, u.button({ text = 'Btn' }))
	end
end

local function initPanelD()
  kitanaImage = u.image({
    image = kitana,
    keepOriginalSize = true,
    keepAspectRatio = true
  })
  panelD = u.panel({ bgColor = {0, 1, 0, 0.3}, rows = 4, cols = 2, tag = 'PanelD' })
	panelD
		:colspanAt(3, 1, 2)
		:rowspanAt(3, 1, 2)
		:addAt(1, 1, u.toggle({ text = 'K.A.R.', value = true }):action(function()
      kitanaImage.keepAspectRatio = not kitanaImage.keepAspectRatio
    end))
		:addAt(1, 2, u.toggle({ text = 'K.O.S.', value = true }):action(function()
      kitanaImage.keepOriginalSize = not kitanaImage.keepOriginalSize
    end))
		:addAt(2, 1, u.slider())
		:addAt(3, 1, kitanaImage):action(function (e)
      e.target.keepAspectRatio = not e.target.keepAspectRatio
    end)
end

local function initPanelB()
  panelB = u.panel({
    -- debug = true,
    bgColor = {1, 0.6, 0.8, 0.4}, rows = 5, cols = 2,
    tag = 'PanelB', csy = 28
  })
	panelB
    :rowspanAt(5, 1, 3)
    :rowspanAt(5, 2, 3)
    :rowspanAt(1, 2, 3)
		:addAt(1, 1, u.label({ text = 'Panel B' }))
    :addAt(1, 2, marcoAnimation)
    :addAt(4, 1, u.label({ text = 'Panel C'}):center())
		:addAt(4, 2, u.label({ text = 'Panel D'}))
    :addAt(2, 1, u.label({ text = 'click ->' }))
		:addAt(5, 1, panelC)
		:addAt(5, 2, panelD)
end

local function initPanelA()
  enableAToggle = u.toggle({ text = 'A enabled', value = true }):action(function (e)
    if e.target.value then
      e.target.text = 'A enabled'
      panelA:enable()
    else
      e.target.text = 'Hit space'
      panelA:disable()
    end
  end)

  panelA = u.panel({
    -- debug = true,
    rows = 9, cols = 4, x = 0, y = 0, w = 320, h = 180, tag = 'PanelA'
  }):rowspanAt(2, 4, 5) -- giant slider
    :colspanAt(2, 4, 0.25) -- giant slider
		:colspanAt(3, 1, 3) -- panel B
		:rowspanAt(3, 1, 4) -- panel B
    :rowspanAt(7, 3, 2) -- joystick
		:addAt(1, 1, u.label({ text = 'Panel A' }))
		:addAt(1, 2, u.toggle({ text = 'Slider ->' }):action(function (e)
			local slider = panelA:getChildren(1, 3)
			if e.target.value then
				slider:enable()
			else
				slider:disable()
			end
		end))
    :addAt(1, 4, u.button({ text = 'Next >' }))
		:addAt(1, 3, u.slider({ value = 0.3, tag = 'slider', axis = 'x'  }):disable())
		:addAt(2, 3, u.toggle({ value = false, text = 'Boolean' }))
		:addAt(2, 2, u.text({ text = 'привт' }):setStyle({ font = font2 }))
		:addAt(3, 1, panelB)
    :addAt(7, 1, u.toggle({ text = 'D enabled', value = true }):action(function (e)
			if e.target.value then
				e.target.text = 'D enabled'
				panelD:enable()
			else
				e.target.text = 'D disabled'
				panelD:disable()
			end
		end))
		:addAt(8, 1, u.toggle({ text = 'D visible', value = true }):action(function (e)
			if e.target.value then
				e.target.text = 'D visible'
				panelD:show()
			else
				e.target.text = 'D hidden'
				panelD:hide()
			end
		end))
    :addAt(9, 1, u.button({ text = 'K.O.S' }):action(function()
      marcoAnimation.keepOriginalSize = not marcoAnimation.keepOriginalSize
    end))
    :addAt(10, 1, u.button({ text = 'Exit' })
      :setStyle({ bgColor = {0.6, 0.1, 0} })
      :action(function()
        love.event.quit()
      end))
		:addAt(2, 1, u.multi({ items = { 'One', 'Two', 'Three' } }):left())
    :addAt(2, 4, u.slider({
      x = 310,
      y = 20,
      w = 2,
      h = 78,
      value = 0.3,
      tag = 'slider',
      axis = 'y'
    }))
    :addAt(9, 2, enableAToggle)
    :addAt(7, 3, u.joy({ image = love.graphics.newImage('img/ball.png') }))
end

function love.load()
	initStuff()
	initPanelC()
  initPanelD()
  initPanelB()
  initPanelA()
	u:add(panelA)

	--activation and deactivation elements by tag
	--u:deactivateByTag('PanelD')
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
