require 'images'

return {
  handleStyleChanges = function (u, evt, font1, font2, font3)
    if evt.index == 1 then -- Blue
      evt.target.parent.parent:setStyle({
        lineWidth = 1,
        lineStyle = 'rough',
        outline = false,
        cornerRadius = 0, -- percent
        bgColor = u.utils.colors.LOVE_BLUE,
        fgColor = u.utils.colors.WHITE,
        hoverBgColor = u.utils.colors.LOVE_PINK,
        font = font1
      })
      u:getByTag('russian'):setStyle({ font = font2 })
    end
    if evt.index == 2 then -- Olive
      evt.target.parent.parent:setStyle({
        outline = false,
        cornerRadius = 0.2, -- percent
        bgColor = {0, .4, 0, 0.5},
        fgColor = {0, .2, 0},
        disableFgColor = {.5, .5, .5},
        font = font3
      })
    end
    if evt.index == 3 then -- Neon
      evt.target.parent.parent:setStyle({
        lineWidth = 2,
        lineStyle = 'smooth',
        cornerRadius = 0.5, -- percent
        outline = true,
        bgColor = {1, 0, 0.5},
        fgColor = {1, 1, 1},
        font = font1,
        sliderMark = sliderAndToggle,
        toggleMark = sliderAndToggle
      })
      u:getByTag('russian'):setStyle({ font = font2 })
    end
  end
}
