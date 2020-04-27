local u = require('urutora')

function love.load()
  local font = love.graphics.newFont('fonts/proggy-tiny.ttf', 16)
  u.font = font

  print(tostring(u))
  u.panel({ rows = 4, cols = 3, w = 384, h = 108 })
    :add(u.label({ text = 'A label' }), 1, 1)
    :add(u.button({ text = 'Button' }):action(function (e)
      e.target.text = 'Clicked!'
    end), 1, 2)
    :add(u.slider({ value = 0.3 }):disable():hide(), 1, 3)
    :add(u.toggle({ text = 'off', value = false }):action(function (e)
      e.target.text = 'off'
      if e.target.value then
        e.target.text = 'on'
      end
    end), 2, 1)
    :add(u.multi({ items = { 'One', 'Two', 'Three' } }), 2, 1)
    :add(u.text({ value = 'aaa' }), 2, 2)
    :add(u.button({ text = 'Change to B' }):action(function(e)
      u.enableGroup('B')
      u.showGroup('B')
      u.disableGroup('A')
      u.hideGroup('A')
    end), 4, 2)
  :setGroup('A')

  u.panel({ rows = 4, cols = 3, w = 384, h = 108, y = 108 })
    :add(u.label({ text = 'A label' }), 1, 1)
    :add(u.button({ text = 'Button' }):action(function (e)
      e.target.text = 'Clicked!'
    end), 1, 2)
    :add(u.slider({ value = 0.3 }), 1, 3)
    :add(u.toggle({ text = 'off', value = false }):action(function (e)
      e.target.text = 'off'
      if e.target.value then
        e.target.text = 'on'
      end
    end), 2, 1)
    :add(u.multi({ items = { 'One', 'Two', 'Three' } }), 2, 1)
    :add(u.text({ value = 'bbb' }), 2, 2)
    :add(u.button({ text = 'Change to A' }):action(function(e)
      u.enableGroup('A')
      u.showGroup('A')
      u.disableGroup('B')
      u.hideGroup('B')
    end), 4, 2)
  :setGroup('B')

  u.disableGroup('B')
  u.hideGroup('B')

  u.setResolution(384, 216)
  u.setFilter('nearest')
end

function love.update(dt)
  u.update(dt)
end

function love.draw()
  u.draw()
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