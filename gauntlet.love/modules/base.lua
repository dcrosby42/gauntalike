require 'crozeng.helpers'
require 'ecs.ecshelpers'

local Estore = require 'ecs.estore'
local Comps = require 'comps'

local Joystick = require 'util.joystick'
local KeyboardSimGamepad = require 'util.keyboardsimgamepad'


local Module = {}

Module.makeSetupFunc = function(postInit)
  return function(opts)
    local world={
      estore=Estore:new(),
      input={
        dt=0,
        events={}
      },
      resources={
        caches={},
      },
    }

    postInit(opts,world)

    return world
  end
end

local function makeUpdateFunc(updateSystem)
  local ControllerIds = { "one", "two" }
  local keyboardOpts = { devId="two" }

  return function(world,action)
    if action.type == 'tick' then
      world.input.dt = action.dt
      updateSystem(world.estore, world.input, world.resources)
      world.input.events = {}

    elseif action.type == 'joystick' then
      Joystick.handleJoystick(action, ControllerIds, function(controllerId, input,action)
        addInputEvent(world.input, {type='controller', id=controllerId, input=input, action=action})
      end)

    elseif action.type == 'keyboard' then
      KeyboardSimGamepad.handleKeyboard(action, keyboardOpts, function(controllerId, input,action)
        addInputEvent(world.input, {type='controller',id=controllerId, input=input, action=action})
      end)
    end
    return world
  end
end

Module.makeUpdateFunc = function(updateSystem)
  local ControllerIds = { "one", "two" }
  local keyboardOpts = { devId="two" }

  return function(world,action)
    if action.type == 'tick' then
      world.input.dt = action.dt
      updateSystem(world.estore, world.input, world.resources)
      world.input.events = {}

    elseif action.type == 'joystick' then
      Joystick.handleJoystick(action, ControllerIds, function(controllerId, input,action)
        addInputEvent(world.input, {type='controller', id=controllerId, input=input, action=action})
      end)

    elseif action.type == 'keyboard' then
      KeyboardSimGamepad.handleKeyboard(action, keyboardOpts, function(controllerId, input,action)
        addInputEvent(world.input, {type='controller',id=controllerId, input=input, action=action})
      end)
    end
    return world
  end
end

Module.makeDrawFunc = function(opts)
  return function(world)
    if opts.before then
      opts.before(world)
    end
    if opts.system then
      opts.system(world.estore, world.resources)
    end
  end
end


return Module
