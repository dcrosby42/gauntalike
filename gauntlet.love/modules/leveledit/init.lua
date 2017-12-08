local ZoomUI = require 'modules.zoomui'

local function addPoint(shape,x,y)
  table.insert(shape.pts, x)
  table.insert(shape.pts, y)
end

local function handleMouse(world,action)
  if action.state == "pressed" then
    local x,y = ZoomUI.screenToUI(world.ui, action.x, action.y)
    -- local x = action.x / world.ui.zoom + world.ui.loc[1]
    -- local y = action.y / world.ui.zoom + world.ui.loc[2]
    print(x,y)

    -- world.ui, action.x, action.y
    addPoint(world.shape,x,y)
  end
  -- print(tflatten(action))
end

--
-- NEW
--
local function newWorld()
  local world ={
    shape={pts={}},
    ui=ZoomUI.newWorld(),
  }
  world.ui.flags.drawGrid = true
  return world
end

--
-- UPDATE
--
local function updateWorld(world,action)
  world.ui, handled = ZoomUI.updateWorld(world.ui, action)
  if handled then return world,nil end

  if action.type == 'tick' then
    --
  elseif action.type == 'mouse' then
    handleMouse(world,action)
  end

  return world, nil
end

local function mapPts(list,fn)
  local res = {}
  for i=1,#list-1,2 do
    res[i],res[i+1] = fn(list[i],list[i+1])
  end
  return res
end

--
-- DRAW
--
local function drawWorld(world)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  local ui = world.ui

  -- love.graphics.push()
  -- love.graphics.translate(-ui.loc[1]*100, -ui.loc[2]*100)

  if #world.shape.pts > 2 then
    local pts = mapPts(world.shape.pts, function(x,y)
      return ZoomUI.uiToScreen(world.ui, x,y)
    end)
    love.graphics.line(unpack(pts))
  end

  -- love.graphics.pop()

  ZoomUI.drawWorld(world.ui)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
