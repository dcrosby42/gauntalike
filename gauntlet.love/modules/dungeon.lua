local Module = {}

require 'crozeng.helpers'
require 'ecs.ecshelpers'
local Estore = require 'ecs.estore'
local Comps = require 'comps'
local BodyDefs = require 'modules.dungeon_bodydefs'
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

-- local moverSystem = defineUpdateSystem({"pos","vel"}, function(e,estore,input,res)
--   e.pos.x = e.pos.x + (e.vel.dx * input.dt)
--   e.pos.y = e.pos.y + (e.vel.dy * input.dt)
--   if e.pos.x < -100 or e.pos.x > 1500 or e.pos.y < -100 or e.pos.y > 1500 then
--     estore:destroyEntity(e)
--   end
-- end)

local collisionSystem = defineUpdateSystem({'collision'}, function(me,estore,input,res)
  -- print(tostring(me.collision), tostring(#me.collisions))
  -- me:removeComp(me.collision)
  local cleanups={}
  -- print("collisionSystem: me.eid="..me.eid.." has "..numkeys(me.collisions).." collisions:")
  for _,coll in pairs(me.collisions) do
    -- print("  collision comp: "..Comp.debugString(coll))
    local them = estore:getEntity(coll.theirEid)
    -- print("  them.eid="..them.eid)
    if me.hero and them.hero then
      -- print("  HERO FIGHT")

    elseif me.hero and them.item then
      local i = them.item
      -- print("  ITEM! got a ".. i.kind.." destroying item="..them.eid)
      if i.kind == 'key' then
        me.hero.numKeys = me.hero.numKeys + 1
      end
      estore:destroyEntity(them)

    elseif me.hero and them.arrow then
      -- print("  I AM KILLED! destroying me="..me.eid.." and arrow="..them.eid)
      estore:destroyEntity(them)
      estore:destroyEntity(me)

    elseif me.hero and them.door then
      if me.hero.numKeys > 0 then
        me.hero.numKeys = me.hero.numKeys - 1
        -- print("  Opening door, destroying door="..them.eid)
        estore:destroyEntity(them)
      else
        -- print("  This door requires a key!")
      end
    else
      -- print("  No action to take.")
    end
    table.insert(cleanups,coll)
  end
  for _,comp in pairs(cleanups) do
    -- print("  Removing collision comp "..Comp.debugString(comp))
    me:removeComp(comp)
  end
end)


local RunSystems = iterateFuncs({
  -- outputCleanupSystem,
  -- timerSystem,
  -- selfDestructSystem,
  controllerSystem,
  heroControllerSystem,
  Physics.update,
  collisionSystem,
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
  world.resources.bodyDefs = BodyDefs
  setupEstore(world.estore)
  for cid,comp in pairs(world.estore.comps) do
    print("component "..comp.eid.. "."..cid.." - "..comp.type)
  end


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
    {'body',{kind='testbox',debugDraw=true}},
    {'pos', {x=200,y=100}},
    {'vel', {dx=0,dy=50}},
  })
  pw:newChild({
    {'door', {x=0,y=0,w=20,h=100}},
    {'body',{kind='door',debugDraw=true}},
    {'pos', {x=1024-10,y=768/2-5}},
    {'vel', {dx=0,dy=0}},
  })
  pw:newChild({
    {'roomWalls', {}},
    {'body',{kind='roomWalls',debugDraw=true}},
    {'pos', {x=1024/2,y=768/2}},
    {'vel', {dx=0,dy=0}},
  })
  -- pw:newChild({
  --   {'wall', {x=0,y=0,w=10,h=600}},
  --   {'body',{kind='wall',debugDraw=true}},
  --   {'pos', {x=1024-15,y=0}},
  --   {'vel', {dx=0,dy=0}},
  -- })
  -- pw:newChild({
  --   {'wall', {x=0,y=0,w=10,h=600}},
  --   {'body',{kind='wall',debugDraw=true}},
  --   {'pos', {x=1024-15,y=688}},
  --   {'vel', {dx=0,dy=0}},
  -- })
  for _,coords in ipairs({
    {400,400},
    -- {450,400},
  }) do
    local x,y = unpack(coords)
    pw:newChild({
      {'item',{kind='key'}},
      {'body',{kind='item',debugDraw=true}},
      {'pos', {x=x,y=y}},
      {'vel', {dx=0,dy=0}},
    })
  end
  pw:newChild({
    {'hero', {speed=300,hiSpeed=300, loSpeed=100}},
    {'body',{kind='archer',group=-3,debugDraw=false}},
    {'pos', {x=100,y=100, r=0, ox=10, oy=5, sx=1.5,sy=1.5}},
    {'vel', {dx=0,dy=0}},
    {'force', {fx=0,fy=0}},
    {'controller', {id="one"}},
  })
  pw:newChild({
    {'hero', {speed=400,hiSpeed=400, loSpeed=200}},
    {'body',{kind='archer',group=-2,debugDraw=false}},
    {'pos', {x=600,y=150, r=math.pi, ox=10, oy=5, sx=1.5,sy=1.5}},
    {'vel', {dx=0,dy=0}},
    {'force', {fx=0,fy=0}},
    {'controller', {id="two"}},
  })

end

--
-- UPDATE
--
local ControllerIds = { "one", "two" }
local keyboardOpts = { devId="two" }

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
  love.graphics.setBackgroundColor(0,0,0)
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
