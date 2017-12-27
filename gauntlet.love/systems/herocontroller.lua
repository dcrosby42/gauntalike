local PI_2 = math.pi / 2
local PI_4 = math.pi / 4
local floor = math.floor
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local fireArrow, elfStateMachine
local angleToDir

local Speed=200


local system = defineUpdateSystem({'hero','controller'}, function(e,estore,input,res)
  local c = e.controller

  -- Set velocity based on left stick
  if e.force then
    e.force.fx = c.leftx * Speed
    e.force.fy = c.lefty * Speed
  else
    e.vel.dx = c.leftx * Speed
    e.vel.dy = c.lefty * Speed
  end

  -- Set aim dir based on absolute dir of right stick
  local rx = c.rightx or 0
  local ry = c.righty or 0
  if rx ~= 0 or ry ~= 0 then
    local r = arcTan(rx,-ry) - PI_2 -- math.atan2 is smart about y=0 case
    e.hero.r = r
    e.hero.dir = angleToDir(r)
  end


  -- Firing state machine
  -- bowStateMachine(e,estore,input,res)
  if e.hero.race == "elf" then
    elfStateMachine(e,estore,input,res)
  end

  -- Determine proper sprite animation based on new hero state
  if e.vel.dx == 0 and e.vel.dy == 0 then
    e.hero.action = "stand"
  else
    e.hero.action = "walk"
  end

  e.sprite.anim = e.hero.race.."/"..e.hero.dir.."/"..e.hero.action

end)

-- Determine abstract direction based on angle in radians
-- declared local above
local dirs={"r","dr","d","dl","l","ul","u","ur"}
function angleToDir(r)
  local idx = floor(r / PI_4)
  if idx < 0 then
    idx = #dirs+idx -- negative indexing, coming back from the end of the array
  end
  return dirs[idx+1]
end

-- declared local above
function fireArrow(e, estore,input,res)
  local r = e.hero.r
  local vel = 500 - (e.hero.bowtimer * 800)
  -- local vel = 500
  local dx = vel * cos(r)
  local dy = vel * sin(r)
  local x = e.pos.x
  local y = e.pos.y
  estore:seekEntity(hasComps('physicsWorld'), function(pwEnt)
    pwEnt:newChild({
      {'pos', {x=x,y=y, r=r, ox=10, oy=5, sx=1.5,sy=1.5}},
      {'vel', {dx=dx,dy=dy}},
      {'arrow', {}},
      {'body', {kind='arrow',group=e.body.group}},
    })
  end)
end

-- declared local above
function bowStateMachine(e,estore,input,res)
  local hero = e.hero
  local c = e.controller

  if hero.bow == "rest" then
    hero.speed=hero.hiSpeed
    if e.controller.r2 == 1 then
      hero.bow = "drawn"
      hero.bowtimer = 0.5
    end

  elseif hero.bow == "drawn" then
    hero.speed=hero.loSpeed
    hero.bowtimer = hero.bowtimer - input.dt
    if hero.bowtimer <= 0 then hero.bowtimer = 0 end
    if e.controller.r2 == 0 then
      fireArrow(e,estore,input,res)
      hero.bow = "fired"
      hero.bowtimer = 0.5 -- arrow re-nock timer
    end

  elseif hero.bow == "fired" then
    hero.speed=hero.hiSpeed
    hero.bowtimer = hero.bowtimer - input.dt
    if hero.bowtimer <= 0 then
      hero.bow = "rest"
      hero.bowtimer = 0
    end

  end
end

return system
