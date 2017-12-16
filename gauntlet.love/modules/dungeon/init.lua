local Module = {}

local Base = require 'modules.base'
local DungeonBodyDefs = require 'modules.dungeon.bodydefs'
local Anims = require 'data.anims'

-- update systems:
local timerSystem = require 'systems.timer'
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
  timerSystem,
  controllerSystem,
  heroControllerSystem,
  physicsSystem,
  collisionSystem,

  refereeSystem,
})


require 'data/anims'



local function setupResourcesAndEntities(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = DungeonBodyDefs
  world.resources.anims = Anims.load()

  local estore = world.estore

  estore:newEntity({
    {'physicsWorld', {allowSleep=false, gx=0, gy=0}},
  })
  estore:newEntity({
    {'referee',{}},
    {'controller', {id='referee'}},
  })

  Level.addLevel(estore, opts.levelInfo)
end


Module.newWorld = Base.makeSetupFunc(setupResourcesAndEntities)

Module.updateWorld = Base.makeUpdateFunc(UpdateSystem, function(world,action,exports)
  if action.type == 'keyboard' then
    if action.key == '8' and action.state == 'pressed' then
      world.estore:walkEntities(hasComps('mob'), function(e)
        e.vel.dx = -50
      end)
    end
  end
  -- (the 'exports' come from the generated portion of the makeUpdateFunc)
  return world,exports
end)

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
