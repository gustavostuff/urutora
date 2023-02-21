require 'images'

return {
  handleStyleChanges = function (u, evt, font1, font2)
    if evt.index == 1 then -- Blue
      u:setStyle({
        lineWidth = 1,
        lineStyle = 'rough',
        outline = false,
        cornerRadius = 0, -- percent
        bgColor = u.utils.colors.LOVE_BLUE,
        -- fgColor = u.utils.colors.WHITE,
        hoverBgColor = u.utils.colors.LOVE_PINK,
        font = font1
      })
      u:getByTag('russian').style.font = font3
    end
    if evt.index == 2 then -- Olive
      u:setStyle({
        outline = false,
        cornerRadius = 0.2, -- percent
        bgColor = {0, .4, 0, 0.5},
        fgColor = {0, .2, 0},
        disableFgColor = {0, 0, 0, 0.5},
        font = font2
      })
    end
    if evt.index == 3 then -- Neon
      u:setStyle({
        lineWidth = 2,
        lineStyle = 'smooth',
        cornerRadius = 0.5, -- percent
        outline = true,
        bgColor = {1, 0, 0.5},
        fgColor = {1, 1, 1},
        disableFgColor = {0.5, 0.5, 0.5},
        font = font1,
        sliderMark = sliderAndToggle,
        toggleMark = sliderAndToggle,
      })
      u:getByTag('russian').style.font = font3
    end
    if evt.index == 4 then -- Metal
      u:setStyle({
        customLayers = {
          bgButton = bgButton,
          bgSlider = bgSlider,
          bgText = bgText,
          bgMulti = bgMulti,
          fgSlider = fgSlider,
          bgToggle = bgToggle,
          fgToggle = fgToggle
        },
        fgColor = {love.math.colorFromBytes(67, 78, 108)},
        hoverFgColor = {0, 0.8, 0},
        pressedFgColor = {0, 1, 0},
        disableFgColor = {0.2 , 0.2, 0.2},
      })
      u:getByTag('russian').style.font = font3
    end
  end
}
