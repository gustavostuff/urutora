local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local baseNode = require(modules .. 'baseNode')
local utf8 = require('utf8')

local text = baseNode:extend('text')

function text:constructor()
  text.super.constructor(self)
  self.align = utils.alignments.LEFT
  self.text = self.text or ''
  self:resetCursor()
  self.cursorDelay = 0.25
end

function text:resetCursor()
  self.cursorChar = '_'
  self.cursorTimer = 0
end

function text:draw()
  local _, fgc = self:getLayerColors()
  lg.setColor(fgc)
  local y = self.y + self.h - 2
  local textY = self:centerY() - utils.textHeight(self) / 2
  lg.setLineStyle(self.style.lineStyle or utils.style.lineStyle)
  lg.setLineWidth(self.style.lineWidth or utils.style.lineStyle)
  
  local layers = self.style.customLayers or {}
  if layers.textBg then
    lg.setColor(1, 1, 1)
    utils.draw(layers.textBg, self.x, self.y)
  else
    utils.line(self.x, y, self.x + self.w, y)
  end

  if self.focused then
    lg.setColor(fgc)
    utils.print(self.cursorChar, self.x + utils.textWidth(self), textY)
  end
end

function text:update(dt)
  self.cursorTimer = self.cursorTimer + dt
  if self.cursorTimer > self.cursorDelay then
    self.cursorTimer = 0
    self.cursorChar =  self.cursorChar == '_' and ' ' or '_'
  end
end

function text:textInput(text, scancode)
  if scancode == 'backspace' then
    local byteoffset = utf8.offset(self.text, -1)
    if byteoffset then
      self.text = string.sub(self.text, 1, byteoffset - 1)
    end
  else
    if utils.textWidth(self) <= self.npw then
      self.text = self.text .. (text or '')
    end
  end

  if scancode == 'return' then
    self.focused = false
  end
end

return text
