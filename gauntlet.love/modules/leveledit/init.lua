local ZoomUI = require 'modules.zoomui'
local Anims = require 'data.anims'

local TileWidth = 32
local TileHeight = 32
local ChunkWidth = 16
local ChunkWidthPx = ChunkWidth*TileWidth
local ChunkHeight = 12
local ChunkHeightPx = ChunkHeight*TileHeight

local function chunkToXY(row,col)
  local chx = col * ChunkWidthPx
  local chy = row * ChunkHeightPx
  return chx,chy
end

local function xyToChunk(x,y)
  local col = math.floor(x / ChunkWidthPx)
  local row = math.floor(y / ChunkHeightPx)
  return row,col
end

local function xyToChunkAndSlot(x,y)
  local col = math.floor(x / ChunkWidthPx)
  local slc = math.floor((x - col*ChunkWidthPx) / TileWidth)
  local row = math.floor(y / ChunkHeightPx)
  local slr = math.floor((y - row*ChunkHeightPx) / TileHeight)
  return row,col,slr+1,slc+1
end

local function initChunk(r,c,w,h)
  local chunk = {
    row=r,
    col=c,
    slots={},
  }
  for i=1,h do
    local row = {}
    for j=1,w do
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
      [4]={anim="dungeon/vwall1"},
      [5]={anim="dungeon/hwall1"},
      [6]={anim="dungeon/ulwall1"},
      [7]={anim="dungeon/urwall1"},
      [8]={anim="dungeon/lrwall1"},
      [9]={anim="dungeon/llwall1"},
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

local function getChunk(map,r,c)
  local chrow = map.chunks[r]
  if chrow then
    return chrow[c]
  end
end

-- local function addPoint(shape,x,y)
--   table.insert(shape.pts, x)
--   table.insert(shape.pts, y)
-- end

local function continuePainting(world,action)
  local x,y = ZoomUI.screenToUI(world.ui, action.x, action.y)
  local chr,chc,slr,slc = xyToChunkAndSlot(x,y)
  local chunk = getChunk(world.map, chr,chc)
  if chunk then
    chunk.slots[slr][slc] = world.painting.tid
  end
end

local function startPainting(world,action)
  local tid = world.palette.slots[world.palette.selected]
  if tid and tid > 0 then
    world.painting = {
      tid=tid,
    }
    continuePainting(world,action)
  end
end


local function stopPainting(world,action)
  world.painting = nil
end

local function handleMouse(world,action)
    -- local x,y = ZoomUI.screenToUI(world.ui, action.x, action.y)
    -- addPoint(world.shape,x,y)
  if action.button == 1 then
    if action.state == "pressed" then
      if not world.painting then
        startPainting(world,action)
      end
    elseif action.state == "released" then
      if world.painting then
        stopPainting(world,action)
      end
    end
  end
  if world.painting and action.state == "moved" then
    continuePainting(world,action)
  end
end

local function handleKeyboard(world,action)
  if action.state == "pressed" then
    if action.key == "1" then
      world.palette.selected = 1
    elseif action.key == "2" then
      world.palette.selected = 2
    elseif action.key == "3" then
      world.palette.selected = 3
    elseif action.key == "4" then
      world.palette.selected = 4
    elseif action.key == "5" then
      world.palette.selected = 5
    elseif action.key == "6" then
      world.palette.selected = 6
    elseif action.key == "7" then
      world.palette.selected = 7
    elseif action.key == "8" then
      world.palette.selected = 8
    elseif action.key == "9" then
      world.palette.selected = 9
    elseif action.key == "0" then
      world.palette.selected = 10
    end
  end
end

local function newPalette()
  local pal = {
    selected=1,
    slots={1,2,3,4,5,6,7,8,9,0},
  }
  return pal
end

local function getTilePic(world,tid)
  if tid == 0 then return end
  local t = world.map.tiles[tid]
  local aname = t.anim
  local anim = world.resources.anims[aname]
  local pic = anim.pics[1] -- for now just assume first pic in animation
  return pic
end

local function drawPalette(world)
  local pal = world.palette
  local h = (32*2)+10
  local w = (((32*2)+5)*#pal.slots)+10
  local x=0
  local y=world.ui.pixh-h
  love.graphics.setColor(0,0,150,150)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(255,255,255,150)
  love.graphics.rectangle("line", x, y, w, h)

  y = y + 5
  x = 5
  w = 32*2
  h = w
  for i,tid in ipairs(pal.slots) do
    if i == pal.selected then
      love.graphics.setColor(255,255,255,255)
      love.graphics.rectangle("line", x, y, w, h)
    end
    love.graphics.setColor(255,255,255,255)
    local pic = getTilePic(world,tid)
    if pic then
      love.graphics.draw(pic.image, pic.quad, x,y, 0, 2,2, 0,0)
    end
    love.graphics.print(""..i,x+3,y+3)
    x = x + w + 5
  end

end

--
-- NEW
--
local function randint(lo,hi)
  return math.floor(love.math.random() * (hi-lo+1)) + lo
end

local function newWorld()
  -- FIXME this chunk buildup data must be elsewhere:
  local map = newMap()
  local ch0 = addChunk(map,0,0)
  for i,sr in ipairs(ch0.slots) do
    for j,_ in ipairs(sr) do
      -- ch0.slots[i][j] = 1
      ch0.slots[i][j] = randint(1,3)
    end
  end

  local world ={
    map=map,
    -- shape={pts={}},
    ui=ZoomUI.newWorld({
      zoom=2,
      defaultzoom=2,
      gridsize=32,
    }),
    resources={
      anims=Anims.load(),
    },
    palette=newPalette(),
  }
  -- world.ui.flags.drawGrid = true
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
  elseif action.type == 'keyboard' then
    handleKeyboard(world,action)

  elseif action.type == 'mouse' then
    handleMouse(world,action)
  end

  return world, nil
end

-- Map a list of coords like {x0,y0, x1,y1, ...} by applying fn(x,y)
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


  -- local chunk = world.map.chunks[0][0]
  -- local tid = ch.slots[1][1]
  -- local t = world.map.tiles[tid]
  -- local an = t.anim
  -- local anim = world.resources.anims[an]
  -- local pic = anim.pics[1]

  local chr = 0
  local chc = 0
  local chunk = world.map.chunks[chr][chc]
  local chx,chy = chunkToXY(chr,chc)
  for r,srow in ipairs(chunk.slots) do
    for c,slot in ipairs(srow) do
      tid = slot
      -- if type(slot) == "table" then
      --    tid = slot[1]
      -- end
      if tid ~= 0 then
        local pic = getTilePic(world,tid)

        local mx = chx + ((c-1) * TileWidth)
        local my = chy + ((r-1) * TileHeight)
        local x,y = trans(world.ui, mx,my)
        local s = world.ui.zoom + 0.05
        love.graphics.draw(pic.image, pic.quad, x,y, 0, s,s, 0,0)
      end
    end
  end

  -- for i=0,(16-1)*64,64 do
  --   for j=0,(12-1)*64,64 do
  --     local x,y = trans(world.ui, i,j)
  --     local s = 2 * world.ui.zoom
  --     love.graphics.draw(pic.image, pic.quad, x,y, 0, s,s, 0,0)
  --   end
  -- end

  -- if #world.shape.pts > 2 then
  --   local pts = mapPts(world.shape.pts, function(x,y)
  --     return ZoomUI.uiToScreen(world.ui, x,y)
  --   end)
  --   love.graphics.line(unpack(pts))
  -- end

  ZoomUI.drawWorld(world.ui)

  drawPalette(world)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
