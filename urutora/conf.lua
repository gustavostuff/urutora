function love.conf(t)
  t.identity = nil
  t.appendidentity = false
  t.version = '11.4'
  t.console = false
  t.accelerometerjoystick = true
  t.externalstorage = false
  t.gammacorrect = false

  t.audio.mic = false
  t.audio.mixwithsystem = true

  t.window.title = 'Urutora'
  t.window.icon = nil
  t.window.width = 320 * 3
  t.window.height = 180 * 3
  t.window.borderless = true
  t.window.resizable = true
  t.window.minwidth = 320
  t.window.minheight = 180
  t.window.fullscreen = false
  t.window.fullscreentype = 'desktop'
  t.window.vsync = 1
  t.window.msaa = 0
  t.window.depth = nil
  t.window.stencil = nil
  t.window.display = 1
  t.window.highdpi = false
  t.window.usedpiscale = true
  t.window.x = nil
  t.window.y = nil

  t.modules.audio = true
  t.modules.data = true
  t.modules.event = true
  t.modules.font = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = true
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = true
  t.modules.sound = true
  t.modules.system = true
  t.modules.thread = true
  t.modules.timer = true
  t.modules.touch = true
  t.modules.video = true
  t.modules.window = true
end
