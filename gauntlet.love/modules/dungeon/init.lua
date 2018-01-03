local Module = {}

local Base = require 'modules.base'
local DungeonBodyDefs = require 'modules.dungeon.bodydefs'
local Anims = require 'data.anims'
local Level = require 'modules.dungeon.level'

local UpdateSystem = composeSystems(requireModules({
  'systems.timer',
  'systems.selfdestruct',
  'systems.controller',
  'systems.herocontroller',
  'systems.physics',
  'systems.collision',
  'systems.referee',
}))

local DrawSystem = composeDrawSystems(requireModules({
  'systems.physicsdraw',
  'modules.dungeon.drawdungeonsystem',
}))

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

local function setupResourcesAndEntities(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = DungeonBodyDefs
  world.resources.anims = Anims.load()
  world.resources.maps = {} -- Maps.load()

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

  Level.addLevel(opts.levelInfo, estore, world.resources)
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
    love.graphics.setBackgroundColor(40,40,40)
  end,
  system=composeDrawSystems(drawDungeon, drawPhysics)
})

return Module
