# urutora

GUI Library for LÖVE

:information_source: This library aims to replace [GOOi](https://github.com/tavuntu/gooi), which won't be maintained anymore.

[![License](http://img.shields.io/:license-MIT-blue.svg)](https://github.com/tavuntu/urutora/blob/master/LICENSE.md)
[![Version](http://img.shields.io/:version-0.0.8-green.svg)](https://github.com/tavuntu/urutora)

![](https://i.postimg.cc/4Nh1RSKB/Screen-Shot-2020-05-01-at-1-48-55-PM.png)

![](https://i.postimg.cc/T3B32gVj/Screen-Shot-2020-05-01-at-2-55-14-PM.png)

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
-- returns slider with a given value (0.5 by default)
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
-- returns a multi option selector
urutora.text({ text, x, y, w, h })
```

```lua
-- returns a joystick component
urutora.joy({ x, y, w, h })
```

## Notes

:information_source: This version does not support multituoch yet and haven't been tested in mobile

:information_source: See ```main.lua``` for more details
