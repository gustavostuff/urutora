# urutora

GUI Library for LÖVE

[![License](http://img.shields.io/:license-MIT-blue.svg)](https://github.com/tavuntu/urutora/blob/master/LICENSE.md)
[![Version](http://img.shields.io/:beta-0.1.0-green.svg)](https://github.com/tavuntu/urutora)

![](https://i.postimg.cc/YSn4vZRF/Screen-Shot-2020-05-14-at-9-55-09-PM.png)

![](https://i.postimg.cc/9F5DwGdL/Screen-Shot-2020-05-14-at-9-55-17-PM.png)

## Instructions

Import the urutora folder in your project and do:

```lua
urutora = require 'urutora'
```

You will also need to pass love's events to urutora:

```lua
function love.mousepressed(x, y, button) urutora.pressed(x, y) end
function love.mousemoved(x, y, dx, dy) urutora.moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) urutora.released(x, y) end
function love.textinput(text) urutora.textinput(text) end
function love.keypressed(k, scancode, isrepeat) urutora.keypressed(k, scancode, isrepeat) end
```

In your update and draw functions, call urutora's respective functions:

```lua
function love.update(dt)
  urutora.update(dt)
end

function love.draw()
  urutora.draw()
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
-- returns a slider with a given value (0.5 by default)
urutora.slider({ value, x, y, w, h })
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

:information_source: See ```main.lua``` for more details
