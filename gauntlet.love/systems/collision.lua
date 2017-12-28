
local arcTan = math.atan2
local pow = math.pow
local sqrt = math.sqrt

local Level = require 'modules.dungeon.level'

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


local function mob_arrow(coll,me,them, estore,input,res)
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
  estore:destroyEntity(them) -- remove arrow
  print(msg)

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
      if not me.timers or not me.timers.self_destruct then
        me:newComp("tag", {name="self_destruct"})
        me:newComp("timer", {name="self_destruct",t=1})
      end
    end

    table.insert(cleanups,coll) -- defered component removal
  end

  for _,comp in pairs(cleanups) do
    me:removeComp(comp)
  end
end)
