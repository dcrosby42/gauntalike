local Levels = require 'data.levels'
local Dungeon = require 'modules.dungeon'

local Module = {}

Module.newWorld = function()
  local level1 = Levels.getFactories()[1]()
  local dungeon = Dungeon.newWorld({levelInfo=level1})
  local world ={
    dungeon=dungeon,
  }
  return world
end

Module.updateWorld = function(world,action)
  world.dungeon = Dungeon.updateWorld(world.dungeon,action)
  return world
end

Module.drawWorld = function(world)
  Dungeon.drawWorld(world.dungeon)
end

return Module
