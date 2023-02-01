local urutora = require('lib/urutora')
local u

local bgColor = { 0.1, 0.1, 0.1 }
local canvas
local panelA, panelB, panelC, panelD
local kitana = love.graphics.newImage('img/clickbait_kitana.png')
local unnamed = love.graphics.newImage('img/unnamed.png')

function love.load()
	local w, h = love.window.getMode()
	w = w / 2
	h = h / 2

	u = urutora:new()

	function love.mousepressed(x, y, button) u:pressed(x, y) end
	function love.mousemoved(x, y, dx, dy) u:moved(x, y, dx, dy) end
	function love.mousereleased(x, y, button) u:released(x, y) end
	function love.textinput(text) u:textinput(text) end
	function love.wheelmoved(x, y) u:wheelmoved(x, y) end

	function love.keypressed(k, scancode, isrepeat)
		u:keypressed(k, scancode, isrepeat)

		if k == 'escape' then
			love.event.quit()
		end
	end

	canvas = love.graphics.newCanvas(w, h)
	canvas:setFilter('nearest', 'nearest')
	local font1 = love.graphics.newFont('fonts/proggy/proggy-tiny.ttf', 16)
	local font2 = love.graphics.newFont('fonts/proggy/proggy-square-rr.ttf', 16)

	u.setDefaultFont(font1)
	u.setResolution(canvas:getWidth(), canvas:getHeight())

	panelC = u.panel({ rows = 20, cols = 6, csy = 18, tag = 'PanelC'})
	panelC
		:colspanAt(1, 1, 6)
	for i = 1, 20 do
		panelC
			:colspanAt(i, 1, 3)
			:colspanAt(i, 4, 3)
			:addAt(i, 1, u.label({ text = tostring(i) }))
			:addAt(i, 4, u.button({ text = 'Button' }))
	end

	panelD = u.panel({ rows = 4, cols = 2, tag = 'PanelD' })
	panelD
		:colspanAt(2, 1, 2)
		:colspanAt(3, 1, 2)
		:rowspanAt(3, 1, 2)
		:addAt(1, 1, u.button({ text = '1' }))
		:addAt(1, 2, u.button({ text = '2' }))
		:addAt(2, 1, u.slider())
		:addAt(3, 1, u.image({ image = unnamed }):action(function (e)
      e.target.keepAspectRatio = not e.target.keepAspectRatio
    end))

	panelB = u.panel({ rows = 5, cols = 2, tag = 'PanelB', csy = 32, spacing = 5 })
	panelB
    :rowspanAt(5, 1, 3)
    :rowspanAt(5, 2, 3)
    :rowspanAt(1, 2, 3)
		:addAt(1, 1, u.label({ text = 'B Panel (scroll)' }))
  :addAt(1, 2, u.animation({
    image = kitana,
    frames = 21,
    frameWidth = 80,
    frameHeight = 75,
    frameDelay = 0.2,
    keepOriginalSize = true
  }):action(function (e)
    e.target.keepOriginalSize = not e.target.keepOriginalSize
  end))
    :addAt(4, 1, u.label({ text = 'C panel (scroll)'}):center())
		:addAt(4, 2, u.label({ text = 'D panel'}))
    :addAt(2, 1, u.label({ text = 'click ->' }))
		:addAt(5, 1, panelC)
		:addAt(5, 2, panelD)

	panelA = u.panel({ rows = 7, cols = 4, x = 0, y = 0, w = 300, h = 140, tag = 'PanelA' })
	panelA
		:rowspanAt(1, 4, 2)
		:rowspanAt(5, 1, 2)
		:colspanAt(5, 1, 3)
		:rowspanAt(3, 2, 3)
		:colspanAt(3, 1, 3)
    :rowspanAt(3, 4, 4)
		:rowspanAt(3, 1, 4)
		:addAt(1, 1, u.label({ text = 'A panel' }))
		:addAt(1, 2, u.toggle({ text = 'Slider ->' }):action(function (e)
			local slider = panelA:getChildren(1, 3)
			if e.target.value then
				slider:enable()
			else
				slider:disable()
			end
		end))
		:addAt(1, 3, u.slider({ value = 0.3, tag = 'slider', axis = 'x'  }):disable():action(function(e)
			panelC:setScrollY(e.target.value)
		end))
		:addAt(3, 4, u.slider({ value = 0.3, tag = 'slider', axis = 'y' }):action(function(e)
			panelB:setScrollY(e.target.value)
		end))
		:addAt(2, 3, u.toggle({ value = false, text = 'Boolean' }):right())
		:addAt(2, 2, u.text({ text = 'привет мир!' }):setStyle({ font = font2 }))
		:addAt(3, 1, panelB)
		:addAt(1, 4, u.joy())
    :addAt(7, 1, u.toggle({ text = 'D enabled', value = true }):action(function (e)
			if e.target.value then
				e.target.text = 'D enabled'
				panelD:enable()
			else
				e.target.text = 'D disabled'
				panelD:disable()
			end
		end))
		:addAt(7, 2, u.toggle({ text = 'D visible', value = true }):action(function (e)
			if e.target.value then
				e.target.text = 'D visible'
				panelD:show()
			else
				e.target.text = 'D hidden'
				panelD:hide()
			end
		end))
		:addAt(2, 1, u.multi({ items = { 'One', 'Two', 'Three' } }):left()
			:setStyle({ bgColor = { 0.6, 0.7, 0.8 } }, true))

	u:add(panelA)

	--activation and deactivation elements by tag
	--u:deactivateByTag('PanelD')

  kitanaAnim = katsudo.new('img/clickbait_kitana.png', 80, 75, 21, 0.2)
end

local x = 0
local y = 0

function love.update(dt)
	u:update(dt)
	--panelA:moveTo(x, y)
	--x = x + 0.1
	--y = y + 0.1
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear(bgColor)
	u:draw()
	love.graphics.setCanvas()

	love.graphics.draw(canvas, 0, 0, 0,
		love.graphics.getWidth() / canvas:getWidth(),
		love.graphics.getHeight() / canvas:getHeight()
	)
end
