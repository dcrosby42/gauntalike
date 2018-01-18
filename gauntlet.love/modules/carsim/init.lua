local Module = {}

local Base = require 'modules.base'
local BodyDefs = require 'modules.carsim.bodydefs'
local Scripts = require 'modules.carsim.scripts'

local UpdateSystem = composeSystems(requireModules({
  'systems.timer',
  'systems.selfdestruct',
  'systems.controller',
  -- 'systems.herocontroller',
  'systems.physics',
  'systems.collision',
  -- 'systems.referee',
  'systems.script',
}))

local DrawSystem = composeDrawSystems(requireModules({
  'systems.physicsdraw',
  -- 'modules.dungeon.drawdungeonsystem',
}))

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

Module.newWorld = Base.makeSetupFunc(function(opts, world)
  world.resources.caches = {}
  world.resources.bodyDefs = BodyDefs
  world.resources.scripts = Scripts
  -- world.resources.anims = Anims.load()
  -- world.resources.maps = {} -- Maps.load()

  local estore = world.estore

  local phys = estore:newEntity({
    {'name',{name="physics world"}},
    {'physicsWorld', {allowSleep=false, gx=0, gy=0}},
  })

  phys:newChild({
    {'name', {name="Car"}},
    {'body',{kind='car', debugDraw=true}},
    {'pos', {x=100,y=100}},
    {'vel', {dx=0,dy=0}},
    {'script',{script='hi',args='',state={keys={}}}},
    -- {'controller', {id = pl.id}},
  })

  -- estore:newEntity({
  --   {'name',{name="Referee"}},
  --   {'referee',{}},
  --   {'controller', {id='referee'}},
  -- })

  -- Level.addLevel(opts.levelInfo, estore, world.resources)
end)



Module.updateWorld = Base.makeUpdateFunc(UpdateSystem, function(world,action,exports)
  if action.type == 'keyboard' then
    world.estore:seekEntity(hasComps('script'), function(e)
      if e.name and e.name.name == 'Car' then
        table.insert(e.script.state.keys, action)
        return true
      end
    end)
    -- if action.key == '8' and action.state == 'pressed' then
    --   world.estore:walkEntities(hasComps('mob'), function(e)
    --     e.vel.dx = -50
    --   end)
    -- end
  end
  -- (the 'exports' come from the generated portion of the makeUpdateFunc)
  return world,exports
end)

Module.drawWorld = Base.makeDrawFunc({
  -- before=function(world)
  --   love.graphics.setBackgroundColor(40,40,40)
  -- end,
  system=DrawSystem,
})

return Module
