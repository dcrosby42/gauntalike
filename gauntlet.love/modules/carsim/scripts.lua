local Scripts = {}

local sin = math.sin
local cos = math.cos

-- local function event2mem(event,mem,conf)
-- end
local DriveForce = 500

Scripts.car = function(e,estore,input,res)
  local pedal = -(e.controller.righty)
  if pedal ~= 0 then
    local drive = {
      DriveForce * pedal * cos(e.pos.r),
      DriveForce * pedal * sin(e.pos.r),
    }
    e.force.fx = drive[1]
    e.force.fy = drive[2]
    print(tflatten(e.force))
  end
  local wheel = e.controller.rightx
  if wheel ~= 0 then
    e.pos.r = e.pos.r + wheel * 0.05
  end


  -- local state = e.script.state
  -- local keys = state.keys
  -- local mem = state.mem
  -- if keys then
  --   for _,action in ipairs(keys) do
  --     if action.key == "right" and action.state == "pressed" then
  --       e.vel.dx = 100
  --     elseif action.key == "left" and action.state == "pressed" then
  --       e.vel.dx = -100
  --     end
  --     -- print("script keys: "..tflatten(action))
  --   end
  -- end

  e.script.state.keys = {}
end

return Scripts
