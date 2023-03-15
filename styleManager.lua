require 'images'
require 'fonts'

local emptyStyle = {}

local oliveStyle = {
  outline = false,
  cornerRadius = 0.2, -- percent
  bgColor = {0, 0.4, 0, 0.5},
  fgColor = {0, 0.3, 0},
  disableFgColor = {0, 0, 0, 0.3},
  font = robotoBold
}

local neonStyle = {
  lineWidth = 2,
  lineStyle = 'smooth',
  cornerRadius = 0.5, -- percent
  outline = true,
  bgColor = {1, 0, 0.5},
  fgColor = {1, 1, 1},
  hoverBgColor = {1, 0.9, 0},
  disableFgColor = {0.5, 0.5, 0.5},
  font = neonClub,
  sliderMark = sliderAndToggle,
  toggleMark = sliderAndToggle,
}

local metalStyle = {
  customLayers = {
    bgButton = bgButton,
    bgSlider = bgSlider,
    bgSliderVertical = bgSliderVertical,
    bgText = bgText,
    bgProgressbar = bgProgressbar, 
    fgProgressbar = fgProgressbar, 
    bgMulti = bgMulti,
    bgToggle = bgToggle,
    fgSlider = fgSlider,
    fgSliderOn = fgSliderOn,
    fgSliderVertical = fgSliderVertical,
    fgSliderVerticalOn = fgSliderVerticalOn,
    fgToggle = fgToggle,
    fgToggleOn = fgToggleOn,
  },
  progressBarGooColor = {0, 1, 0, 0.7},
  cornerRadius = 0.2,
  fgColor = {love.math.colorFromBytes(67, 78, 108)},
  hoverFgColor = {0, 0.8, 0},
  pressedFgColor = {0, 1, 0},
  disableFgColor = {0.2 , 0.2, 0.2},
}

return {
  handleStyleChanges = function (u, evt)
    if evt.index == 1 then
      u:setStyle(emptyStyle)
      -- only this fonts has the Cyrillic alphabet:
      u:getByTag('russian').style.font = proggySquare
    end
    if evt.index == 2 then
      u:setStyle(oliveStyle)
    end
    if evt.index == 3 then
      u:setStyle(neonStyle)
      u:getByTag('russian').style.font = proggySquare
    end
    if evt.index == 4 then
      u:setStyle(metalStyle)
      -- change fgColor fot labels:
      metalStyle.fgColor = {love.math.colorFromBytes(212, 222, 248)}
      u:setStyle(metalStyle, u.utils.nodeTypes.LABEL)
      metalStyle.fgColor = {love.math.colorFromBytes(67, 78, 108)}
      u:getByTag('russian').style.font = proggySquare
    end
  end
}
