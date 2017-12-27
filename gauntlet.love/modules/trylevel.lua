local Levels = require 'data.levels'
local Dungeon = require 'modules.dungeon'
local EcsInspector = require 'modules.ecsinspector'

local Module = {}

Module.newWorld = function()
  local level1 = Levels.getFactories()[1]()
  local dungeonWorld = Dungeon.newWorld({levelInfo=level1})
  local world = EcsInspector.newWorld({
    sub={
      module=Dungeon,
      state=dungeonWorld,
    }
  })
  return world
end

Module.updateWorld = EcsInspector.updateWorld
Module.drawWorld = EcsInspector.drawWorld

return Module
