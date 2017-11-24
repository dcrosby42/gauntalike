local Module = {}

local Mappings = {
  ['Generic   USB  Joystick  '] = 'generic',
  ['Wireless Controller'] = 'dualshock4',
}

local Layouts = {}

Layouts["generic"] = {
  axes = {
    [1]="leftx",
    [2]="lefty",
    [3]="unknown",
    [4]="rightx",
    [5]="righty",
  },
  buttons = {
    [1] = "face1",
    [2] = "face2",
    [3] = "face3",
    [4] = "face4",
    [5] = "l2",
    [6] = "r2",
    [7] = "l1",
    [8] = "r1",
    [9] = "select",
    [10] = "start",
    [11] = "l3",
    [12] = "r3",
  }
}
Layouts["dualshock4"] = {
  axes = {
    [1]="leftx",
    [2]="lefty",
    [3]="unknown",
    [4]="rightx",
    [5]="righty",
  },
  buttons = {
    [1] = "face1",
    [2] = "face2",
    [3] = "face3",
    [4] = "face4",
    [5] = "l2",
    [6] = "r2",
    [7] = "l1",
    [8] = "r1",
    [9] = "select",
    [10] = "start",
    [11] = "l3",
    [12] = "r3",
  }
}

-- Secret inner state maintained as we encounter newly connected joystick ids.
local SeenJoysticks = {} -- keys will be joystick ids, values will be tables with keys {controllerId, axisState} where controllerId is user-supplied.
local JoystickCount = 0

local function defaultAxisState()
  return {leftx=0, lefty=0, rightx=0, righty=0}
end

local function joystickIdToControllerId(jsId, controllerIds)
  local jsinfo = SeenJoysticks[jsId]
  if not jsinfo then
    JoystickCount = JoystickCount + 1
    jsinfo = {
      controllerId = controllerIds[JoystickCount],
      axisState = defaultAxisState(),
    }
    SeenJoysticks[jsId] = jsinfo
  end
  return jsinfo.controllerId
end

local function getAxisState(jsId)
  local jsinfo = SeenJoysticks[jsId]
  if not jsinfo then error("No SeenJoysticks["..tostring(jsId).."]") end
  return jsinfo.axisState
end

Module.handleJoystick = function(action, controllerIds, callback)
  local layoutKey = Mappings[action.name] or "generic"
  local layout = Layouts[layoutKey]
  if layoutKey == "dualshock4" then
    print(tdebug(action))
  end

  local axis, value, changed, button
  local controllerId = joystickIdToControllerId(action.joystickId, controllerIds)
  if action.controlType == 'axis' then
    axis = layout.axes[action.control]
    if not axis then return end
    value = math.round1(action.value)
    local axisState = getAxisState(action.joystickId)
    if axisState[axis] ~= value then
      axisState[axis] = value
      callback(controllerId, axis,value)
    end

  elseif action.controlType == 'button' then
    button = layout.buttons[action.control]
    if button then
      callback(controllerId, button,action.value)
    else
      print("UNHANDLED JOYSTICK BUTTON"..tdebug(action))
    end
  end
end

return Module
