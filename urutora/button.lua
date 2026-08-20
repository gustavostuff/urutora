local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local lg = love.graphics
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')

local button = baseNode:extend('button')

function button:draw()
  local layers = self:getLayers()
  if layers.bgButton then
    utils.drawWithShader(self, layers.bgButton, self.x, self.y)
  end
end

function button:performReleaseAction(data)
  if not self.enabled then return end
  if self.pressed and self.pointed then
    self.callback({ target = self })
  end
  self.pressed = false
end

return button
