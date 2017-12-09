
local function addWallsAndDoors(par)
  par:newChild({
    {'door', {w=20,h=122}},
    {'body',{kind='door',debugDraw=true}},
    {'pos', {x=1024-10,y=768/2}},
    {'vel', {dx=0,dy=0}},
  })
  par:newChild({
    {'door', {w=20,h=122}},
    {'body',{kind='door',debugDraw=true}},
    {'pos', {x=10,y=768/2}},
    {'vel', {dx=0,dy=0}},
  })
  par:newChild({
    {'door', {w=378,h=20}},
    {'body',{kind='door',debugDraw=true}},
    {'pos', {x=1024/2,y=10}},
    {'vel', {dx=0,dy=0}},
  })
  par:newChild({
    {'door', {w=378,h=20}},
    {'body',{kind='door',debugDraw=true}},
    {'pos', {x=1024/2,y=768-10}},
    {'vel', {dx=0,dy=0}},
  })
  par:newChild({
    {'roomWalls', {}},
    {'body',{kind='roomWalls',debugDraw=true}},
    {'pos', {x=1024/2,y=768/2}},
    {'vel', {dx=0,dy=0}},
  })
end

local function addPlayers(par,players)
  local groupCounter = players._groupCounter or 1
  for plId,pl in pairs(players) do
    par:newChild({
      {'hero', {speed=400,hiSpeed=400, loSpeed=200}},
      {'body',{kind='archer',group=-groupCounter, debugDraw=false}},
      {'pos', {x=pl.loc[1],y=pl.loc[2], r=pl.r, ox=10, oy=5, sx=1.5,sy=1.5}},
      {'vel', {dx=0,dy=0}},
      {'force', {fx=0,fy=0}},
      {'controller', {id=plId}},
    })
    groupCounter = groupCounter + 1
  end
  players._groupCounter = groupCounter
end

local function addItems(par, items)
  for _,item in pairs(items) do
    par:newChild({
      {'item',{kind='key'}},
      {'body',{kind='item',debugDraw=true}},
      {'pos', {x=item.loc[1], y=item.loc[2]}},
      {'vel', {dx=0,dy=0}},
    })
  end
end

local function addLevel(estore,level)
  local pworld
  estore:seekEntity(hasComps('physicsWorld'),function(e) pworld = e end)
  if not pworld then error("Cannot find physicsWorld") end

  addWallsAndDoors(pworld, level.room)
  addItems(pworld, level.items)
  addPlayers(pworld, level.players)
end

return {
  addLevel=addLevel,
}
