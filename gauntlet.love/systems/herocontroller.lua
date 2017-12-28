local PI_2 = math.pi / 2
local PI_4 = math.pi / 4
local floor = math.floor
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local elf_update, elf_fireArrow
local angleToDir

local Speed=200

local function timer_startCountUp(timer)
  timer.alarm = false
  timer.countDown = false
  timer.t = 0
  timer.reset = 0
end

local function timer_countUpTo(timer, max)
  timer_startCountUp(timer)
  timer.reset = max
end


local function leftStick_applyVelocity(e)
  e.vel.dx = e.controller.leftx * Speed
  e.vel.dy = e.controller.lefty * Speed
end

local function rightStick_applyDirection(e)
  local rx = e.controller.rightx or 0
  local ry = e.controller.righty or 0
  if rx ~= 0 or ry ~= 0 then
    local r = arcTan(rx,-ry) - PI_2 -- math.atan2 is smart about y=0 case
    e.hero.r = r
    e.hero.dir = angleToDir(r)
  end
end

local function determineAction(e)
  -- Determine proper sprite animation based on new hero state
  if e.hero.attack then
    -- if attacking, that's our action
    e.hero.action = e.hero.attack
  else
    -- otherwise standing or walking based on vel
    if e.vel.dx == 0 and e.vel.dy == 0 then
      e.hero.action = "stand"
    else
      e.hero.action = "walk"
    end
  end
end

local function calcSpriteAnim(e)
  e.sprite.anim = e.hero.race.."/"..e.hero.dir.."/"..e.hero.action
end

local function calcSpriteAnim_elfArrow(e)
  -- local dir = angleToDir(e.arrow.r)
  -- print("calcSpriteAnim_elfArrow: r="..e.arrow.r.." dir="..dir)
  -- e.sprite.anim = "elf/"..dir.."/arrow"
  e.sprite.anim = "elf/r/arrow"
end

local system = defineUpdateSystem({'hero','controller'}, function(e,estore,input,res)
  if e.hero.race == "elf" then
    elf_update(e,estore,input,res)
  end
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
function elf_fireArrow(e, estore,input,res)
  local r = e.hero.r
  local vel = 500
  local dx = vel * cos(r)
  local dy = vel * sin(r)
  local x = e.pos.x
  local y = e.pos.y-4
  estore:seekEntity(hasComps('physicsWorld'), function(pwEnt)
    local arrowE = pwEnt:newChild({
      {'arrow', {r=r}},
      {'sprite',{anim=""}},
      {'body', {kind='arrow',group=e.body.group, debugDraw=false}},
      {'pos', {x=x,y=y, r=r, ox=16, oy=16, sx=2,sy=2}},
      {'vel', {dx=dx,dy=dy}},
    })
    calcSpriteAnim_elfArrow(arrowE)
  end)
end

-- declared local above
function elf_update(e,estore,input,res)
  leftStick_applyVelocity(e)
  rightStick_applyDirection(e)

  local hero = e.hero
  local c = e.controller
  local timer = e.timers.spriteAnim

  if not hero.attack then
    if c.r2 == 1 then
      hero.attack = "shoot"
      c.r2 = 0 -- FIXME dirty trick
      timer_countUpTo(timer, 0.2)
      elf_fireArrow(e,estore,input,res)
    end

  elseif hero.attack == "shoot" then
    if timer.alarm then
      print("  (shoot over)")
      hero.attack = nil
      timer_startCountUp(timer)
    end

  end

  determineAction(e)
  calcSpriteAnim(e)
end

return system
