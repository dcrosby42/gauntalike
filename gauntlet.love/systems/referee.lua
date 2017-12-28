require 'ecs.debug'

return defineUpdateSystem({'referee'}, function(me,estore,input,res)
  estore:walkEntities(hasComps('hero'), function(e)
    local ct = e.inv.stoneKeys or 0
    if ct >= 1 then
      -- print("referee: hero key count >= 1, win! "..entityName(e))
      table.insert(input.exports, {
        type='win',
        eid=e.eid,
        name=entityName(e),
      })
    end
  end)
end)
