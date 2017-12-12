-- Enable loading a dir as a package via ${package}/init.lua
package.path = package.path .. ";./?/init.lua"

require 'crozeng.helpers'
local ModuleLoader = require 'crozeng.moduleloader'

local DefaultConfig = {
  width = love.graphics.getWidth(),
  height = love.graphics.getHeight(),
}

local Config = DefaultConfig

local Hooks = {}

local RootModule
local world, errWorld

function setErrorMode(err,traceback)
  print("!! CAUGHT ERROR !!")
  print(err)
  print(traceback)
  errWorld={
    err=err, traceback=traceback, -- debug.traceback()
  }
end
function clearErrorMode()
  errWorld = nil
end

function loadItUp(opts)
  if not opts then opts={} end
  Config = tcopy(DefaultConfig)
  if Hooks.module_name then
    RootModule = ModuleLoader.load(Hooks.module_name)
    ModuleLoader.debug_deps()
  elseif Hooks.module then
    RootModule = Hooks.module
  end
  if not RootModule then
    error("Please specify Hooks.module_name or Hooks.module")
  end
  if not RootModule.newWorld then error("Your module must define a .newWorld() function") end
  if not RootModule.updateWorld then error("Your module must define an .updateWorld() function") end
  if not RootModule.drawWorld then error("Your module must define a .drawWorld() function") end


  if opts.doOnload ~= false then
    if Hooks.onload then
      Hooks.onload()
    end
    Config.width = love.graphics.getWidth()
    Config.height = love.graphics.getHeight()
  end

  world = RootModule.newWorld(opts.newWorldOpts)
  clearErrorMode()
end

local function reloadRootModule(newWorldOpts)
  if Hooks.module_name then
    local names = ModuleLoader.list_deps_of(Hooks.module_name)
    for i=1,#names do
      ModuleLoader.uncache_package(names[i])
    end
    ModuleLoader.uncache_package(Hooks.module_name)


    ok,err = xpcall(function() loadItUp({doOnload=false, newWorldOpts=newWorldOpts}) end, debug.traceback)
    if ok then
      print("crozeng: Reloaded root module.")
      clearErrorMode()
    else
      print("crozeng: RELOAD FAIL!")
      setErrorMode(err,debug.traceback())
    end
  end
end

function love.load()
  loadItUp()
end

local function updateWorld(action)
  if errWorld then
    if action.type == "keyboard" and action.state == "pressed" then
      if action.key == 'r' then
        reloadRootModule()
      end
    end
    return
  end
  if not RootModule then return end
  local newworld, sidefx
  ok,err = xpcall(function() newworld,sidefx = RootModule.updateWorld(world, action) end, debug.traceback)
  if ok then
    if newworld then
      world = newworld
    end
    if sidefx then
      for i=1,#sidefx do
        if sidefx[i].type == 'crozeng.reloadRootModule' then
          reloadRootModule(sidefx[i].opts)
        end
      end
    end
  else
    setErrorMode(err,debug.traceback())
  end
end

local dtAction = {type="tick", dt=0}
function love.update(dt)
  dtAction.dt = dt
  updateWorld(dtAction)
end

function drawErrorScreen(w)
  love.graphics.setBackgroundColor(150,0,0)
  love.graphics.setColor(255,255,255)
  love.graphics.print("!! CAUGHT ERROR !!\n\nHIT 'R' TO RELOAD\n\n"..w.err.."\n\n(inside crozeng)"..w.traceback,0,0)
end

function love.draw()
  if errWorld then
    drawErrorScreen(errWorld)
  else
    ok,err = xpcall(function() RootModule.drawWorld(world) end, debug.traceback)
    if not ok then
      setErrorMode(err,debug.traceback())
    end
  end
end

--
-- INPUT EVENT HANDLERS
--
local function applyKeyboardModifiers(action)
  for _,mod in ipairs({"ctrl","shift","gui"}) do
    action[mod] = false
    action["l"..mod] = false
    action["r"..mod] = false
    if love.keyboard.isDown("l"..mod) then
      action["l"..mod] = true
      action[mod] = true
    elseif love.keyboard.isDown("r"..mod) then
      action["r"..mod] = true
      action[mod] = true
    end
  end
