katsudo = {}
katsudo.__index = katsudo
katsudo.anims = {}

function katsudo.new(img, quadWidth, quadHeight, numberOfQuads, millis, style)
  local newAnim = {}
  
  if not img then
    error("Error in katsudo.new() parameter #1, please provide an image (string or Image)")
  end
  if not (quadWidth or quadHeight) then
    error("Error in katsudo.new(), parameter #2 nor #3, please provide width and height")
  end

  if type(img) == "string" then
    img = lg.newImage(img)
  end
  img:setFilter(
    katsudo.rough and 'nearest' or 'linear',
    katsudo.rough and 'nearest' or 'linear'
  )

  newAnim.img = img
  local imgW = newAnim.img:getWidth()
  local imgH = newAnim.img:getHeight()

  local automaticNumberOfQuads = math.floor(imgW / quadWidth) * math.floor(imgH / quadHeight)
  if numberOfQuads and (numberOfQuads > automaticNumberOfQuads) then
    error("Error in katsudo.new(), the max number of frames is "..automaticNumberOfQuads)
  end

  newAnim.numberOfQuads = numberOfQuads or automaticNumberOfQuads
  newAnim.items = {}
  newAnim.mode = "repeat"
  newAnim.animType = 'frames'

  -- Generate frames (quads):
  local x, y = 0, 0
  for i = 1, newAnim.numberOfQuads do
    table.insert(newAnim.items, {
      quad = lg.newQuad(x, y, quadWidth, quadHeight, imgW, imgH),
      delay = millis or 0.1
    })
    x = x + quadWidth
    if x >= imgW then
      y = y + quadHeight
      x = 0
    end
  end

  newAnim.w = quadWidth
  newAnim.h = quadHeight
  newAnim.timer = 0
  newAnim.index = 1
  newAnim.sense = 1
  newAnim.finished = false

  table.insert(katsudo.anims, newAnim)
  return setmetatable(newAnim, katsudo)
end

function katsudo.rotate(img, speed, reverse)
  if not img then
    error("Error in katsudo.rotate() parameter #1, please provide an image (string or Image)")
  end

  if type(img) == "string" then
    img = lg.newImage(img)
  end

  local newAnim = {}
  newAnim.img = img
  newAnim.w = img:getWidth()
  newAnim.h = img:getHeight()
  newAnim.animType = 'rotation'
  newAnim.speed = speed or 1
  newAnim.rotationAmount = 0
  newAnim.rotationCounterClockwise = reverse

  -- random rotation sense:
  if reverse == 'random' then
    if love.math.random(1, 2) == 1 then
      newAnim.rotationCounterClockwise = true
    else
      newAnim.rotationCounterClockwise = false
    end
  end

  table.insert(katsudo.anims, newAnim)
  return setmetatable(newAnim, katsudo)
end

function katsudo.update(dt)
  for i = 1, #katsudo.anims do
    local a = katsudo.anims[i]

    if a.animType == 'frames' then
      if not a.finished then
        a.timer = a.timer + dt
        if a.timer >= a.items[a.index].delay then
          a.timer = 0
          a.index = a.index + 1 * a.sense

          if a.index > #a.items or a.index < 1 then
            if a.mode == "repeat" then
              a.index = 1
            elseif a.mode == "rewind" then
              a.sense = a.sense * -1
              if a.sense < 0 then
                a.index = a.index - 1
              end
              if a.sense > 0 then
                a.index = a.index + 1
              end
            elseif a.mode == "once" then
              a.finished = true
              a.index = a.index - 1
            end
          end
        end
      end
    elseif a.animType == 'rotation' then
      a.rotationAmount = a.rotationAmount + dt * a.speed * 360

      if a.rotationAmount >= 360 then
        a.rotationAmount = 0
      end
    end
  end
end

function katsudo:selfUpdate(dt)
  local a  = self

  if a.animType == 'frames' then
    if not a.finished then
      a.timer = a.timer + dt
      if a.timer >= a.items[a.index].delay then
        a.timer = 0
        a.index = a.index + 1 * a.sense

        if a.index > #a.items or a.index < 1 then
          if a.mode == "repeat" then
            a.index = 1
          elseif a.mode == "rewind" then
            a.sense = a.sense * -1
            if a.sense < 0 then
              a.index = a.index - 1
            end
            if a.sense > 0 then
              a.index = a.index + 1
            end
          elseif a.mode == "once" then
            a.finished = true
            a.index = a.index - 1
          end
        end
      end
    end
  elseif a.animType == 'rotation' then
    a.rotationAmount = a.rotationAmount + dt * a.speed * 360

    if a.rotationAmount >= 360 then
      a.rotationAmount = 0
    end
  end
end

function katsudo:r()
  if self.rotationCounterClockwise then
    return math.rad(360 - self.rotationAmount)
  end

  return math.rad(self.rotationAmount)
end

function katsudo:rewind()
  if self.animType == 'frames' then
    self.mode = "rewind"
  end
  return self
end

function katsudo:once()
  if self.animType == 'frames' then
    self.mode = "once"
  end
  return self
end

function katsudo:setDelay(millis, index, theRestAlso)
  if self.animType == 'frames' then
    if index then
      if self.items[index] then
        self.items[index].delay = millis

        if theRestAlso then
          for i = index + 1, #self.items do
            self.items[i].delay = millis                    
          end
        end
      else
        error("error in setDelay(), no frame at index "..index.."")
      end
    else
      for i = 1, #self.items do
        self.items[i].delay = millis                    
      end
    end
  elseif self.animType == 'rotation' then
    self.speed = millis
  end
  return self
end

function katsudo:draw(...)
  lg.push('all')
  if self.animType == 'frames' then
    local q = self.items[self.index].quad
    lg.draw(self.img, q, ...)
  elseif self.animType == 'rotation' then
    lg.draw(self.img, ...)
  end
  lg.pop()
end

return katsudo
