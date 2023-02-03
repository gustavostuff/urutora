local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local base_node = require(modules .. 'base_node')

local lovg = love.graphics

local image = base_node:extend('image')

function image:constructor()
  image.super.constructor(self)
  self.image_w, self.image_h = self.image:getDimensions()
  self.keepAspectRatio = true
end

function image:draw()
  if self.image then
    local _, fgc = self:getLayerColors()
    lovg.setColor(1, 1, 1, 1)
    local sx, sy
    local x = self.x
    local y = self.y
    sx = (self.w - 1) / self.image_w
    sy = (self.h - 1) / self.image_h

    if self.keepAspectRatio then
      sx = math.min(sx, sy)
      sy = sx

      x = x + (self.w - (self.image_w * sx)) / 2
      y = y + (self.h - (self.image_h * sy)) / 2
    end

    if self.disabled then
      lovg.setColor(1, 0, 0)
    end
    if self.keepOriginalSize then
      x = self.x + self.w / 2 - self.image_w / 2
      y = self.y + self.h / 2 - self.image_h / 2
      sx, sy = 1, 1
    end
    lovg.draw(self.image, x, y, 0, sx, sy)
  end
end

return image
