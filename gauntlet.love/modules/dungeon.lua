local Module = {}

require 'crozeng.helpers'
require 'ecs.ecshelpers'
local Estore = require 'ecs.estore'
local Comps = require 'comps'
-- local Resources = require 'modules.dungeon.resources'
-- local timerSystem = require 'systems.timer'
-- local scriptSystem = require 'systems.script'
local controllerSystem = require 'systems.controller'
local heroControllerSystem = require 'systems.herocontroller'
-- local isoSpriteAnimSystem = require 'systems.isospriteanim'
-- local characterControllerSystem = require 'systems.charactercontroller'
-- local blockMoverSystem = require 'systems.blockmover'
-- local blockMapSystem = require 'systems.blockmap'
-- local gravitySystem = require 'systems.gravity'

local Joystick = require 'util.joystick'


local RunSystems = iterateFuncs({
  -- outputCleanupSystem,
  -- timerSystem,
  -- selfDestructSystem,
  controllerSystem,
  -- scriptSystem,
  -- characterControllerSystem,
  -- gravitySystem,
  -- isoSpriteAnimSystem,
  -- avatarControlSystem,
  -- moverSystem,
  -- animSystem,
  -- zChildrenSystem,
  -- blockMapSystem,
  -- blockMoverSystem,
  -- effectsSystem,
  heroControllerSystem,
})

local setupEstore
Module.newWorld = function()
  local world={}
  world.input = { dt=0, events={} }
  world.estore = Estore:new()
  setupEstore(world.estore)
  return world
end

function setupEstore(estore)
  estore:newEntity({
    {'pos', {x=100,y=100, r=0, ox=10, oy=5}},
    {'vel', {dx=0,dy=0}},
    -- {'rot', {rad=0}},
    {'controller', {id="one"}},
    {'hero', {}},
    {'debug',{name="dirmag",value=0}}
  })

end

--
-- UPDATE
--

Module.updateWorld = function(world,action)
  if action.type == 'tick' then
    world.input.dt = action.dt
    RunSystems(world.estore, world.input, world.resources)
    world.input.events = {}

  elseif action.type == 'joystick' then
    Joystick.handleJoystick(action, function(input,action)
      addInputEvent(world.input, {type='controller', id='one', input=input, action=action})
    end)
  end

  return world
end

--
-- DRAW
--
local function drawHero(e)
  love.graphics.setColor(255,255,255)
  local p = e.pos
  local dirmag = e.debugs.dirmag.value
  love.graphics.print(tostring(dirmag).."---->", p.x, p.y, p.r, p.sx, p.sy, p.ox, p.oy)
end

Module.drawWorld = function(world)
  world.estore:walkEntities(hasComps('pos'), function(e)
    if e.hero then drawHero(e) end
  end)
end

return Module
