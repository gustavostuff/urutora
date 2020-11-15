local urutora = require('urutora')
local u

local style = { 
	fgColor = urutora.utils.toRGB('#788089'),
	bgColor = urutora.utils.toRGB('#efefef'),
	hoverbgColor = urutora.utils.toRGB('#e3e3ef'),
	hoverfgColor = urutora.utils.toRGB('#148ee3'),
	disablefgColor = urutora.utils.toRGB('#586069'),
	disablebgColor = urutora.utils.toRGB('#afafaf'),
	outlineColor = urutora.utils.toRGB('#aaaaaa'),
}
local bgColor = {0.98,0.98,0.98}
local canvas

function love.load()
	local w, h = love.window.getMode()
	w = w / 2
	h = h / 2
	u = urutora:new()

	love.mousepressed = u:pressed()
	love.mousemoved = u:moved()
	love.mousereleased = u:released()
	love.textinput = u:textinput()
	local keypressed = u:keypressed()

	function love.keypressed(k, scancode, isrepeat)
		keypressed(k, scancode, isrepeat)

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

	local panelA
	local panelC = u.panel(nil, { rows = 20, cols = 6, oh = 20 * 18 }, 'C')
	panelC.outline = true
	panelC
		:colspanAt(1, 1, 6)
		:addAt(1, 1, u.label({ text = 'C in B' }))
	for i = 1, 20 do
		panelC
			:colspanAt(i, 1, 3)
			:colspanAt(i, 4, 3)
			:addAt(i, 1, u.label({ text = tostring(i) }))
			:addAt(i, 4, u.button({ text = 'Button' }):action(function (e)
				e.target.text = tostring(i) .. ' clicked!'
			end))
	end

	local panelD = u.panel(nil, { rows = 4, cols = 2 }, 'D')
	panelD.outline = true
	panelD:setStyle({outlineColor = {1, 1, 1}})
	panelD
		:colspanAt(2, 1, 2)
		:colspanAt(3, 1, 2)
		:rowspanAt(3, 1, 2)
		:addAt(1, 1, u.button({ text = 'Button' }))
		:addAt(1, 2, u.button({ text = 'Button' }))
		:addAt(2, 1, u.button({ text = 'Button' }))
		:addAt(3, 1, u.image({ image = love.graphics.newImage('img/unnamed.png'), keep_aspect_ratio = true }))

	local panelB = u.panel(nil, { rows = 4, cols = 4 }, 'B')
	--panelB.outline = true
	panelB
		:rowspanAt(2, 2, 3)
		:colspanAt(2, 2, 2)
		:rowspanAt(2, 4, 3)
		:addAt(1, 1, u.label({ text = 'B in A' }))
		:addAt(1, 2, u.toggle({ text = 'D enabled', value = true }):action(function (e)
			if e.target.value then
				e.target.text = 'D enabled'
				panelD:enable()
			else
				e.target.text = 'D disabled'
				panelD:disable()
			end
		end))
		:addAt(1, 3, u.toggle({ text = 'D visible', value = true }):action(function (e)
			if e.target.value then
				e.target.text = 'D visible'
				panelD:show()
			else
				e.target.text = 'D unvisible'
				panelD:hide()
			end
		end))
		:addAt(1, 4, u.label({ text = 'D panel'}))
		:addAt(2, 2, panelC)
		:addAt(2, 4, panelD)
		:addAt(3, 1, u.joy():action(function (e)
			-- move panel
			--panelA:moveTo(panelA.x + e.target:getX(), panelA.y + e.target:getY())
		end))

	panelA = u.panel(u, { rows = 6, cols = 3, x = 10, y = 10, w = w - 20, h = h - 20 }, 'A')
	--panelA.outline = true
	panelA
		:rowspanAt(5, 1, 2)
		:colspanAt(5, 1, 3)
		:rowspanAt(3, 1, 3)
		:colspanAt(3, 1, 3)
		:addAt(1, 1, u.button({ text = 'A panel' }))
		:addAt(1, 2, u.toggle({ text = 'Slider Toggle' }):action(function (e)
			local slider = panelA:getChildren(1, 3)
			if e.target.value then
				slider:enable()
			else
				slider:disable()
			end
		end))
		:addAt(1, 3, u.slider({ value = 0.3, tag = 'slider' }):disable():action(function(e)
			panelC:setScrollY(e.target.value)
		end))
		:addAt(2, 3, u.toggle({ value = false, text = 'Boolean' }):right())
		:addAt(2, 2, u.text({ text = 'привет мир!' }):setStyle({ font = font2 }))
		:addAt(3, 1, panelB)
		panelA:setStyle(style)
		:addAt(2, 1, u.multi({ items = { 'One', 'Two', 'Three' } }):left():setStyle({ bgColor = { 0.6, 0.7, 0.8 } }))

	--activation and deactivation panel by nameid
	--u:deactivatePanel('A')
	--u:activatePanel('A')
end

function love.update(dt)
	u:update(dt)
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