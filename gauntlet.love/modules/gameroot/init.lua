local Dungeon = require 'modules.dungeon'


local function newWorld()
  local model ={
    mode="title"
  }
  return model
end

--
-- UPDATE
--

local function winGame(data,world)
  print("WIN! "..tflatten(data))
  world.dungeon = nil
  world.mode = "title"
end

local function handleExports(exports,world)
  if exports then
    for i=1,#exports do
      local export = exports[i]
      if export.type == "win" then
        winGame(export,world)
      end
    end
  end

  return world, nil
end

local function updateWorld(world,action)
  if world.mode == "title" then
    if action.type == "keyboard" and action.state == "pressed" then
      if not world.dungeon then
        world.dungeon = Dungeon.newWorld()
      end
      -- world.dungeon = Dungeon.updateWorld(world.dungeon,action)
      world.mode = "playthru"
    end
  elseif world.mode == "playthru" then
    local exports
    world.dungeon, exports = Dungeon.updateWorld(world.dungeon, action)
    return handleExports(exports,world)
    -- local exports
    -- world.dungeon, exports = Dungeon.updateWorld(world.dungeon, action)
    -- if exports then
    --   for _,export in exports do
    --     if export.type == "win" then
    --       print("WIN! "..tflatten(export))
    --       world.mode = "title"
    --     end
    --   end
    -- end
  end
  return world, nil
end

--
-- DRAW
--

local function drawTitleScreen()
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)
  love.graphics.print(">>> Gaunt-a-like <<<",100,100)
  love.graphics.print("PRESS BUTTON TO PLAY",100,160)
end

local function drawWorld(world)
  if world.mode == "title" then
    drawTitleScreen()
  elseif world.mode == "playthru" then
    Dungeon.drawWorld(world.dungeon)
  end
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
