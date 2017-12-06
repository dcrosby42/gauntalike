local ZoomUi = require 'modules.zoomui'

local function addPoint(shape,x,y)
  table.insert(shape.pts, x)
  table.insert(shape.pts, y)
end

local function handleMouse(world,action)
  if action.state == "pressed" then
    addPoint(world.shape,action.x,action.y)
  end
  -- print(tflatten(action))
end

--
-- NEW
--
local function newWorld()
  local world ={
    shape={pts={}},
    ui=ZoomUi.newWorld(),
  }
  world.ui.flags.drawGrid = true
  return world
end

--
-- UPDATE
--
local function updateWorld(world,action)
  ZoomUi.updateWorld(world.ui, action)

  -- if action.type == 'tick' then
  --   --
  -- elseif action.type == 'mouse' then
  --   handleMouse(world,action)
  -- end

  return world, nil
end

--
-- DRAW
--
local function drawWorld(world)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  if #world.shape.pts > 2 then
    love.graphics.line(unpack(world.shape.pts))
  end

  ZoomUi.drawWorld(world.ui)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
