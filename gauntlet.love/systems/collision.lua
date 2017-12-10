
local function hero_item(me,them, estore,input,res)
  if them.item.kind == 'key' then
    me.hero.numKeys = me.hero.numKeys + 1
  end
  estore:destroyEntity(them)
end

local function hero_arrow(me,them, estore,input,res)
  estore:destroyEntity(them)
  estore:destroyEntity(me)
end

local function hero_door(me,them, estore,input,res)
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
      hero_item(me,them,estore,input,res)

    elseif me.hero and them.arrow then
      hero_arrow(me,them,estore,input,res)

    elseif me.hero and them.door then
      hero_door(me,them,estore,input,res)

    end

    table.insert(cleanups,coll) -- defered component removal
  end

  for _,comp in pairs(cleanups) do
    me:removeComp(comp)
  end
end)
