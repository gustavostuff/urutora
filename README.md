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

:information_source: This version does not support multituoch yet and haven't been tested in mobile

:information_source: See ```main.lua``` for more details
