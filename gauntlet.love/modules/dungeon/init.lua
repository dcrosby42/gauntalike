local Module = {}

local Base = require 'modules.base'
local DungeonBodyDefs = require 'modules.dungeon.bodydefs'

-- update systems:
local physicsSystem = require 'systems.physics'
local controllerSystem = require 'systems.controller'
local heroControllerSystem = require 'systems.herocontroller'
local collisionSystem = require 'systems.collision'
-- drawing systems:
local drawPhysics = require 'systems.physicsdraw'
local drawDungeon = require 'modules.dungeon.drawdungeonsystem'

local UpdateSystem = iterateFuncs({
  controllerSystem,
  heroControllerSystem,
  physicsSystem,
  collisionSystem,
})

function setupResourcesAndEntities(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = DungeonBodyDefs

  local estore = world.estore

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
  --   {'pos', {x=1024-15,y=688}},
  --   {'vel', {dx=0,dy=0}},
  -- })
  for _,coords in ipairs({
    {400,400},
    {450,400},
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


Module.newWorld = Base.makeSetupFunc(setupResourcesAndEntities)

Module.updateWorld = Base.makeUpdateFunc(UpdateSystem)

Module.drawWorld = Base.makeDrawFunc({
  before=function(world)
    love.graphics.setBackgroundColor(40,50,0)
  end,
  system=iterateFuncs({
    drawDungeon,
    drawPhysics,
  })
})

return Module
