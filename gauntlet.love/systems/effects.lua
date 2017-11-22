
local Comp = require 'ecs/component'
Comp.define('effect',{'path',{}, 'data',{}, 'timer','','animFunc',''})

local function lookupEntCompKeyByPath(e, path)
  -- local ent = nil
  local key = path[#path]
  local cur = e
  for i=1,#path-2 do
    if path[i] == 'PARENT' then
      cur = cur:getParent()
    else
      cur = cur[path[i]]
    end
    -- if i == 1 then ent = cur end
  end
  local comp = cur[path[#path-1]]
  return cur, comp, key
end

local effectSystem = defineUpdateSystem({'effect','timer'},
  function(e, estore,input,res)
    local effect = e.effect
    -- local data = effect.data
    local timer = e.timers[effect.timer]
    if timer then
      local ent,comp,key = lookupEntCompKeyByPath(e, effect.path)
      local data = effect.data
      if effect.animFunc ~= '' then
        local fn = res.anims[effect.animFunc]
        if fn then
          comp[key] = fn(timer.t)
        end
      else
        local newVal = nil
        for i=1, #data, 2 do
          if timer.t >= data[i] then
            newVal = data[i+1]
          else
            break
          end
        end
        comp[key] = newVal
      end
    end
  end
)

return effectSystem
