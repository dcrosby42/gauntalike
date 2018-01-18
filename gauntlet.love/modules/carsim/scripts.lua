local Scripts = {}

-- local function event2mem(event,mem,conf)
-- end

Scripts.hi = function(e,estore,input,res)
  local state = e.script.state
  local keys = state.keys
  -- local mem = state.mem
  if keys then
    for _,action in ipairs(keys) do
      if action.key == "right" and action.state == "pressed" then
        e.vel.dx = 100
      elseif action.key == "left" and action.state == "pressed" then
        e.vel.dx = -100
      end
      -- print("script keys: "..tflatten(action))
    end
  end
  state.keys = {}
end

return Scripts
