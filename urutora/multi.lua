local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local baseNode = require(modules .. 'baseNode')
local utils = require(modules .. 'utils')

local multi = baseNode:extend('multi')

function multi:constructor()
  multi.super.constructor(self)
  self.index = self.index or 1
  self.items = self.items or {}
  self.text = self.items[self.index]
end

function multi:change(amount)
  amount = amount or 1
  self.index = self.index + amount
  if self.index < 1           then self.index = #self.items end
  if self.index > #self.items then self.index = 1           end
  self.text = self.items[self.index]
  self._textW = nil
end

function multi:setIndex(index)
  if index > 0 and index <= #self.items then
    self.index = index
    self.text = self.items[self.index]
    self._textW = nil
  end
end

function multi:setValue(text)
  local index = 1
  for i = 1, #self.items do
    index = i
    if self.items[i] == text then break end
  end

  self.index = index
  self.text = self.items[self.index]
  self._textW = nil
end

function multi:draw()
  local layers = self:getLayers()
  local bg = layers.bg or layers.bgMulti
  if bg then
    utils.drawWithShader(self, bg, self.x, self.y)
  end
end

function multi:performReleaseAction(data)
  if not self.enabled then return end
  if self.pressed and self.pointed then
    self:change()
    self.callback({
      target = self,
      value = self.text,
      index = self.index
    })
  end
  self.pressed = false
end

return multi
