# urutora

GUI Library for LÖVE

[![License](http://img.shields.io/:license-MIT-blue.svg)](https://github.com/tavuntu/urutora/blob/master/LICENSE.md)
[![Version](http://img.shields.io/:beta-0.1.0-green.svg)](https://github.com/tavuntu/urutora)

![](https://i.postimg.cc/bJjMkXWV/1.png)

## Instructions

Import the urutora folder in your project and do:

```lua
urutora = require 'urutora'
local u = urutora:new()

```

You will also need to pass love's events to urutora:

```lua
function love.mousepressed(x, y, button) u:pressed(x, y) end
function love.mousemoved(x, y, dx, dy) u:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) u:released(x, y) end
function love.textinput(text) u:textinput(text) end
function love.keypressed(k, scancode, isrepeat) u:keypressed(k, scancode, isrepeat) end
function love.wheelmoved(x, y) u:wheelmoved(x, y) end
```

In your update and draw functions, call urutora's respective functions:

```lua
function love.update(dt) 
    u:update(dt)
end
function love.draw() 
    u:draw()
end
```

Then, to set up your UI, call any of the component functions with its parameters during initialization.

```lua
function love.load()
  local clickMe = urutora.button({
    text = 'Click me!',
    x = 10, y = 10,
    w = 200,
  })

  local num = 0
  clickMe:action(function(e)
    num = num + 1
    e.target.text = 'You clicked me ' .. num .. ' times!'
  end)

  u:add(clickMe)
end
```

## Components

```lua
-- returns a panel with a Rows x Cols grid
urutora.panel({ text, x, y, w, h, rows, cols })
```

```lua
-- returns a label with centered text
urutora.label({ text, x, y, w, h })
```

```lua
-- returns a button with centered text
urutora.button({ text, x, y, w, h })
```

```lua
-- returns a image component
urutora.image({ image, x, y, w, h, keep_aspect_ratio })
```

```lua
-- returns a slider with a given value (0.5 by default)
urutora.slider({ value, x, y, w, h, minValue, maxValue })
```

```lua
-- returns a toggle button, turned off by default
urutora.toggle({ text, value, x, y, w, h })
```

```lua
-- returns a multi option selector
urutora.multi({ items, x, y, w, h })
```

```lua
-- returns a text field component
urutora.text({ text, x, y, w, h })
```

```lua
-- returns a joystick component
urutora.joy({ x, y, w, h })
```

## Notes

:information_source: This version does not support multitouch yet and haven't been tested in mobile

:information_source: See ```main.lua``` for a more complete example