end

local function toKeyboardAction(state,key)
  local keyboardAction = {type="keyboard", action='', key='', ctrl=false, lctrl=false, lctrl=false, shift=false, lshift=false, lshift=false,  gui=false, lgui=false, lgui=false}
  keyboardAction.state=state
  keyboardAction.key=key
  applyKeyboardModifiers(keyboardAction)
  -- for _,mod in ipairs({"ctrl","shift","gui"}) do
  --   keyboardAction[mod] = false
  --   keyboardAction["l"..mod] = false
  --   keyboardAction["r"..mod] = false
  --   if love.keyboard.isDown("l"..mod) then
  --     keyboardAction["l"..mod] = true
  --     keyboardAction[mod] = true
  --   elseif love.keyboard.isDown("r"..mod) then
  --     keyboardAction["r"..mod] = true
  --     keyboardAction[mod] = true
  --   end
  -- end
  return keyboardAction
end
function love.keypressed(key, _scancode, _isrepeat)
  updateWorld(toKeyboardAction("pressed",key))
end
function love.keyreleased(key, _scancode, _isrepeat)
  updateWorld(toKeyboardAction("released",key))
end

local mouseAction = {type="mouse", state=nil, x=0, y=0, dx=0,dy=0,button=0, isTouch=0, ctrl=false, lctrl=false, lctrl=false, shift=false, lshift=false, lshift=false,  gui=false, lgui=false, lgui=false}
function toMouseAction(s,x,y,b,it,dx,dy)
  mouseAction.state=s
  mouseAction.x=x
  mouseAction.y=y
  mouseAction.button=b
  mouseAction.isTouch=it
  mouseAction.dx=dx
  mouseAction.dy=dy
  applyKeyboardModifiers(mouseAction)
  return mouseAction
end

function love.mousepressed(x,y, button, isTouch, dx, dy)
  updateWorld(toMouseAction("pressed",x,y,button,isTouch))
end

function love.mousereleased(x,y, button, isTouch)
  updateWorld(toMouseAction("released",x,y,button,isTouch))
end

function love.mousemoved(x,y, dx,dy, isTouch)
  updateWorld(toMouseAction("moved",x,y,nil,isTouch,dx,dy))
end

local touchAction = {type="touch", state=nil, id='', x=0, y=0, dx=0, dy=0}
function toTouchAction(s,id,x,y,dx,dy)
  touchAction.state= s
  touchAction.id = id
  touchAction.x=x
  touchAction.y=y
  touchAction.dx=dx
  touchAction.dy=dy
  return touchAction
end

function love.touchpressed(id, x,y, dx,dy, pressure)
  updateWorld(toTouchAction("pressed",id,x,y,dx,dy))
end
function love.touchmoved(id, x,y, dx,dy, pressure)
  updateWorld(toTouchAction("moved",id,x,y,dx,dy))
end
function love.touchreleased(id, x,y, dx,dy, pressure)
  updateWorld(toTouchAction("released",id,x,y,dx,dy))
end

local joystickAction = {type="joystick", joystickId=0, instanceId=0, controlType='', control='', value=0}
function toJoystickAction(joystick, controlType, control, value)
  joystickAction.joystickId, joystickAction.instanceId = joystick:getID()
  joystickAction.name = joystick:getName()
  joystickAction.controlType=controlType
  joystickAction.control=control
  joystickAction.value=(value or 0)
  return joystickAction
end

function love.joystickaxis( joystick, axis, value )
  updateWorld(toJoystickAction(joystick, "axis", axis, value))
end

function love.joystickpressed( joystick, button )
  local id,inst = joystick:getID()
  updateWorld(toJoystickAction(joystick, "button",button,1))
end

function love.joystickreleased( joystick, button )
  updateWorld(toJoystickAction(joystick, "button", button,0))
end

function love.textinput(text)
  updateWorld({type='textinput',text=text})
end

function love.resize(w,h)
  updateWorld({type='resize',w=w, h=h})
end

return Hooks
