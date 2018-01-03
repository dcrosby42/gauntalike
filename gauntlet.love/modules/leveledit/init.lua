local ZoomUI = require 'modules.zoomui'
local Anims = require 'data.anims'

local ChunkWidth = 16
local ChunkHeight = 12
local function initChunk(r,c,w,h)
  local chunk = {
    row=r,
    col=c,
    slots={},
  }
  for i=1,w do
    local row = {}
    for j=1,h do
      table.insert(row,0)
    end
    table.insert(chunk.slots,row)
  end
  return chunk
end

local function newMap()
  return {
    tiles={
      [1]={anim="dungeon/slatefloor1"},
      [2]={anim="dungeon/slatefloor2"},
      [3]={anim="dungeon/slatefloor3"},
    },
    chunks={}
  }
end

local function addChunk(map,r,c)
  local chunk = initChunk(r,c,ChunkWidth,ChunkHeight)
  local row = map.chunks[r]
  if not row then
    row = {}
    map.chunks[r] = row
  end
  row[c] = chunk
  return chunk
end

-- local function addPoint(shape,x,y)
--   table.insert(shape.pts, x)
--   table.insert(shape.pts, y)
-- end

local function handleMouse(world,action)
  if action.state == "pressed" then
    -- local x,y = ZoomUI.screenToUI(world.ui, action.x, action.y)
    -- addPoint(world.shape,x,y)
  end
end


--
-- NEW
--

local function newWorld()
  local map = newMap()
  local ch0 = addChunk(map,0,0)
  ch0.slots[1][1] = 1

  local world ={
    map=map,

    -- shape={pts={}},
    ui=ZoomUI.newWorld(),
    resources={
      anims=Anims.load(),
    },
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
local trans = ZoomUI.transxy

local function drawWorld(world)
  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(255,255,255)

  local ui = world.ui

  local ch = world.map.chunks[0][0]
  local tid = ch.slots[1][1]
  local t = world.map.tiles[tid]
  local an = t.anim
  local anim = world.resources.anims[an]
  local pic = anim.pics[1]

  -- love.graphics.draw()
  local x,y = trans(world.ui, 0,0)
  local s = 2 * world.ui.zoom
  love.graphics.draw(pic.image, pic.quad, x,y, 0, s,s, 0,0)
  -- if #world.shape.pts > 2 then
  --   local pts = mapPts(world.shape.pts, function(x,y)
  --     return ZoomUI.uiToScreen(world.ui, x,y)
  --   end)
  --   love.graphics.line(unpack(pts))
  -- end

  ZoomUI.drawWorld(world.ui)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
