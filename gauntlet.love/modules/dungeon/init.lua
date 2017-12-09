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
local Level = require 'modules.dungeon.level'

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

local UpdateSystem = iterateFuncs({
  controllerSystem,
  heroControllerSystem,
  physicsSystem,
  collisionSystem,
})


function level1()
  return {
    name="Level 1",
    players={
      one={
        loc={100,100},
        r=0,
      },
      two={
        loc={600,150},
        r=math.pi,
      },
    },
    items={
      [1]={
        kind='key',
        loc={200,100},
      },
    },
  }
end


function setupResourcesAndEntities(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = DungeonBodyDefs

  local estore = world.estore

  local pw = estore:newEntity({
    {'physicsWorld', {allowSleep=false, gx=0, gy=0}},
  })

  -- initSandbox(estore,pw)
  Level.addLevel(estore, level1())
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
