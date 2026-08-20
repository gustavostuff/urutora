local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local baseNode = require(modules .. 'baseNode')
local katsudo = require(modules .. 'katsudo')
local utils = require(modules .. 'utils')
local media = require(modules .. 'media')

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
  if not self.anim then return end
  lg.setColor(1, 1, 1, 1)
  media.fitAndDraw(self, self.anim.w, self.anim.h, function (x, y, sx, sy)
    if not self.enabled then
      lg.setShader(utils.disabledImgShader)
    end
    self.anim:draw(x, y, 0, sx, sy)
    if not self.enabled then
      lg.setShader()
    end
  end)
end

function animation:performReleaseAction(data)
  if not self.enabled then return end
  if self.pressed and self.pointed then
    self.callback({ target = self })
  end
  self.pressed = false
end

return animation
