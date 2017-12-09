require 'ecs.ecshelpers'

return defineDrawSystem({'physicsWorld'}, function(physWorldE,estore,res)
  love.graphics.setColor(255,255,255)
  estore:walkEntity(physWorldE, hasComps('body'), function(e)
    if e.body.debugDraw then
      local phobjs = res.caches.physicsObjects
      if phobjs then
        local obj = phobjs[e.body.cid]
        for _,shape in ipairs(obj.shapes) do
          if shape:type() == "CircleShape" then
            local x,y = obj.body:getWorldPoints(shape:getPoint())
            local r = shape:getRadius()
            love.graphics.circle("line", x,y,r)
          elseif shape:type() == "ChainShape" then
            love.graphics.line(obj.body:getWorldPoints(shape:getPoints()))
          else
            love.graphics.polygon("line", obj.body:getWorldPoints(shape:getPoints()))
          end
        end
      end
    end
  end)
end)
