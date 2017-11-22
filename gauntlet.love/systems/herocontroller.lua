local PI_2 = math.pi / 2
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local function fireArrow(e, estore,input,res)
  local r = e.pos.r
  local vel = 500 - (e.hero.bowtimer * 800)
  local dx = vel * cos(r)
  local dy = vel * sin(r)
  local x = e.pos.x
  local y = e.pos.y
  estore:newEntity({
    {'pos', {x=x,y=y, r=r, ox=10, oy=5, sx=1.5,sy=1.5}},
    {'vel', {dx=dx,dy=dy}},
    {'arrow', {}},
  })
end

local function bowStateMachine(e,estore,input,res)
  local hero = e.hero
  local c = e.controller

  if hero.bow == "rest" then
    hero.speed=200
    if e.controller.r2 == 1 then
      hero.bow = "drawn"
      hero.bowtimer = 0.5
    end

  elseif hero.bow == "drawn" then
    hero.speed=100
    hero.bowtimer = hero.bowtimer - input.dt
    if hero.bowtimer <= 0 then hero.bowtimer = 0 end
    if e.controller.r2 == 0 then
      fireArrow(e,estore,input,res)
      hero.bow = "fired"
      hero.bowtimer = 0.5 -- arrow re-nock timer
    end

  elseif hero.bow == "fired" then
    hero.speed=200
    hero.bowtimer = hero.bowtimer - input.dt
    if hero.bowtimer <= 0 then
      hero.bow = "rest"
      hero.bowtimer = 0
    end

  end
end

local heroControllerSystem = defineUpdateSystem({'hero','controller'}, function(e,estore,input,res)
  local c = e.controller

  -- Set velocity based on left stick
  e.vel.dx = c.leftx * e.hero.speed
  e.vel.dy = c.lefty * e.hero.speed

  -- Set aim dir based on absolute dir of right stick
  local rx = c.rightx or 0
  local ry = c.righty or 0
  if rx ~= 0 or ry ~= 0 then
    local r = arcTan(rx,-ry) - PI_2 -- math.atan2 is smart about y=0 case
    e.pos.r = r
    -- local mag = sqrt(rx*rx + ry*ry)
    -- e.debugs.dirmag.value = mag
  end

  -- Firing state machine
  bowStateMachine(e,estore,input,res)
end)

return heroControllerSystem
