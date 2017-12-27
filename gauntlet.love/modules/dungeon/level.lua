
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
  for _,pl in pairs(players) do
    pl.groupId = -groupCounter
    if pl.type == 'elf' then
      par:newChild({
        {'hero', {}},
        {'name', {name=pl.name or "GauntletHero"}},
        {'sprite',{anim="elf/d/walk"}},
        {'timer',{name="spriteAnim", countDown=false}},
        {'body',{kind='gauntletHero',group=pl.groupId, debugDraw=true}},
        {'pos', {x=pl.loc[1],y=pl.loc[2], r=pl.r, ox=10, oy=5, sx=2,sy=2}},
        {'vel', {dx=0,dy=0}},
        {'force', {fx=0,fy=0}},
        {'controller', {id = pl.id}},
      })

    elseif pl.type == 'archer' then
      par:newChild({
        {'archer', {speed=400,hiSpeed=400, loSpeed=200}},
        {'name', {name=pl.name or "Archer"}},
        {'body',{kind='archer',group=pl.groupId, debugDraw=false}},
        {'pos', {x=pl.loc[1],y=pl.loc[2], r=pl.r, ox=10, oy=5, sx=1.5,sy=1.5}},
        {'vel', {dx=0,dy=0}},
        {'force', {fx=0,fy=0}},
        {'controller', {id=pl.id}},
      })
    elseif pl.type == 'survivor' then
      par:newChild({
        {'hero', {feet="idle", weapon="flashlight", action="idle"}},
        {'name', {name=pl.name or "Hero"}},
        {'body',{kind='survivor',group=pl.groupId, debugDraw=false}},
        {'pos', {x=pl.loc[1],y=pl.loc[2], r=pl.r, ox=10, oy=5, sx=0.4,sy=0.4}},
        {'vel', {dx=0,dy=0}},
        {'force', {fx=0,fy=0}},
        {'controller', {id=pl.id}},
        {'timer', {name='moveAnim', countDown=false}},
        {'timer', {name='weaponAnim', countDown=false}},
      })
    else
      error("Cannot add player, unknown pl.type='"..pl.type.."' in: "..tdebug(pl))
    end
    groupCounter = groupCounter + 1
  end
  players._groupCounter = groupCounter
end

local function addItem(par, item)
  par:newChild({
    {'item',{kind='key'}},
    {'body',{kind='item',debugDraw=true}},
    {'pos', {x=item.loc[1], y=item.loc[2]}},
    {'vel', {dx=0,dy=0}},
  })
end

local function addItems(par, items)
  for _,item in pairs(items) do
    addItem(par,item)
  end
end

local function addMobs(par, mobs)
  for _,mob in pairs(mobs) do
    local vel = mob.vel or {0,0}
    par:newChild({
      {'mob',{kind=mob.kind, hp=8}},
      {'body',{kind='mob',debugDraw=true}},
      {'pos', {x=mob.loc[1], y=mob.loc[2]}},
      {'vel', {dx=vel[1],dy=vel[2]}},
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
  addMobs(pworld, level.mobs)
end

return {
  addItem=addItem,

  addLevel=addLevel,
}
