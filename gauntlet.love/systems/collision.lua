return defineUpdateSystem({'collision'}, function(me,estore,input,res)
  local cleanups={}
  for _,coll in pairs(me.collisions) do
    local them = estore:getEntity(coll.theirEid)
    if me.hero and them.hero then
      -- ?

    elseif me.hero and them.item then
      local i = them.item
      if i.kind == 'key' then
        me.hero.numKeys = me.hero.numKeys + 1
      end
      estore:destroyEntity(them)

    elseif me.hero and them.arrow then
      estore:destroyEntity(them)
      estore:destroyEntity(me)

    elseif me.hero and them.door then
      if me.hero.numKeys > 0 then
        me.hero.numKeys = me.hero.numKeys - 1
        estore:destroyEntity(them)
      else
        -- print("  This door requires a key!")
      end
    else
      -- print("  No action to take.")
    end
    table.insert(cleanups,coll)
  end
  for _,comp in pairs(cleanups) do
    me:removeComp(comp)
  end
end)
