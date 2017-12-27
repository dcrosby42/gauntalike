local function drawCurtain(bounds)
  love.graphics.setColor(0,0,0,100)
  love.graphics.rectangle("fill", unpack(bounds))
  love.graphics.setColor(255,255,255,255)
  love.graphics.print("Dev overlay!")
end

local function drawElist(world,bounds)
  local elist = world.parts.elist
  local estore = world.sub.state.estore
  local x = bounds[1]
  local y = bounds[2]
  local num = 0
  love.graphics.setColor(255,255,255,255)
  estore:walkEntities(nil, function(e)
    num = num + 1
    local ename = entityName(e)
    if num == elist.selectedIndex then
      love.graphics.setColor(150,150,255,255)
      elist.selectedEid = e.eid
    end
    love.graphics.print(ename,x,y)
    love.graphics.setColor(255,255,255,255)
    y = y + 15
  end)
  elist.count = num
end

local function drawEntity(world,bounds)
  local elist = world.parts.elist
  local estore = world.sub.state.estore
  local eid = elist.selectedEid
  local e = estore:getEntity(eid)
  local x = bounds[1]
  local y = bounds[2]
  if e then
    love.graphics.print(entityDebugString(e),x,y)
  end
end

local function drawDevOverlay(world)
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  drawCurtain({0,0,sw,sh})
  drawElist(world,{0,15,100,sh-15})
  drawEntity(world,{100,15,sw-100,sh-15})
end

return drawDevOverlay
