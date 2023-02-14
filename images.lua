marco = love.graphics.newImage('img/marco.png')
logo = love.graphics.newImage('img/logo.png')
arrow = love.graphics.newImage('img/arrow.png')
anim = love.graphics.newImage('img/clickbait_kitana.png')

joyLayer1 = love.graphics.newImage('img/joy_layer_1.png')
joyLayer2 = love.graphics.newImage('img/joy_layer_2.png')
joyLayer3 = love.graphics.newImage('img/joy_layer_3.png')

joyLayer1:setFilter('nearest', 'nearest')
joyLayer2:setFilter('nearest', 'nearest')
joyLayer3:setFilter('nearest', 'nearest')

sliderAndToggle = love.graphics.newImage('img/slider_and_toggle.png')

bgs = {
  love.graphics.newImage('img/bg1.png'),
  love.graphics.newImage('img/bg2.png'),
  love.graphics.newImage('img/bg3.png')
}
