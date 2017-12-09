local Module = {}

local State = {}

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
  local change = false

  local m = Mapping[action.key]
  if m then
    local axis = m[1]
    local changeVal = m[2]
    if action.state == 'released' then
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
end

return Module
