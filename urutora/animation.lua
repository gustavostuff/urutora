local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local baseNode = require(modules .. 'baseNode')
local katsudo = require(modules .. 'katsudo')
local utils = require(modules .. 'utils')

local animation = baseNode:extend('animation')

function animation:constructor()
  animation.super.constructor(self)
  self.anim = katsudo.new(
    self.image,
    self.frameWidth,
    self.frameHeight,
    self.frames,
    self.frameDelay,
    self.style
  )
end

function animation:draw()
  if self.anim then
    local _, fgc = self:getLayerColors()
    lg.setColor(1, 1, 1, 1)
    local sx, sy
    local x = self.x
    local y = self.y
    sx = self.w / self.anim.w
    sy = self.h / self.anim.h

    if self.keepAspectRatio then
      sx = math.min(sx, sy)
      sy = sx

      x = x + (self.w - (self.anim.w * sx)) / 2
      y = y + (self.h - (self.anim.h * sy)) / 2
    end

    if self.keepOriginalSize then
      x = self.x + self.w / 2 - self.anim.w / 2
      y = self.y + self.h / 2 - self.anim.h / 2
      sx, sy = 1, 1
    end

    if not self.enabled then
      lg.setShader(utils.disabledImgShader)
    end
    self.anim:draw(
      math.floor(x),
      math.floor(y),
      0,
      sx,
      sy
    )
    if not self.enabled then
      lg.setShader()
    end
  end
end

return animation
