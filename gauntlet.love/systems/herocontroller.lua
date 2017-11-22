local PI_2 = math.pi / 2
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local heroControllerSystem = defineUpdateSystem({'hero','controller'}, function(e,estore,input,res)
  local c = e.controller
  local pos = e.pos

  pos.x = pos.x + (c.leftx * input.dt * 100)
  pos.y = pos.y + (c.lefty * input.dt * 100)
  -- pos.r = pos.r + (math.pi * c.rightx * input.dt)
  local rx = c.rightx or 0
  local ry = c.righty or 0
  if rx ~= 0 or ry ~= 0 then
    local r = arcTan(rx,-ry) - PI_2 -- math.atan2 is smart about y=0 case
    pos.r = r

    -- rx = cos(r)
    -- ry = sin(r)
    local mag = sqrt(rx*rx + ry*ry)
    e.debugs.dirmag.value = mag
  end

end)

return heroControllerSystem
