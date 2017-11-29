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
local Physics = require 'systems.physics'
-- local isoSpriteAnimSystem = require 'systems.isospriteanim'
-- local characterControllerSystem = require 'systems.charactercontroller'
-- local blockMoverSystem = require 'systems.blockmover'
-- local blockMapSystem = require 'systems.blockmap'
-- local gravitySystem = require 'systems.gravity'

local Joystick = require 'util.joystick'
local KeyboardSimGamepad = require 'util.keyboardsimgamepad'

local moverSystem = defineUpdateSystem({"pos","vel"}, function(e,estore,input,res)
  e.pos.x = e.pos.x + (e.vel.dx * input.dt)
  e.pos.y = e.pos.y + (e.vel.dy * input.dt)
  if e.pos.x < -100 or e.pos.x > 1500 or e.pos.y < -100 or e.pos.y > 1500 then
    estore:destroyEntity(e)
  end
end)


local RunSystems = iterateFuncs({
  -- outputCleanupSystem,
  -- timerSystem,
  -- selfDestructSystem,
  controllerSystem,
  heroControllerSystem,
  Physics.update,
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
})

local setupEstore
Module.newWorld = function()
  local world={}
  world.input = { dt=0, events={} }
  world.estore = Estore:new()
  world.resources = {}
  world.resources.caches = {}
  setupEstore(world.estore)
  return world
end

function setupEstore(estore)

  -- estore:newEntity({
  --   {'pos', {x=300,y=200, r=math.pi, ox=10, oy=5, sx=1.5,sy=1.5}},
  --   {'vel', {dx=0,dy=0}},
  --   {'controller', {id="two"}},
  --   {'hero', {speed=200}},
  -- })
  local pw = estore:newEntity({
    {'physicsWorld', {allowSleep=false, gx=0, gy=0}},
  })
  pw:newChild({
    {'pos', {x=200,y=100}},
    {'vel', {dx=0,dy=50}},
    {'body',{kind='testbox'}},
  })
  pw:newChild({
    {'hero', {speed=800,hiSpeed=800, loSpeed=400}},
    {'body',{kind='archer'}},
    {'pos', {x=100,y=100, r=0, ox=10, oy=5, sx=1.5,sy=1.5}},
    {'vel', {dx=0,dy=0}},
    {'force', {fx=0,fy=0}},
    {'controller', {id="one"}},
  })

end

--
-- UPDATE
--
local ControllerIds = { "one", "two" }
local keyboardOpts = { devId="one" }

Module.updateWorld = function(world,action)
  if action.type == 'tick' then
    world.input.dt = action.dt
    RunSystems(world.estore, world.input, world.resources)
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

--
-- DRAW
--
local BowArts = {
  rest  ="  -}->",
  drawn ="=--}>",
  fired="     }",
}

local ArrowArts = {
  default="=-->"
}

local function drawAscii(str, p, color)
  love.graphics.setColor(unpack(color))
  love.graphics.print(str, p.x, p.y, p.r, p.sx, p.sy, p.ox, p.oy)
end

local function drawHero(e)
  local key = e.hero.bow
  drawAscii(BowArts[key], e.pos, {255,255,255})
end

local function drawArrow(e)
  drawAscii(ArrowArts.default, e.pos, {150,150,200})
end

Module.drawWorld = function(world)
  world.estore:walkEntities(hasComps('pos'), function(e)
    if e.hero then drawHero(e) end
    if e.arrow then drawArrow(e) end
    if e.physicsObjects then
      for _,obj in ipairs(e.physicsObjects) do
        drawPhysicsObject(e,obj)
      end
    end
  end)

  world.estore:walkEntities(hasComps('physicsWorld'), function(e)
    Physics.draw(e,world.estore,world.input,world.resources)
  end)
end

return Module
