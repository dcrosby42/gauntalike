local Module = {}

local State = {}
local Pressed = {}

local Mapping = {
  w={'lefty',-1},
  s={'lefty',1},
  a={'leftx',-1},
  d={'leftx',1},

  up={'righty',-1},
  down={'righty',1},
  left={'rightx',-1},
  right={'rightx',1},

  rshift={'r1',1},
  space={'r2',1},
  lctrl={'l1',1},
  lshift={'l2',1},

  ["1"]={'face1',1},
  ["2"]={'face2',1},
  ["3"]={'face3',1},
  ["4"]={'face4',1},
}

Module.handleKeyboard = function(action, opts, callback)
  local controllerId = opts.devId or "FIXME"

  -- Protect from out-of-sequence arrivals, sych as a key release event arriving before a press (eg, due to mode switching or something)
  local key = action.key
  local keyState = action.state
  if keyState == 'pressed' then
    if Pressed[key] then
      return
    end
    Pressed[key] = true
  elseif keyState == 'released' then
    if not Pressed[key] then
      return
    end
    Pressed[key] = false
  end


  local m = Mapping[key]
  if m then
    local axis = m[1]
    local changeVal = m[2]
    if keyState == 'released' then
      changeVal = -changeVal
    end
    local s = State[axis] or 0
    s = s + changeVal
    State[axis] = s
    callback(controllerId, axis, s)
  -- else
  --   print(tflatten(action))
  end
end

-- Don't need this yet
-- Module.reset = function()
--   State = {}
--   Pressed = {}
-- end

return Module
