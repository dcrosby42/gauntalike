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

  space={'r2',1},
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
  end
end

Module.reset = function()
  State = {}
  Pressed = {}
end

return Module
