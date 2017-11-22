local crozeng = require 'crozeng.main'

crozeng.module_name = 'modules/switcher'

crozeng.onload = function()
  love.window.setMode(800, 600, {
    resizable=true,
    minwidth=400,
    minheight=300,
    highdpi=false
  })
end
