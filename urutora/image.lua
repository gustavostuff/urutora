local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local baseNode = require(modules .. 'baseNode')
local utils = require(modules .. 'utils')

local image = baseNode:extend('image')

function image:constructor()
  image.super.constructor(self)
  self.image_w, self.image_h = self.image:getDimensions()
  self.keepAspectRatio = true
end

function image:draw()
  if self.image then
    local _, fgc = self:getLayerColors()
    lg.setColor(1, 1, 1, 1)
    local sx, sy
    local x = self.x
    local y = self.y
    sx = self.w / self.image_w
    sy = self.h / self.image_h

    if self.keepAspectRatio then
      sx = math.min(sx, sy)
      sy = sx

      x = x + (self.w - (self.image_w * sx)) / 2
      y = y + (self.h - (self.image_h * sy)) / 2

      if self.align == utils.alignments.LEFT then
        x = self.x
      end
      if self.align == utils.alignments.RIGHT then
        x = self.w - self.image_w * sx
      end
    end

    if self.keepOriginalSize then
      x = self.x + self.w / 2 - self.image_w / 2
      y = self.y + self.h / 2 - self.image_h / 2
      sx, sy = 1, 1
    end
    if not self.enabled then
      lg.setShader(utils.disabledImgShader)
    end
    lg.draw(self.image, math.floor(x), math.floor(y), 0, sx, sy)
    if not self.enabled then
      lg.setShader()
    end
  end
end

return image
