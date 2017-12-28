
local arcTan = math.atan2
local pow = math.pow
local sqrt = math.sqrt

local Level = require 'modules.dungeon.level'

local function entity_setSelfDestruct(e,t)
  if not e.timers or not e.timers.self_destruct then
    e:newComp("tag", {name="self_destruct"})
    e:newComp("timer", {name="self_destruct",t=t})
  end
end

local function hero_item(coll,me,them, estore,input,res)
  if them.item.kind == 'key' then
    me.hero.numKeys = me.hero.numKeys + 1
  end
  estore:destroyEntity(them)
end

local function hero_arrow(coll,me,them, estore,input,res)
  estore:destroyEntity(them)
  estore:destroyEntity(me)
end

local function collisionVelocity(coll)
  local avel = coll.contactInfo.a.vel
  local bvel = coll.contactInfo.b.vel
  return sqrt(pow(avel[1]-bvel[1], 2) + pow(avel[2]-bvel[2], 2))
end


local function mob_arrow(coll,me,arrow, estore,input,res)
  -- print("== contactInfo ==\n"..tdebug(coll.contactInfo))
  local mag = collisionVelocity(coll)
  local add = math.floor(4 * ((mag-125) / (500-125)))
  local dmg = 4+add
  -- print("  dmg="..dmg)
  local hp = me.mob.hp
  hp = hp - dmg
  me.mob.hp = hp
  local msg = "Mob "..entityName(me).." hit for dmg="..dmg..", remain hp="..hp
  if hp <= 0 then
    msg = msg .. " KILLED!"

    local count = 0
    estore:walkEntities(hasComps('mob'), function(e) count = count + 1 end)
    if count <= 1 then
      Level.addItem(me:getParent(), { kind='key', loc={me.pos.x,me.pos.y}, })
    end

    estore:destroyEntity(me) -- remove mob
  end
  -- Add splode effect:
  local arrowBody = res.caches.physicsObjects[arrow.body.cid].body
  local splodeX,splodeY = arrowBody:getWorldPoint(13,0)
  local splode = estore:newEntity({
    {'name', {name='splode'}},
    {'sprite',{anim="elf/splode"}},
    {'timer',{name='spriteAnim',countDown=false,t=0,reset=0.27}},
    {'pos', {x=splodeX, y=splodeY, ox=16,oy=16,sx=2,sy=2}},
  })
  entity_setSelfDestruct(splode,0.27)
  estore:destroyEntity(arrow) -- remove arrow




  print(msg)

end

local function arrow_other(coll,me,them, estore,input,res)
  entity_setSelfDestruct(me,1)
end

local function hero_door(coll,me,them, estore,input,res)
  if me.hero.numKeys > 0 then
    me.hero.numKeys = me.hero.numKeys - 1
    estore:destroyEntity(them)
  else
    -- print("  This door requires a key!")
  end
end

return defineUpdateSystem({'collision'}, function(me,estore,input,res)
  local cleanups={}
  for _,coll in pairs(me.collisions) do
    local them = estore:getEntity(coll.theirEid)
    if me.hero and them.item then
      hero_item(coll,me,them,estore,input,res)

    elseif me.hero and them.arrow then
      hero_arrow(coll,me,them,estore,input,res)

    elseif me.hero and them.door then
      hero_door(coll,me,them,estore,input,res)

    elseif me.mob and them.arrow then
      mob_arrow(coll,me,them,estore,input,res)

    elseif me.arrow then
      arrow_other(coll,me,them,estore,input,res)
    end

    table.insert(cleanups,coll) -- defered component removal
  end

  for _,comp in pairs(cleanups) do
    me:removeComp(comp)
  end
end)
