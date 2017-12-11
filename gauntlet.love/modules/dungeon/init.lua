local Module = {}

local Base = require 'modules.base'
local DungeonBodyDefs = require 'modules.dungeon.bodydefs'

-- update systems:
local physicsSystem = require 'systems.physics'
local controllerSystem = require 'systems.controller'
local heroControllerSystem = require 'systems.herocontroller'
local collisionSystem = require 'systems.collision'
local refereeSystem = require 'systems.referee'
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

  refereeSystem,
})



local function setupResourcesAndEntities(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = DungeonBodyDefs

  local estore = world.estore

  estore:newEntity({
    {'physicsWorld', {allowSleep=false, gx=0, gy=0}},
  })
  estore:newEntity({
    {'scoreboard',{}},
  })

  Level.addLevel(estore, opts.levelInfo)
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
