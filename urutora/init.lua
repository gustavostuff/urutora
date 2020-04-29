local path = ( ... ):match("(.+)%.[^%.]+$") or ( ... )
local u = require(path .. '/urutora')
return u
