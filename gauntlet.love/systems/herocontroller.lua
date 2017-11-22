local heroControllerSystem = defineUpdateSystem({'hero','controller'}, function(e,estore,input,res)
  local c = e.controller
  local pos = e.pos

  pos.x = pos.x + (c.leftx * input.dt * 100)
  pos.y = pos.y + (c.lefty * input.dt * 100)
  pos.r = pos.r + (math.pi * c.rightx * input.dt)
end)

return heroControllerSystem
