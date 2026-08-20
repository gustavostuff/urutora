local lg = love.graphics

local shaders = {}

shaders.disabledImgShader = lg.newShader([[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    number average = (pixel.r + pixel.b + pixel.g) / 3.0;
    pixel.r = average * 0.4;
    pixel.g = average * 0.4;
    pixel.b = average * 0.4;
    return pixel;
  }
]])

shaders.pointedImgShader = lg.newShader([[
  float brightness = 0.1;
  float contrast = 1.2;

  vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec4 pixel = Texel(tex, tex_coords);
      pixel.rgb += brightness;
      pixel.rgb = (pixel.rgb - 0.5) * contrast + 0.5;
      return pixel * color;
  }
]])

shaders.pressedImgShader = lg.newShader([[
  float brightness = 0.1;
  float contrast = 1.1;

  vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec4 pixel = Texel(tex, tex_coords);
      pixel.rgb -= brightness;
      pixel.rgb = (pixel.rgb - 0.5) / contrast + 0.5;
      return pixel * color;
  }
]])

return shaders
