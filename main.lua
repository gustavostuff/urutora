local urutora = require 'urutora'
local colors = require 'colors'

function love.load()
  urutora.newPanel({ x = 0, y = 0, w = 800, h = 600, rows = 16, cols = 6 })
    :add(urutora.newLabel({ text = 'Label' }), 1, 1)
    :add(urutora.newButton({ text = 'Button' }):action(function(evt)
      evt.target.text = 'Clicked!'
    end), 1, 2)
end

function love.update(dt)

  urutora.update(dt)
end

function love.draw()
  urutora.draw()
end

function love.mousepressed(x, y, button)  urutora.pressed(x, y) end
function love.mousemoved(x, y, dx, dy)    urutora.moved(x, y) end
function love.mousereleased(x, y, button) urutora.released(x, y) end
function love.textinput(text)             urutora.textinput(text) end

function love.keypressed(k, scancode)
  urutora.keypressed(k, scancode)

  if k == 'escape' then
    love.event.quit()
  end
end