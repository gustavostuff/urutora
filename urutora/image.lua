local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local baseNode = require(modules .. 'baseNode')
local utils = require(modules .. 'utils')
local media = require(modules .. 'media')

local image = baseNode:extend('image')

function image:constructor()
  image.super.constructor(self)
  self.image_w, self.image_h = self.image:getDimensions()
  self.keepAspectRatio = true
end

function image:draw()
  if not self.image then return end
  lg.setColor(1, 1, 1, 1)
  media.fitAndDraw(self, self.image_w, self.image_h, function (x, y, sx, sy)
    if not self.enabled then
      lg.setShader(utils.disabledImgShader)
    end
    lg.draw(self.image, x, y, 0, sx, sy)
    if not self.enabled then
      lg.setShader()
    end
  end)
end

function image:performReleaseAction(data)
  if not self.enabled then return end
  if self.pressed and self.pointed then
    self.callback({ target = self })
  end
  self.pressed = false
end

return image
