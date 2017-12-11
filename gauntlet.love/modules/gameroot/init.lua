local Dungeon = require 'modules.dungeon'

local function level1()
  return {
    name="Level 1",
    players={
      -- one={
      --   loc={100,100},
      --   r=0,
      -- },
      two={
        name="Hanzo",
        loc={700,150},
        r=math.pi,
      },
    },
    items={
      -- [1]={ kind='key', loc={200,100}, },
      [2]={ kind='key', loc={300,200}, },
    },
  }
end
local function level2()
  return {
    name="Level 1",
    players={
      two={
        name="Hanzo",
        loc={600,450},
        r=math.pi/2,
      },
    },
    items={
      [2]={ kind='key', loc={950,150}, },
    },
  }
end

local function newWorld()
  local model ={
    mode="title",
    currentLevel=0,
    levelFactories={
      level1,
      level2,
      level1,
    }
  }
  return model
end


--
-- UPDATE
--

local function eachOnType(objList, fnMap)
  if objList then
    for i=1,#objList do
      local obj = objList[i]
      local fn = fnMap[obj.type]
      if fn then fn(obj) end
    end
  end
end

local function setLevel(world,level)
  local fact = world.levelFactories[level]
  assert(fact, "No level "..tostring(level))
  world.dungeon = Dungeon.newWorld({
    levelInfo = fact()
  })
  world.currentLevel = level
end

local function updateWorld(world,action)
  if world.mode == "title" then
    if action.type == "keyboard" and action.state == "pressed" then
      world.mode = "playthru"
      setLevel(world,1)
    end

  elseif world.mode == "playthru" then
    local exports
    world.dungeon, exports = Dungeon.updateWorld(world.dungeon, action)
    eachOnType(exports, {
      win=function(export)
        print("Level complete! "..tflatten(export))

        local nextLevel = world.currentLevel + 1
        if not world.levelFactories[nextLevel] then
          world.dungeon = nil
          world.mode = "end"
        else
          setLevel(world,nextLevel)
        end
      end,
    })

  elseif world.mode == "end" then
    if action.type == "keyboard" and action.state == "pressed" then
      world.mode = "title"
    end

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
local function drawEndScreen()
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)
  love.graphics.print("The End. You won!",100,100)
  love.graphics.print("PRESS BUTTON",100,160)
end

local function drawWorld(world)
  if world.mode == "title" then
    drawTitleScreen()
  elseif world.mode == "end" then
    drawEndScreen()
  elseif world.mode == "playthru" then
    Dungeon.drawWorld(world.dungeon)
  end
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
