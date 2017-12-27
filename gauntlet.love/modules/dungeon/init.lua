local Module = {}

local Base = require 'modules.base'
local DungeonBodyDefs = require 'modules.dungeon.bodydefs'
local Anims = require 'data.anims'
local Level = require 'modules.dungeon.level'


-- update systems:
-- local timer = require 'systems.timer'
-- local dude = require 'systems.physics'
-- local controller = require 'systems.controller'
-- local archerController = require 'systems.archercontroller'
-- local survivorController = require 'systems.survivorcontroller'
-- local collision = require 'systems.collision'
-- local referee = require 'systems.referee'

-- drawing systems:
local drawPhysics = require 'systems.physicsdraw'
local drawDungeon = require 'modules.dungeon.drawdungeonsystem'


love.physics.setMeter(64) --the height of a meter our worlds will be 64px

local function requireAndCompose(systemReqs)
  local systems = {}
  for i,req in ipairs(systemReqs) do
    local system = require(req)
    assert(system, "Cannot require system '"..req.."'")
    table.insert(systems,system)
  end

  return iterateFuncs(systems)
end

local systemRequires = {
  'systems.timer',
  'systems.controller',
  'systems.herocontroller',
  'systems.physics',
  'systems.collision',
  'systems.referee',
}

local ComposedSystem = requireAndCompose(systemRequires)

local function setupResourcesAndEntities(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = DungeonBodyDefs
  world.resources.anims = Anims.load()

  local estore = world.estore

  estore:newEntity({
    {'name',{name="physics world"}},
    {'physicsWorld', {allowSleep=false, gx=0, gy=0}},
  })
  estore:newEntity({
    {'name',{name="Referee"}},
    {'referee',{}},
    {'controller', {id='referee'}},
  })

  Level.addLevel(estore, opts.levelInfo)
end


Module.newWorld = Base.makeSetupFunc(setupResourcesAndEntities)

Module.updateWorld = Base.makeUpdateFunc(ComposedSystem, function(world,action,exports)
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
    -- love.graphics.setBackgroundColor(40,50,0)
    love.graphics.setBackgroundColor(40,40,40)
  end,
  system=iterateFuncs({
    drawDungeon,
    drawPhysics,
  })
})

return Module
