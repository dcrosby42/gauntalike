local PI = math.pi
local PI_2 = math.pi / 2
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local pow = math.pow
local abs = math.abs
local round = math.round

local Speed=400
local StrafeThreshold = PI / 4

-- local WeaponRotation = {"flashlight","knife","handgun","shotgun","rifle"}
local WeaponCycle = {
  flashlight="knife",
  knife="handgun",
  handgun="shotgun",
  shotgun="rifle",
  rifle="flashlight",
}
local WeaponMachines = {}-- populated below

local survivorControllerSystem = defineUpdateSystem({'survivor','controller'}, function(e,estore,input,res)
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
    local r = arcTan(rx,-ry) - PI_2
    e.pos.r = r
  end

  -- Determine relative movement velocity and strafe
  local moveAngle = arcTan(e.vel.dx, -e.vel.dy) - PI_2
  local moveVel = sqrt(pow(e.vel.dx,2) + pow(e.vel.dy,2))
  local strafeAmt = sin(moveAngle-e.pos.r)

  if moveVel > 30 then
    if strafeAmt < -StrafeThreshold then
      e.survivor.feet = "strafe_left"
    elseif strafeAmt > StrafeThreshold then
      e.survivor.feet = "strafe_right"
    else
      e.survivor.feet = "walk"
    end
    e.survivor.action = "move"
  else
    e.survivor.feet = "idle"
    e.survivor.action = "idle"
  end

  -- Select weapon
  if c.face1 ==1 then
    local current = e.survivor.weapon
    local next = WeaponCycle[e.survivor.weapon]
    e.survivor.weapon = next

    c.face1 = 0 -- FIXME this is a dirty trick, forcing state back into the controller to avoid repeats!
  end

  -- Attack state machine
  local fn = WeaponMachines[e.survivor.weapon]
  if fn then fn(e,estore,input,res) end

  if e.survivor.attack ~= "" then
    e.survivor.action = e.survivor.attack
  end

end)

WeaponMachines.flashlight = function(e,estore,input,res)
  if e.survivor.attack == '' then
    if e.controller.r2 > 0 or e.controller.r1 > 0 then
      e.survivor.attack = 'meleeattack'
      e.timers.weaponAnim.t = 0
    end

  elseif e.survivor.attack == 'meleeattack' then
    if e.timers.weaponAnim.t > (14/36) then
      e.survivor.attack = ''
    end

  end
end
WeaponMachines.knife = function(e,estore,input,res)
  if e.survivor.attack == '' then
    if e.controller.r2 > 0 or e.controller.r1 > 0 then
      e.survivor.attack = 'meleeattack'
      e.timers.weaponAnim.t = 0
    end

  elseif e.survivor.attack == 'meleeattack' then
    if e.timers.weaponAnim.t > (14/36) then
      e.survivor.attack = ''
    end

  end
end

WeaponMachines.handgun = function(e,estore,input,res)
  if e.survivor.attack == '' then
    if e.controller.r1 > 0 then
      e.survivor.attack = 'meleeattack'
      e.timers.weaponAnim.t = 0

    elseif e.controller.r2 > 0 then
      e.survivor.attack = 'shoot'
      e.timers.weaponAnim.t = 0

    elseif e.controller.face2 > 0 then
      e.survivor.attack = 'reload'
      e.timers.weaponAnim.t = 0
    end

  elseif e.survivor.attack == 'meleeattack' then
    if e.timers.weaponAnim.t > (14/36) then
      e.survivor.attack = ''
    end

  elseif e.survivor.attack == 'shoot' then
    if e.timers.weaponAnim.t > (3/36) then
      e.survivor.attack = ''
    end

  elseif e.survivor.attack == 'reload' then
    if e.timers.weaponAnim.t > (14/36) then
      e.survivor.attack = ''
    end

  end
end

WeaponMachines.shotgun = function(e,estore,input,res)
  if e.survivor.attack == '' then
    if e.controller.r1 > 0 then
      e.survivor.attack = 'meleeattack'
      e.timers.weaponAnim.t = 0

    elseif e.controller.r2 > 0 then
      e.survivor.attack = 'shoot'
      e.timers.weaponAnim.t = 0

    elseif e.controller.face2 > 0 then
      e.survivor.attack = 'reload'
      e.timers.weaponAnim.t = 0
    end

  elseif e.survivor.attack == 'meleeattack' then
    if e.timers.weaponAnim.t > (14/36) then
      e.survivor.attack = ''
    end

  elseif e.survivor.attack == 'shoot' then
    if e.timers.weaponAnim.t > (3/36) then
      e.survivor.attack = ''
    end

  elseif e.survivor.attack == 'reload' then
    if e.timers.weaponAnim.t > (19/36) then
      e.survivor.attack = ''
    end

  end
end

WeaponMachines.rifle = function(e,estore,input,res)
  if e.survivor.attack == '' then
    if e.controller.r1 > 0 then
      e.survivor.attack = 'meleeattack'
      e.timers.weaponAnim.t = 0

    elseif e.controller.r2 > 0 then
      e.survivor.attack = 'shoot'
      e.timers.weaponAnim.t = 0

    elseif e.controller.face2 > 0 then
      e.survivor.attack = 'reload'
      e.timers.weaponAnim.t = 0
    end

  elseif e.survivor.attack == 'meleeattack' then
    if e.timers.weaponAnim.t > (14/36) then
      e.survivor.attack = ''
    end

  elseif e.survivor.attack == 'shoot' then
    if e.timers.weaponAnim.t > (3/36) then
      e.survivor.attack = ''
    end

  elseif e.survivor.attack == 'reload' then
    if e.timers.weaponAnim.t > (19/36) then
      e.survivor.attack = ''
    end

  end
end

return survivorControllerSystem
