local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local baseNode = require(modules .. 'baseNode')
local utils = require(modules .. 'utils')

local button = baseNode:extend('button')

local base_drawText = button.super.drawText
local base_drawBaseRectangle = button.super.drawBaseRectangle

function button:constructor()
  button.super.constructor(self)
  local layers = self.style.customLayers or {}
end

function button:draw()
  local layers = self.style.customLayers or {}
  if layers.bgButton then
    utils.drawWithShader(self, layers.bgButton, self.x, self.y)
  end
end


return button
