_G.lg = love.graphics
_G.lm = love.mouse

local modules = (...) and (...):gsub('%.init$', '') .. "." or ""
return require(modules .. 'urutora')
