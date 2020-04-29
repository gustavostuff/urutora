local u = require('urutora')

function love.load()
  bgColor = { 0, 0, 0 }
  canvas = love.graphics.newCanvas(384, 216)
  canvas:setFilter('nearest', 'nearest')
  local font = love.graphics.newFont('fonts/proggy/proggy-tiny.ttf', 16)
  local font2 = love.graphics.newFont('fonts/press-start/PressStart2P-vaV7.ttf', 8)
  
  u.font = font
  u.setResolution(canvas:getWidth(), canvas:getHeight())

  print(tostring(u))
  local panelA = u.panel({ rows = 7, cols = 3, w = 384, h = 216 })
  panelA
    :addAt(1, 1, u.label({ text = 'A label' }))
    :addAt(1, 2, u.button({ text = 'Button' }):action(function (e)
      e.target.text = 'Clicked!'
    end))
    :addAt(1, 3, u.slider({ value = 0.3 }):disable())
    :addAt(2, 3, u.toggle({ value = false, text = 'Boolean' }))
    :addAt(2, 1, u.multi({ items = { 'One', 'Two', 'Three' } }):setStyle({
      bgColor = { 0.6, 0.2, 0.2 }
    }))
    :addAt(2, 2, u.text({ text = 'aaa' }))
    :addAt(3, 1, u.button({ text = 'Enable slider' }):action(function (e)
      panelA.children[3]:enable() -- 3rd addAt call
    end))
    :addAt(4, 2, u.button({ text = 'Change to B' }):action(function(e)
      u.activateGroup('B').deactivateGroup('A')
      bgColor = { 1, 1, 1 }
    end))
  :setGroup('A')

  u.panel({ rows = 7, cols = 3, w = 384, h = 216 })
    :addAt(1, 1, u.button({ text = 'Button' }):action(function (e)
      e.target.text = 'Clicked!'
    end))
    :addAt(1, 2, u.label({ text = 'Panel B' }))
    :addAt(1, 3, u.slider({ value = 0.3 }):disable())
    :addAt(2, 3, u.toggle({ text = 'off', value = false }):action(function (e)
      if e.target.value then e.target.text = 'on' else e.target.text = 'off' end
    end))
    :addAt(2, 1, u.text({ text = 'aaa' }))
    :addAt(2, 2, u.multi({ items = { 'One', 'Two', 'Three' } }))
    :addAt(4, 2, u.button({ text = 'Change to A' }):action(function(e)
      u.activateGroup('A').deactivateGroup('B')
      bgColor = { 0, 0, 0 }
    end))
  :setGroup('B'):setStyle({
    bgColor = { 1, 0.5, 0.2 },
    fgColor = { 0, 0, 0 },
    font = font2
  })

  u.disableGroup('B')
  u.hideGroup('B')
end

function love.update(dt)
  u.update(dt)
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear(bgColor)
  u.draw()
  love.graphics.setCanvas()
  
  love.graphics.draw(canvas, 0, 0, 0,
    love.graphics.getWidth() / canvas:getWidth(),
    love.graphics.getHeight() / canvas:getHeight()
  )
end

function love.mousepressed(x, y, button) u.pressed(x, y) end
function love.mousemoved(x, y, dx, dy) u.moved(x, y) end
function love.mousereleased(x, y, button) u.released(x, y) end
function love.textinput(text) u.textinput(text) end

function love.keypressed(k, scancode, isrepeat)
  u.keypressed(k, scancode, isrepeat)

  if k == 'escape' then
    love.event.quit()
  end
end